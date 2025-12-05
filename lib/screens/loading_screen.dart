import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../widgets/fixed_size_wrapper.dart';

// 웹 전용 import
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  static int _videoViewId = 0;
  late String _videoViewType;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebVideo();
    }
    // 5초 후 메인 페이지로 이동
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        context.go('/main');
      }
    });
  }

  void _initializeWebVideo() {
    _videoViewId++;
    // 타임스탬프를 포함하여 완전히 고유한 viewType 생성
    _videoViewType = 'loading-video-player-${DateTime.now().millisecondsSinceEpoch}-$_videoViewId';
    
    // Flutter 웹 빌드에서는 /assets/ 경로로 시작해야 함
    final videoPath = '/assets/videos/0_Minimalism_Color_2160x3840-min.mp4';
    
    // HTML5 video 요소 생성
    final videoElement = html.VideoElement()
      ..src = videoPath
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/icn_folder_white.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '감정을 기록하고 연결하다',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      'assets/images/icn_chat_black.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
