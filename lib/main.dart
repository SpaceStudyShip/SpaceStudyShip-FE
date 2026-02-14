import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/env_config.dart';
import 'core/services/fcm/firebase_messaging_service.dart';
import 'core/services/fcm/local_notifications_service.dart';
import 'core/constants/text_styles.dart';
import 'core/theme/app_theme.dart';
import 'features/todo/data/datasources/local_todo_datasource.dart';
import 'features/todo/presentation/providers/todo_provider.dart';
import 'routes/app_router.dart';

void main() async {
  // Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // 1. 환경 변수 초기화 (API URL 등)
  // ============================================================
  await EnvConfig.initialize();

  // ============================================================
  // 2. 화면 방향을 세로 모드(정방향)로 고정
  // ============================================================
  try {
    debugPrint('🔒 [Screen] 화면 방향 고정 시작...');
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    debugPrint('✅ [Screen] 화면 방향이 세로 모드로 고정되었습니다.');
  } catch (e, stackTrace) {
    debugPrint('❌ [Screen] 화면 방향 고정 실패: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // ============================================================
  // 3. Firebase 초기화
  // ============================================================
  bool isFirebaseInitialized = false;
  try {
    debugPrint('🚀 [Firebase] 초기화 시작...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    isFirebaseInitialized = true;
    debugPrint('✅ [Firebase] 초기화 완료!');
  } catch (e, stackTrace) {
    debugPrint('❌ [Firebase] 초기화 실패: $e');
    debugPrint('Stack trace: $stackTrace');
    debugPrint('⚠️ [경고] Firebase 기능을 사용할 수 없습니다.');
  }

  // ============================================================
  // 4. Crashlytics 설정 (Firebase 성공 시에만 실행)
  // ============================================================
  if (isFirebaseInitialized) {
    try {
      debugPrint('🔧 [Crashlytics] 초기화 시작...');

      // 개발 모드에서는 Crashlytics 비활성화
      if (kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          false,
        );
        debugPrint('🔧 [Crashlytics] Debug 모드에서 비활성화되었습니다.');
      }

      // Flutter 프레임워크 에러 캡처
      FlutterError.onError = (errorDetails) {
        if (kDebugMode) {
          debugPrint('🔥 [Flutter Error] ${errorDetails.exception}');
          debugPrint('Stack trace: ${errorDetails.stack}');
        } else {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        }
      };

      // 비동기 에러 캡처
      PlatformDispatcher.instance.onError = (error, stack) {
        if (kDebugMode) {
          debugPrint('🔥 [Async Error] $error');
          debugPrint('Stack trace: $stack');
        } else {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      debugPrint('✅ [Crashlytics] 초기화 완료!');
    } catch (e, stackTrace) {
      debugPrint('❌ [Crashlytics] 초기화 실패: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    // ============================================================
    // 4-1. Firebase Analytics 초기화
    // ============================================================
    try {
      debugPrint('📊 [Analytics] 초기화 시작...');

      final analytics = FirebaseAnalytics.instance;

      // 개발 모드에서는 Analytics 비활성화
      if (kDebugMode) {
        await analytics.setAnalyticsCollectionEnabled(false);
        debugPrint('📊 [Analytics] Debug 모드에서 비활성화되었습니다.');
      } else {
        await analytics.setAnalyticsCollectionEnabled(true);
        await analytics.logAppOpen();
        debugPrint('📊 [Analytics] 앱 시작 이벤트가 기록되었습니다.');
      }

      debugPrint('✅ [Analytics] 초기화 완료!');
    } catch (e, stackTrace) {
      debugPrint('❌ [Analytics] 초기화 실패: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  } else {
    debugPrint('⚠️ [Crashlytics] Firebase 초기화 실패로 건너뜁니다.');
    debugPrint('⚠️ [Analytics] Firebase 초기화 실패로 건너뜁니다.');
  }

  // ============================================================
  // 5. 로컬 알림 서비스 초기화
  // ============================================================
  LocalNotificationsService? localNotificationsService;
  try {
    debugPrint('🔔 [Local Notifications] 초기화 시작...');
    localNotificationsService = LocalNotificationsService.instance();
    await localNotificationsService.init();
    debugPrint('✅ [Local Notifications] 초기화 완료!');
  } catch (e, stackTrace) {
    debugPrint('❌ [Local Notifications] 초기화 실패: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // ============================================================
  // 6. FCM 서비스 초기화
  // ============================================================
  if (isFirebaseInitialized && localNotificationsService != null) {
    try {
      debugPrint('📱 [FCM] 초기화 시작...');
      await FirebaseMessagingService.instance().init(
        localNotificationsService: localNotificationsService,
      );
      debugPrint('✅ [FCM] 초기화 완료!');
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM] 초기화 실패: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  } else {
    if (!isFirebaseInitialized) {
      debugPrint('⚠️ [FCM] Firebase 초기화 실패로 건너뜁니다.');
    }
    if (localNotificationsService == null) {
      debugPrint('⚠️ [FCM] 로컬 알림 초기화 실패로 건너뜁니다.');
    }
  }

  // ============================================================
  // 7. SharedPreferences 초기화 (Todo 로컬 저장용)
  // ============================================================
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        localTodoDataSourceProvider.overrideWithValue(
          LocalTodoDataSource(prefs),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      // 디자인 기준 화면 크기 (iPhone 12/13/14 기준)
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp.router(
        title: '우주공부선',
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch_rounded, size: 20),
            const SizedBox(width: 8),
            const Text('우주공부선'),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '우주공부선',
              style: AppTextStyles.heading_20.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              '디자인을 시작해보세요!',
              style: AppTextStyles.paragraph_14.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
