import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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

  void _initializeWebVideo() async {
    _videoViewId++;
    // 타임스탬프를 포함하여 완전히 고유한 viewType 생성
    _videoViewType = 'loading-video-player-${DateTime.now().millisecondsSinceEpoch}-$_videoViewId';
    
    // Flutter의 asset 시스템을 사용하여 올바른 URL 가져오기
    // pubspec.yaml에 등록된 asset 경로 사용 (assets/videos/...)
    final assetKey = 'assets/videos/0_Minimalism_Color_2160x3840-min.mp4';
    final videoUrl = await _getAssetUrl(assetKey);
    
    // HTML5 video 요소 생성
    final videoElement = html.VideoElement()
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
      final blob = html.Blob([bytes]);
      return html.Url.createObjectUrlFromBlob(blob);
    } catch (e) {
      // fallback: 직접 경로 사용 (빌드 구조에 따라 다를 수 있음)
      print('Asset URL 가져오기 실패, fallback 사용: $e');
      return '/assets/$assetKey';
    }
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
