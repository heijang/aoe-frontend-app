import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FixedSizeWrapper extends StatelessWidget {
  final Widget child;
  
  const FixedSizeWrapper({super.key, required this.child});

  // 화면 크기에 따라 모바일/태블릿 구분
  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600; // 600px 이상이면 태블릿으로 간주
  }

  // 반응형 너비 계산
  double _getResponsiveWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (_isTablet(context)) {
      // 태블릿: 전체 너비 사용 (iPad Pro 등 대형 태블릿 지원)
      return screenWidth;
    } else {
      // 모바일: 최대 480px, 최소 320px
      return screenWidth.clamp(320.0, 480.0);
    }
  }

  // 반응형 높이 계산
  double _getResponsiveHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 모든 경우에 화면 높이의 100% 사용
    return screenHeight;
  }

  @override
  Widget build(BuildContext context) {
    final width = _getResponsiveWidth(context);
    final height = _getResponsiveHeight(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black, // 검은색 배경으로 변경
      body: kIsWeb
          ? // 웹에서는 SafeArea 없이 직접 처리
          Align(
              alignment: Alignment.center,
              child: Container(
                width: width,
                height: height,
                constraints: BoxConstraints(
                  minWidth: _isTablet(context) ? 600.0 : 320.0,
                  maxWidth: _isTablet(context) ? double.infinity : 480.0, // 태블릿은 전체 너비 허용
                  minHeight: _isTablet(context) ? 800.0 : 600.0,
                  maxHeight: mediaQuery.size.height, // 화면 전체 높이 사용
                ),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: child,
              ),
            )
          : // 앱에서는 SafeArea 사용
          SafeArea(
              // 노치 영역을 피하기 위해 SafeArea 사용
              top: false, // 상단은 AppBar가 처리하므로 false
              bottom: false, // 하단은 필요시 true로 변경
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: width,
                  height: height,
                  constraints: BoxConstraints(
                    minWidth: _isTablet(context) ? 600.0 : 320.0,
                    maxWidth: _isTablet(context) ? 768.0 : 480.0,
                    minHeight: _isTablet(context) ? 800.0 : 600.0,
                    maxHeight: mediaQuery.size.height, // 화면 전체 높이 사용
                  ),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
    );
  }
}
