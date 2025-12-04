import 'package:go_router/go_router.dart';
import 'screens/loading_screen.dart';
import 'screens/main_screen.dart';
import 'screens/survey_screen.dart';
import 'screens/microphone_permission_screen.dart';
import 'screens/microphone_required_screen.dart';
import 'screens/realtime_emotion_analysis_screen.dart';
import 'screens/signup_method_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/survey',
      builder: (context, state) => const SurveyScreen(),
    ),
    GoRoute(
      path: '/microphone',
      builder: (context, state) => const MicrophonePermissionScreen(),
    ),
    GoRoute(
      path: '/microphone-required',
      builder: (context, state) => const MicrophoneRequiredScreen(),
    ),
    GoRoute(
      path: '/emotion-analysis',
      builder: (context, state) => const RealtimeEmotionAnalysisScreen(),
    ),
    GoRoute(
      path: '/signup-method',
      builder: (context, state) => const SignupMethodScreen(),
    ),
  ],
);

