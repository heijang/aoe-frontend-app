import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../widgets/fixed_size_wrapper.dart';

class EmotionRecordingScreen extends StatefulWidget {
  const EmotionRecordingScreen({super.key});

  @override
  State<EmotionRecordingScreen> createState() => _EmotionRecordingScreenState();
}

class _EmotionRecordingScreenState extends State<EmotionRecordingScreen> {
  Timer? _dataTimer; // 그래프 데이터 타이머
  Timer? _timeTimer; // 경과 시간 타이머
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  bool _isRecording = false; // 녹음 시작 여부
  final List<double> _emotionData = []; // 최초에는 빈 배열로 시작
  final Random _random = Random(); // 랜덤 생성기

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 자동으로 녹음 시작
    _startRecording();
  }

  void _startRecording() {
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
        _isPaused = false;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    // 기존 타이머들 취소
    _dataTimer?.cancel();
    _timeTimer?.cancel();
    
    // 그래프 데이터 타이머 (0.5초마다)
    _dataTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isPaused && _isRecording && mounted) {
        setState(() {
          // 랜덤 값 생성 (0.2 ~ 0.75 범위)
          final randomPercent = _random.nextInt(100);
          double randomValue;
          
          // 다양한 감정 상태를 랜덤하게 생성
          if (randomPercent < 30) {
            // 평온 (0.2 ~ 0.3)
            randomValue = 0.2 + _random.nextDouble() * 0.1;
          } else if (randomPercent < 70) {
            // 중립 (0.3 ~ 0.6)
            randomValue = 0.3 + _random.nextDouble() * 0.3;
          } else {
            // 분노 (0.6 ~ 0.75)
            randomValue = 0.6 + _random.nextDouble() * 0.15;
          }
          
          // 이전 값과의 연속성을 위해 약간의 변화만 주기 (부드러운 그래프)
          if (_emotionData.isNotEmpty) {
            final lastValue = _emotionData.last;
            // 이전 값에서 ±0.15 범위 내에서 변화
            final variation = (randomValue - lastValue).clamp(-0.15, 0.15);
            randomValue = (lastValue + variation).clamp(0.2, 0.75);
          }
          
          // 고정된 개수 유지 (그래프가 흘러가는 효과)
          // 최대 40개까지만 유지하고, 새로운 데이터가 들어오면 오래된 데이터 제거
          _emotionData.add(randomValue);
          if (_emotionData.length > 40) {
            _emotionData.removeAt(0);
          }
        });
      }
    });
    
    // 경과 시간 타이머 (1초마다)
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _isRecording && mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      // 일시정지 시 타이머는 계속 돌지만 데이터 추가는 멈춤
      // 재생 시 다시 데이터 추가 시작
    });
  }
  
  @override
  void dispose() {
    _dataTimer?.cancel();
    _timeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour > 12 ? '오후' : '오전'} ${(now.hour % 12 == 0 ? 12 : now.hour % 12).toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return FixedSizeWrapper(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          toolbarHeight: 40,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 18,
            ),
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              context.go('/emotion-analysis');
            },
          ),
          title: const Text(
            '실시간 감정 분석',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 구분선
            Container(
              height: 1,
              color: const Color(0xFF404040),
            ),
            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // 상태 메시지
                    const Text(
                      '대화 속 감정을 측정하고 있어요.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 위치 및 시간 정보
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 아이콘 (두 개의 사각형)
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(right: 8, top: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 2,
                                top: 2,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '강남구 언주로',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$dateStr $timeStr',
                                style: const TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 시간 표시
                        Text(
                          _formatTime(_elapsedSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // 그래프 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 그래프 영역
                          SizedBox(
                            height: 200,
                            child: CustomPaint(
                              painter: EmotionGraphPainter(_emotionData),
                              child: Container(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 범례
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // 평온 (녹색)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '평온',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 중립 (회색)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF999999),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '중립',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 분노 (빨간색)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF44336),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '분노',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // 하단 네비게이션 바
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF404040),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 홈 버튼
                  IconButton(
                    onPressed: () {
                      context.go('/main');
                    },
                    icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  // 일시정지/재생 버튼
                  GestureDetector(
                    onTap: _togglePause,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  // 공유 버튼
                  IconButton(
                    onPressed: () {
                      // TODO: 공유 기능 구현
                    },
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 그래프를 그리는 CustomPainter
class EmotionGraphPainter extends CustomPainter {
  final List<double> data;
  final double calmThreshold = 0.3; // 평온 기준값
  final double angerThreshold = 0.6; // 분노 기준값

  EmotionGraphPainter(this.data);

  Color _getColorForValue(double value) {
    if (value <= calmThreshold) {
      return const Color(0xFF4CAF50); // 녹색 (평온)
    } else if (value >= angerThreshold) {
      return const Color(0xFFF44336); // 빨간색 (분노)
    } else {
      return const Color(0xFF999999); // 회색 (중립)
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // 고정된 데이터 포인트 개수 (그래프가 흘러가는 효과를 위해)
    final maxPoints = 40;
    final displayData = data.length > maxPoints 
        ? data.sublist(data.length - maxPoints) 
        : data;
    
    // 데이터가 적을 때는 왼쪽부터, 많을 때는 최근 데이터만 표시
    final stepX = displayData.length > 1 
        ? size.width / (displayData.length - 1).toDouble()
        : 0.0;

    // 각 구간별로 색상을 다르게 그리기
    for (int i = 0; i < displayData.length - 1; i++) {
      final x1 = i * stepX;
      final y1 = size.height * (1.0 - displayData[i]);
      final x2 = (i + 1) * stepX;
      final y2 = size.height * (1.0 - displayData[i + 1]);
      
      // 두 점의 평균값으로 색상 결정
      final avgValue = (displayData[i] + displayData[i + 1]) / 2;
      final color = _getColorForValue(avgValue);
      
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3.5 // 더 두껍게
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(x1, y1);
      path.lineTo(x2, y2);
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(EmotionGraphPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

