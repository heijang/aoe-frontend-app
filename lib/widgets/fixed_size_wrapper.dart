import 'package:flutter/material.dart';

class FixedSizeWrapper extends StatelessWidget {
  final Widget child;
  
  const FixedSizeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B), // 진한 회색 배경
      body: SafeArea(
        // 노치 영역을 피하기 위해 SafeArea 사용
        top: false, // 상단은 AppBar가 처리하므로 false
        bottom: false, // 하단은 필요시 true로 변경
        child: Center(
          child: Container(
            width: 360,
            height: 800,
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
