import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/fixed_size_wrapper.dart';

// 웹 전용 import
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'dart:js_interop';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  static int _videoViewId = 0;
  late String _videoViewType;
  bool _isVideoInitialized = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // 텍스트와 아이콘 크기 상수
  static const double _iconWidth = 36.0;
  static const double _iconSpacing = 12.0;
  static const String _text = '감정을 기록하고 연결하다';
  static const TextStyle _textStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  
  // 텍스트 너비 계산 (한 번만 계산)
  double? _textWidth;
  
  double _getTextWidth() {
    if (_textWidth == null) {
      final textPainter = TextPainter(
        text: TextSpan(text: _text, style: _textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      _textWidth = textPainter.width;
    }
    return _textWidth ?? 200.0; // fallback
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebVideo();
    }
    
    // 애니메이션 컨트롤러 초기화 (총 5초, 한 번만 실행)
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    // 애니메이션 시작 (한 번만 실행, forward()는 자동으로 완료 시 멈춤)
    _animationController.forward();
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // 6초 후 메인 페이지로 이동
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        context.go('/main');
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // 각 요소의 opacity를 연속적으로 계산 (부드러운 전환)
  // Stage 1: 텍스트 표시 (0.0 ~ 0.3)
  // Stage 2: 아이콘 중앙 이동 + 텍스트 fade out (0.3 ~ 0.5)
  // Stage 3: 아이콘 합쳐진 상태 유지 (0.5 ~ 0.65) - 1초
  // Stage 4: 아이콘 fade out (0.65 ~ 0.75)
  // Stage 5: 최종 텍스트 표시 (0.75 ~ 1.0) - 멈춰있음
  
  double _getLongTextOpacity() {
    final value = _animationController.value;
    // 처음부터 나타나 있는 상태로 시작
    if (value < 0.3) {
      // visible (fade in 없이 바로 표시)
      return 1.0;
    } else if (value < 0.5) {
      // 아이콘이 중앙으로 이동하는 동안 텍스트 fade out (0.3~0.5)
      return Curves.easeInOut.transform(1.0 - ((value - 0.3) / 0.2).clamp(0.0, 1.0));
    }
    return 0.0;
  }
  
  double _getShortTextOpacity() {
    // Stage 2는 사용하지 않음
    return 0.0;
  }
  
  double _getFinalTextOpacity() {
    final value = _animationController.value;
    if (value < 0.75) return 0.0;
    if (value < 0.85) {
      // fade in (아이콘 fade out 후)
      return Curves.easeInOut.transform(((value - 0.75) / 0.1).clamp(0.0, 1.0));
    }
    // visible (멈춰있음 - 애니메이션 반복 안 함)
    return 1.0;
  }
  
  // 위치 이동 애니메이션 값 계산 (부드러운 전환)
  Offset _getLongTextOffset() {
    final value = _animationController.value;
    // 위에서 아래로 이동하면서 나타남 (0.0~0.2: fade in, 0.2~0.3: visible, 0.3~0.5: fade out)
    // if (value < 0.2) {
    //   // fade in: 위에서 아래로
    //   final progress = (value / 0.2).clamp(0.0, 1.0);
    //   return Offset(0, -30 * (1.0 - Curves.easeOut.transform(progress)));
    // } else if (value < 0.5) {
    //   // visible 또는 fade out: 중앙 위치 유지
    //   return Offset.zero;
    // }
    // 완전히 사라진 후: 초기 위치
    return const Offset(0, 0);
  }
  
  // 왼쪽 아이콘의 위치 (중앙으로 모이는 애니메이션)
  Offset _getLeftIconOffset() {
    final value = _animationController.value;
    if (value < 0.3) {
      // 텍스트와 함께 있을 때: 왼쪽 위치 유지
      return Offset.zero;
    } else if (value < 0.5) {
      // 중앙으로 모이는 애니메이션
      // Row 구조: [왼쪽 아이콘(_iconWidth)][_iconSpacing][텍스트][_iconSpacing][오른쪽 아이콘(_iconWidth)]
      final textWidth = _getTextWidth();
      final textStart = _iconWidth + _iconSpacing;
      final textCenter = textStart + (textWidth / 2);
      final leftIconCenter = _iconWidth / 2;
      // 왼쪽 아이콘 중심에서 텍스트 중앙으로 이동
      final moveDistance = textCenter - leftIconCenter;
      
      final progress = ((value - 0.3) / 0.2).clamp(0.0, 1.0);
      return Offset(
        moveDistance * Curves.easeInOut.transform(progress),
        0,
      );
    }
    // 합쳐진 상태 유지: 텍스트 중앙 위치
    final textWidth = _getTextWidth();
    final textStart = _iconWidth + _iconSpacing;
    final textCenter = textStart + (textWidth / 2);
    final leftIconCenter = _iconWidth / 2;
    return Offset(textCenter - leftIconCenter, 0);
  }
  
  // 오른쪽 아이콘의 위치 (중앙으로 모이는 애니메이션)
  Offset _getRightIconOffset() {
    final value = _animationController.value;
    if (value < 0.3) {
      // 텍스트와 함께 있을 때: 오른쪽 위치 유지
      return Offset.zero;
    } else if (value < 0.5) {
      // 중앙으로 모이는 애니메이션
      final textWidth = _getTextWidth();
      final textStart = _iconWidth + _iconSpacing;
      final textCenter = textStart + (textWidth / 2);
      final rightIconStart = textStart + textWidth + _iconSpacing;
      final rightIconCenter = rightIconStart + (_iconWidth / 2);
      // 오른쪽 아이콘 중심에서 텍스트 중앙으로 이동
      final moveDistance = textCenter - rightIconCenter;
      
      final progress = ((value - 0.3) / 0.2).clamp(0.0, 1.0);
      return Offset(
        moveDistance * Curves.easeInOut.transform(progress),
        0,
      );
    }
    // 합쳐진 상태 유지: 텍스트 중앙 위치 (왼쪽 아이콘과 같은 위치)
    final textWidth = _getTextWidth();
    final textStart = _iconWidth + _iconSpacing;
    final textCenter = textStart + (textWidth / 2);
    final rightIconStart = textStart + textWidth + _iconSpacing;
    final rightIconCenter = rightIconStart + (_iconWidth / 2);
    return Offset(textCenter - rightIconCenter, 0);
  }
  
  Offset _getIconOnlyOffset() {
    // Stage 2에서 아이콘만 보일 때 (합쳐진 상태)
    return Offset.zero;
  }
  
  // Stage 2에서 합쳐진 아이콘의 offset (완전히 중앙에 겹치도록)
  Offset _getMergedLeftIconOffset() {
    // Stack의 center alignment를 기준으로 완전히 중앙에 위치
    return Offset.zero;
  }
  
  Offset _getMergedRightIconOffset() {
    // Stack의 center alignment를 기준으로 완전히 중앙에 위치 (왼쪽 아이콘과 겹침)
    return Offset.zero;
  }
  
  Offset _getFinalTextOffset() {
    // 중앙에서 그냥 fade in만 되도록 항상 중앙 위치 유지
    return Offset.zero;
  }
  
  // Stage 2의 별도 아이콘은 사용하지 않음 (제거됨)
  
  double _getIconOpacity() {
    final value = _animationController.value;
    // Stage 1: 아이콘 표시 (중앙으로 이동하는 동안에도 계속 보임)
    // 합쳐진 상태로 1초 유지 (0.5~0.65)
    if (value < 0.65) {
      return 1.0;
    } else if (value < 0.75) {
      // fade out (0.65~0.75)
      return Curves.easeInOut.transform(1.0 - ((value - 0.65) / 0.1).clamp(0.0, 1.0));
    }
    // Stage 3 이후: 아이콘 숨김
    return 0.0;
  }
  
  // 아이콘 색상 (항상 흰색 유지)
  Color _getIconColor() {
    return Colors.white;
  }

  void _initializeWebVideo() async {
    _videoViewId++;
    // 타임스탬프를 포함하여 완전히 고유한 viewType 생성
    _videoViewType = 'loading-video-player-${DateTime.now().millisecondsSinceEpoch}-$_videoViewId';
    
    // Flutter의 asset 시스템을 사용하여 올바른 URL 가져오기
    // pubspec.yaml에 등록된 asset 경로 사용 (assets/videos/...)
    final assetKey = 'assets/videos/0_Minimalism_Color_2160x3840-min.mp4';
    final videoUrl = await _getAssetUrl(assetKey);
    
    // HTML5 video 요소 생성
    final videoElement = web.VideoElement()
      ..src = videoUrl
      ..autoplay = true
      ..loop = true
      ..muted = true
      ..style.objectFit = 'cover'
      ..style.width = '100%'
      ..style.height = '100%';
    
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
      }
    });
    
    setState(() {
      _isVideoInitialized = true;
    });
  }

  // Flutter 웹에서 asset URL 가져오기
  Future<String> _getAssetUrl(String assetKey) async {
    try {
      // rootBundle을 통해 asset을 로드하고 Blob URL 생성
      final assetData = await rootBundle.load(assetKey);
      final bytes = assetData.buffer.asUint8List();
      
      // Uint8List를 JSUint8Array로 변환
      final jsUint8Array = bytes.toJS;
      
      // 리스트를 JSArray로 변환하여 Blob 생성
      final blob = web.Blob(
        [jsUint8Array].toJS,
        web.BlobPropertyBag(type: 'video/mp4'),
      );
      
      // URL.createObjectURL 사용 (이미 Dart String 반환)
      return web.URL.createObjectURL(blob);
    } catch (e) {
      return '/assets/$assetKey';
    }
  }
  
  Widget _buildAnimatedContent() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stage 1: 텍스트 + 아이콘 (아이콘이 중앙으로 이동하면서 텍스트만 fade out)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 왼쪽 아이콘 (항상 보임)
              Transform.translate(
                offset: _getLeftIconOffset(),
                child: Opacity(
                  opacity: _getIconOpacity(),
                  child: Image.asset(
                    'assets/images/icn_folder_white.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    color: _getIconColor(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 텍스트 (fade out만 적용)
              Transform.translate(
                offset: _getLongTextOffset(),
                child: Opacity(
                  opacity: _getLongTextOpacity(),
                  child: Text(
                    _text,
                    style: _textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 오른쪽 아이콘 (항상 보임)
              Transform.translate(
                offset: _getRightIconOffset(),
                child: Opacity(
                  opacity: _getIconOpacity(),
                  child: Image.asset(
                    'assets/images/icn_chat_black.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    color: _getIconColor(),
                  ),
                ),
              ),
            ],
          ),
          
          // Stage 2: 최종 텍스트 "감정도감β"
          Transform.translate(
            offset: _getFinalTextOffset(),
            child: Opacity(
              opacity: _getFinalTextOpacity(),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: '감정도감'),
                    TextSpan(
                      text: 'β',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FixedSizeWrapper(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 비디오 배경 (웹 전용)
            if (kIsWeb && _isVideoInitialized)
              Positioned.fill(
                child: HtmlElementView(
                  viewType: _videoViewType,
                ),
              )
            else if (!kIsWeb)
              Container(
                color: Colors.black,
              )
            else
              Container(
                color: Colors.black,
              ),
            
            // 오버레이
            Container(
              color: Colors.black.withOpacity(0.45),
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return _buildAnimatedContent();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
