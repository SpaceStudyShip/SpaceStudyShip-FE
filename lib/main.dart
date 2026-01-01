import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'core/config/env_config.dart';
import 'core/constants/text_styles.dart';
import 'core/services/fcm/firebase_messaging_service.dart';
import 'core/services/fcm/local_notifications_service.dart';

void main() async {
  // Flutter 엔진 초기화 보장
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // 1. 환경 변수 초기화 (API URL, WebSocket URL 등)
  // 1. Initialize environment variables (API URL, WebSocket URL, etc.)
  // ============================================================
  await EnvConfig.initialize();

  // ============================================================
  // 2. 화면 방향을 세로 모드(정방향)로 고정
  // 2. Lock screen orientation to portrait mode only
  // ============================================================
  try {
    debugPrint('🔒 [Screen] 화면 방향 고정 시작...');
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    debugPrint('✅ [Screen] 화면 방향이 세로 모드로 고정되었습니다.');
  } catch (e, stackTrace) {
    debugPrint('❌ [Screen] 화면 방향 고정 실패: $e');
    debugPrint('Stack trace: $stackTrace');
    // 화면 방향 고정 실패는 치명적이지 않으므로 계속 진행
    // Screen orientation lock failure is not critical, continue execution
  }

  // ============================================================
  // 3. Firebase 초기화 (필수, 하지만 실패해도 앱 실행 가능)
  // 3. Initialize Firebase (required, but app can run without it)
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
    // Firebase 없이도 앱 실행 가능하도록 계속 진행
    // Continue execution even without Firebase
  }

  // ============================================================
  // 4. Crashlytics 설정 (Firebase 성공 시에만 실행)
  // 4. Initialize Crashlytics (only if Firebase initialized)
  // ============================================================
  if (isFirebaseInitialized) {
    try {
      debugPrint('🔧 [Crashlytics] 초기화 시작...');

      // 개발 모드에서는 Crashlytics 비활성화 (프로덕션에서만 수집)
      // Disable Crashlytics in debug mode (only collect in production)
      if (kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          false,
        );
        debugPrint('🔧 [Crashlytics] Debug 모드에서 비활성화되었습니다.');
      }

      // Flutter 프레임워크 에러 캡처 (위젯 빌드 에러 등)
      // Capture Flutter framework errors (widget build errors, etc.)
      FlutterError.onError = (errorDetails) {
        // 개발 모드: 콘솔에만 출력
        // Debug mode: Output to console only
        if (kDebugMode) {
          debugPrint('🔥 [Flutter Error] ${errorDetails.exception}');
          debugPrint('Stack trace: ${errorDetails.stack}');
        } else {
          // 프로덕션 모드: Crashlytics에 전송
          // Production mode: Send to Crashlytics
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        }
      };

      // 비동기 에러 캡처 (Future, Stream 에러 등)
      // Capture asynchronous errors (Future, Stream errors, etc.)
      PlatformDispatcher.instance.onError = (error, stack) {
        // 개발 모드: 콘솔에만 출력
        // Debug mode: Output to console only
        if (kDebugMode) {
          debugPrint('🔥 [Async Error] $error');
          debugPrint('Stack trace: $stack');
        } else {
          // 프로덕션 모드: Crashlytics에 전송
          // Production mode: Send to Crashlytics
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      debugPrint('✅ [Crashlytics] 초기화 완료! 에러 추적이 활성화되었습니다.');
    } catch (e, stackTrace) {
      debugPrint('❌ [Crashlytics] 초기화 실패: $e');
      debugPrint('Stack trace: $stackTrace');
      // Crashlytics 실패해도 앱은 계속 실행
      // Continue execution even if Crashlytics fails
    }

    // ============================================================
    // 4-1. Firebase Analytics 초기화
    // 4-1. Initialize Firebase Analytics
    // ============================================================
    try {
      debugPrint('📊 [Analytics] 초기화 시작...');

      final analytics = FirebaseAnalytics.instance;

      // 개발 모드에서는 Analytics 비활성화 (프로덕션에서만 수집)
      // Disable Analytics in debug mode (only collect in production)
      if (kDebugMode) {
        await analytics.setAnalyticsCollectionEnabled(false);
        debugPrint('📊 [Analytics] Debug 모드에서 비활성화되었습니다.');
      } else {
        await analytics.setAnalyticsCollectionEnabled(true);

        // 앱 시작 이벤트 로깅
        // Log app start event
        await analytics.logAppOpen();
        debugPrint('📊 [Analytics] 앱 시작 이벤트가 기록되었습니다.');
      }

      debugPrint('✅ [Analytics] 초기화 완료! 사용자 행동 추적이 활성화되었습니다.');
    } catch (e, stackTrace) {
      debugPrint('❌ [Analytics] 초기화 실패: $e');
      debugPrint('Stack trace: $stackTrace');
      // Analytics 실패해도 앱은 계속 실행
      // Continue execution even if Analytics fails
    }
  } else {
    debugPrint('⚠️ [Crashlytics] Firebase 초기화 실패로 건너뜁니다.');
    debugPrint('⚠️ [Analytics] Firebase 초기화 실패로 건너뜁니다.');
  }

  // ============================================================
  // 5. 로컬 알림 서비스 초기화 (Firebase와 독립적)
  // 5. Initialize local notifications (independent from Firebase)
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
    // 실패해도 계속 진행 (푸시 알림 없이 앱 사용 가능)
    // Continue execution (app works without push notifications)
  }

  // ============================================================
  // 6. FCM 서비스 초기화 (Firebase + 로컬 알림 필요)
  // 6. Initialize FCM (requires Firebase + Local notifications)
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
      // FCM 실패해도 앱은 계속 실행 (원격 푸시 없이 사용 가능)
      // Continue execution (app works without remote push)
    }
  } else {
    if (!isFirebaseInitialized) {
      debugPrint('⚠️ [FCM] Firebase 초기화 실패로 건너뜁니다.');
    }
    if (localNotificationsService == null) {
      debugPrint('⚠️ [FCM] 로컬 알림 초기화 실패로 건너뜁니다.');
    }
  }

  runApp(MyApp(isFirebaseInitialized: isFirebaseInitialized));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.isFirebaseInitialized = true});

  final bool isFirebaseInitialized;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 디자인 기준 화면 크기 (iPhone 12/13/14 기준)
      // Base design screen size (iPhone 12/13/14)
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        title: 'Space Study Ship',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const FontTestPage(),
      ),
    );
  }
}

class FontTestPage extends StatelessWidget {
  const FontTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Pretendard 폰트 테스트', style: AppTextStyles.heading4.bold()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Heading 1', style: AppTextStyles.heading1),
            Text('Heading 2', style: AppTextStyles.heading2),
            Text('Heading 3', style: AppTextStyles.heading3),
            Text('Heading 4', style: AppTextStyles.heading4),
            SizedBox(height: 20.h),
            Text('Body 1', style: AppTextStyles.body1),
            Text('Body 2', style: AppTextStyles.body2),
            SizedBox(height: 20.h),
            Text('Caption', style: AppTextStyles.caption),
            Text('Overline', style: AppTextStyles.overline),
            SizedBox(height: 30.h),
            Text('Weight 테스트:', style: AppTextStyles.heading4.bold()),
            SizedBox(height: 10.h),
            Text('Thin (100)', style: AppTextStyles.body1.thin()),
            Text('ExtraLight (200)', style: AppTextStyles.body1.extraLight()),
            Text('Light (300)', style: AppTextStyles.body1.light()),
            Text('Regular (400)', style: AppTextStyles.body1.regular()),
            Text('Medium (500)', style: AppTextStyles.body1.medium()),
            Text('SemiBold (600)', style: AppTextStyles.body1.semiBold()),
            Text('Bold (700)', style: AppTextStyles.body1.bold()),
            Text('ExtraBold (800)', style: AppTextStyles.body1.extraBold()),
            Text('Black (900)', style: AppTextStyles.body1.black()),
          ],
        ),
      ),
    );
  }
}
