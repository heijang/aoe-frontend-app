import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import '../widgets/fixed_size_wrapper.dart';

// 웹 전용 import
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class RealtimeEmotionAnalysisScreen extends StatefulWidget {
  const RealtimeEmotionAnalysisScreen({super.key});

  @override
  State<RealtimeEmotionAnalysisScreen> createState() => _RealtimeEmotionAnalysisScreenState();
}

class _RealtimeEmotionAnalysisScreenState extends State<RealtimeEmotionAnalysisScreen> {
  VideoPlayerController? _videoController;
  static int _videoViewId = 0;
  late String _videoViewType;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebVideo();
    } else {
      _initializeNativeVideo();
    }
  }

  void _initializeWebVideo() {
    _videoViewId++;
    _videoViewType = 'video-player-$_videoViewId';
    
    // HTML5 video 요소 생성
    final videoElement = html.VideoElement()
      ..src = 'assets/images/GettyImages.mp4'
      ..autoplay = true
      ..loop = true
      ..muted = true
      ..setAttribute('playsinline', 'true')
      ..style.objectFit = 'cover'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0';
    
    // 플랫폼 뷰로 등록
    ui_web.platformViewRegistry.registerViewFactory(
      _videoViewType,
      (int viewId) => videoElement,
    );
    
    // 비디오 로드 완료 대기
    videoElement.onLoadedData.listen((_) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        videoElement.play();
      }
    });
    
    // 에러 처리
    videoElement.onError.listen((_) {
      print('비디오 로드 오류: ${videoElement.error}');
    });
    
    setState(() {
      _isVideoInitialized = true;
    });
  }

  void _initializeNativeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/images/GettyImages.mp4');
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.play();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('비디오 초기화 오류: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _startAnalysis(BuildContext context) {
    // TODO: 감정 분석 시작
  }

  @override
  Widget build(BuildContext context) {
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
              context.go('/main');
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 배경 (검은색)
                  Container(
                    color: Colors.black,
                  ),
                  
                  // 텍스트 영역 (상단)
                  Positioned(
                    top: 40,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '3초간 깊게 호흡을 고르세요.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '분석 정확도와 감정 컨트롤에 도움이 됩니다.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 동영상 영역 (세로 30% 지점부터 시작)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final videoTop = constraints.maxHeight * 0.3;
                        return Stack(
                          children: [
                            // 동영상 배경
                            Positioned(
                              top: videoTop,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: kIsWeb && _isVideoInitialized
                                  ? HtmlElementView(
                                      viewType: _videoViewType,
                                    )
                                  : !kIsWeb && _videoController != null && _videoController!.value.isInitialized
                                      ? FittedBox(
                                          fit: BoxFit.cover,
                                          child: SizedBox(
                                            width: _videoController!.value.size.width,
                                            height: _videoController!.value.size.height,
                                            child: VideoPlayer(_videoController!),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.black,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                            ),
                            
                            // 오버레이 그라데이션 (하단 어둡게)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 200,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // 하단 제어 버튼들
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 기록 버튼 (왼쪽)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  // 재생/시작 버튼 (가운데 - 큰 원형 마이크 버튼)
                  GestureDetector(
                    onTap: () => _startAnalysis(context),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 3,
                                color: Colors.white,
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.circle,
                                size: 3,
                                color: Colors.white,
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.circle,
                                size: 3,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 공유/다음 버튼 (오른쪽)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
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
