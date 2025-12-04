import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../widgets/fixed_size_wrapper.dart';

class MicrophoneRequiredScreen extends StatelessWidget {
  const MicrophoneRequiredScreen({super.key});

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
              context.go('/microphone');
            },
          ),
          title: const Text(
            '마이크 설정',
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // 상단 여백
                    Expanded(
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/icn_folder_double.svg',
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    // 하단 텍스트
                    Column(
                      children: [
                        // 제목
                        const Text(
                          '마이크 권한 허용',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        
                        // 설명
                        const Text(
                          '권한이 없으면 감정 분석을 진행할 수 없습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.go('/emotion-analysis');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
              ),
              child: const Text(
                '허용하고 시작하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

