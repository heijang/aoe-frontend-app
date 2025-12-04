import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../widgets/fixed_size_wrapper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  // ============================================
  // 모달 팝업 제어 플래그
  // ============================================
  // true로 설정하면 모달이 표시되고, false로 설정하면 숨겨집니다.
  // 다른 기능 개발을 위해 현재는 false로 설정하여 모달을 숨김 처리했습니다.
  // 개발 완료 후 다시 true로 변경하여 모달을 활성화할 수 있습니다.
  static const bool _enableModalPopup = false;
  
  bool _showModal = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // 슬라이드 애니메이션 설정 (하단에서 올라오기)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // 하단에서 시작
      end: Offset.zero, // 원래 위치
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // ============================================
    // 모달 팝업 표시 로직
    // ============================================
    // _enableModalPopup 플래그가 true일 때만 모달을 표시합니다.
    // 1초 후 모달 표시 및 애니메이션 시작
    if (_enableModalPopup) {
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showModal = true;
          });
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FixedSizeWrapper(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  // 배경 이미지 영역은 그대로
              // 상단 배경 이미지 영역 (고정 높이 254px)
              SizedBox(
                height: 254,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 배경 이미지
                    Image.asset(
                      'assets/images/home_01_bg.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 이미지 로드 실패 시 에러 출력 및 대체 배경
                        print('이미지 로드 오류: $error');
                        print('스택 트레이스: $stackTrace');
                        return Container(
                          color: const Color(0xFF1E3A8A), // 파란색 배경
                          child: const Center(
                            child: Text(
                              '이미지 로드 실패',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) {
                          return child;
                        }
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: child,
                        );
                      },
                    ),
                    // 콘텐츠 오버레이
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        children: [
                          // 상단 헤더
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 왼쪽: 로고 아이콘
                              SvgPicture.asset(
                                'assets/images/symbol_logo.svg',
                                width: 80,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              // 오른쪽: 알림 아이콘
                              IconButton(
                                icon: SvgPicture.asset(
                                  'assets/images/icon_noti.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  // 알림 기능
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 네비게이션 인디케이터
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 2,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // 중앙 메인 콘텐츠
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 메인 타이틀
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    '감정도감 오픈 이벤트',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.confirmation_number_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // 부제목 1
                              const Text(
                                '스타벅스부터 유로리포트 할인 쿠폰까지!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 부제목 2
                              const Text(
                                'AI 감정분석으로 일상 속 인사이트를 확인하세요.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 배경 이미지 아래 검은 영역
              Expanded(
                child: Column(
                  children: [
                    // 상단 헤더 (최근 기록)
                    Container(
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 좌측: 최근 기록 텍스트
                          const Text(
                            '최근 기록',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          // 우측: 선택박스 (전체)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  '전체',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 목록 영역
                    Expanded(
                      child: Container(
                        color: Colors.black,
                        // TODO: 목록이 여기에 들어갈 예정
                      ),
                    ),
                  ],
                ),
              ),
              // 하단 네비게이션 바
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/icon_home.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        // 홈 기능
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/icon_report.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        // 리포트 기능
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/icon_more.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        // 더보기 기능
                      },
                    ),
                  ],
                ),
              ),
                ],
              ),
              // 플로팅 액션 버튼 (우측 하단) - 모달 뒤로
              Positioned(
                right: 24.0,
                bottom: 100.0, // 하단 네비게이션 바 위로
                child: GestureDetector(
                  onTap: () {
                    // 실시간 감정 분석 화면으로 이동
                    context.go('/emotion-analysis');
                  },
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: SvgPicture.asset(
                      'assets/images/icon_float_record.svg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      semanticsLabel: '녹음 버튼',
                      errorBuilder: (context, error, stackTrace) {
                        print('SVG 로드 오류: $error');
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1F69FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // ============================================
              // 모달 팝업 (최근 기록 헤더부터 하단 네비게이션 바까지)
              // ============================================
              // _enableModalPopup 플래그가 true이고 _showModal이 true일 때만 표시됩니다.
              // 현재는 _enableModalPopup이 false로 설정되어 있어 모달이 표시되지 않습니다.
              if (_enableModalPopup && _showModal)
                Positioned(
                  top: 254.0, // 배경 이미지 영역 높이
                  left: 0,
                  right: 0,
                  bottom: 0, // 하단 네비게이션 바까지
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // 모달 내용
                        Column(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '지금 가입하면',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(text: '유로 감정 리포트 '),
                                        TextSpan(
                                          text: '3회 무료',
                                          style: TextStyle(
                                            color: Color(0xFF1F69FF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // 가입하고 혜택받기 버튼
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.go('/signup-method');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1F69FF),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        '가입하고 혜택받기',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // 로그인 링크
                                  GestureDetector(
                                    onTap: () {
                                      // 로그인 기능
                                    },
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(text: '이미 회원이신가요? '),
                                          TextSpan(
                                            text: '로그인',
                                            style: TextStyle(
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // WELCOME 태그 이미지 영역 (위쪽)
                        Positioned(
                          top: 40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image.asset(
                              'assets/images/signup_pop_img.png',
                              width: MediaQuery.of(context).size.width * 0.3,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
