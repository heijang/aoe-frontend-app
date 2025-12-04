import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/fixed_size_wrapper.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      'question': '지금 이 앱을 쓰는 이유는 무엇인가요?',
      'answers': ['업무 효율', '관계 개선', '소통 강화', '셀프케어', '직접 입력']
    },
    {
      'question': '지금 내 상태를 가장 잘 표현하는 감정은?',
      'answers': ['불안', '기쁨', '슬픔', '분노', '혼란', '중립']
    },
    {
      'question': '이번 사용에서 이루고 싶은 목표는?',
      'answers': ['감정 기복 줄이기', '자신감 있게 말하기', '스트레스 낮추기', '집중 유지하기', '객관적인 기록 남기기']
    },
    {
      'question': '결과 활용 방식은 어떻게 하고 싶나요?',
      'answers': ['나만 확인할 거에요.', '공유도 해보고 싶어요.']
    },
    {
      'question': '감정도감을 어떻게 아셨나요?',
      'answers': ['인스타그램/페이스북', '유튜브', '인터넷 검색', '지인 추천', '블로그/커뮤니티', '기타']
    },
    {
      'question': '성별이 어떻게 되시나요?',
      'answers': ['여자', '남자', '기타']
    }
  ];

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    
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
            '설문',
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
            // 질문
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      currentQuestion['question'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // 답변 옵션들
                    ...currentQuestion['answers'].map<Widget>((answer) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedAnswer = answer;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                                return const Color(0xFF404040);
                              }
                              return selectedAnswer == answer 
                                  ? const Color(0xFF1E3A8A) 
                                  : const Color(0xFF1A1A1A);
                            }),
                            foregroundColor: WidgetStateProperty.all(Colors.white),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: const BorderSide(
                                color: Color(0xFF404040),
                                width: 1,
                              ),
                            )),
                            elevation: WidgetStateProperty.all(0),
                            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                          ),
                          child: Text(
                            answer,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            
            // 하단 네비게이션
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // 진행 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(questions.length, (index) {
                      return Container(
                        width: index == currentQuestionIndex ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == currentQuestionIndex 
                              ? Colors.white 
                              : const Color(0xFF404040),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 다음 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentQuestionIndex < questions.length - 1) {
                          setState(() {
                            currentQuestionIndex++;
                            selectedAnswer = null;
                          });
                        } else {
                          // 설문 완료 -> 마이크 권한 페이지로 이동
                          context.go('/microphone');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: const BorderSide(
                            color: Color(0xFF404040),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        currentQuestionIndex < questions.length - 1 ? '다음' : '시작하기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
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
