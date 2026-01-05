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
import 'core/theme/app_theme.dart';
import 'core/services/fcm/firebase_messaging_service.dart';
import 'core/services/fcm/local_notifications_service.dart';
import 'core/constants/spacing_and_radius.dart';
import 'core/widgets/widgets.dart';

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
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        title: '우주공부선',
        theme: AppTheme.spaceTheme,
        themeMode: ThemeMode.dark, // 항상 다크 모드 (우주 테마)
        home: const WidgetTestPage(),
      ),
    );
  }
}

class WidgetTestPage extends StatelessWidget {
  const WidgetTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🚀 우주공부선 위젯', style: AppTextStyles.heading4.bold()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 버튼 섹션
            Text('Buttons', style: AppTextStyles.heading3.bold()),
            SizedBox(height: 16.h),
            SpaceButton(
              text: 'Primary Button',
              onPressed: () {
                SpaceSnackBar.success(context, '버튼 클릭!');
              },
            ),
            SizedBox(height: 12.h),
            SpaceButton(
              text: 'Secondary Button',
              type: SpaceButtonType.secondary,
              onPressed: () {
                SpaceSnackBar.info(context, 'Secondary 버튼!');
              },
            ),
            SizedBox(height: 12.h),
            SpaceButton(
              text: '삭제하기',
              type: SpaceButtonType.destructive,
              icon: Icons.delete,
              onPressed: () {
                SpaceSnackBar.warning(context, 'Destructive 버튼!');
              },
            ),
            SizedBox(height: 12.h),
            SpaceButton(
              text: '로딩 중...',
              onPressed: () {},
              isLoading: true,
            ),
            SizedBox(height: 12.h),
            const SpaceButton(text: '비활성 버튼', onPressed: null),
            SizedBox(height: 32.h),

            // 입력 필드 섹션
            Text('Text Fields', style: AppTextStyles.heading3.bold()),
            SizedBox(height: 16.h),
            const SpaceTextField(
              hintText: '이름',
              prefixIcon: Icons.person,
            ),
            SizedBox(height: 12.h),
            const SpaceTextField(
              hintText: '휴대폰 번호',
              prefixIcon: Icons.phone,
              autoFormat: SpaceInputFormat.phone,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12.h),
            const SpaceTextField(
              hintText: '금액',
              prefixIcon: Icons.attach_money,
              autoFormat: SpaceInputFormat.currency,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.h),
            const SpaceTextField(
              hintText: '비밀번호',
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 12.h),
            const SpaceTextField(hintText: '에러 상태', errorText: '올바른 값을 입력해 주세요'),
            SizedBox(height: 32.h),

            // 카드 섹션
            Text('Cards', style: AppTextStyles.heading3.bold()),
            SizedBox(height: 16.h),
            SpaceCard(
              padding: AppPadding.all16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Elevated 카드', style: AppTextStyles.heading4.bold()),
                  SizedBox(height: 8.h),
                  Text(
                    '그림자가 있는 기본 카드 스타일이에요.',
                    style: AppTextStyles.body2.regular(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            SpaceCard(
              style: SpaceCardStyle.outlined,
              padding: AppPadding.all16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outlined 카드', style: AppTextStyles.heading4.bold()),
                  SizedBox(height: 8.h),
                  Text(
                    '테두리만 있는 카드 스타일이에요.',
                    style: AppTextStyles.body2.regular(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            SpaceCard(
              padding: AppPadding.all16,
              isSelected: true,
              onTap: () {
                SpaceSnackBar.info(context, '카드 클릭!');
              },
              child: Row(
                children: [
                  const Icon(Icons.touch_app, size: 40),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선택된 카드',
                          style: AppTextStyles.body1.semiBold(),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '탭하면 애니메이션이 적용돼요',
                          style: AppTextStyles.caption.regular(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // 로딩 인디케이터 섹션
            Text('Loading & Skeleton', style: AppTextStyles.heading3.bold()),
            SizedBox(height: 16.h),
            SpaceCard(
              padding: AppPadding.all24,
              child: const SpaceLoading(message: '불러오는 중...'),
            ),
            SizedBox(height: 12.h),
            SpaceCard(
              padding: AppPadding.all24,
              child: const SpaceLoading(
                type: SpaceLoadingType.dots,
                message: '처리 중...',
              ),
            ),
            SizedBox(height: 12.h),
            SpaceCard(
              padding: AppPadding.all16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Skeleton UI', style: AppTextStyles.body1.semiBold()),
                  SizedBox(height: 12.h),
                  SpaceSkeleton.listTile(),
                  SizedBox(height: 8.h),
                  SpaceSkeleton.listTile(),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // 다이얼로그 섹션
            Text('Dialogs', style: AppTextStyles.heading3.bold()),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                SpaceButton(
                  text: '기본',
                  size: SpaceButtonSize.small,
                  onPressed: () {
                    SpaceDialog.show(
                      context: context,
                      title: '저장할까요?',
                      message: '변경사항이 저장돼요',
                      confirmText: '저장',
                      cancelText: '취소',
                    );
                  },
                ),
                SpaceButton(
                  text: '성공',
                  size: SpaceButtonSize.small,
                  onPressed: () {
                    SpaceDialog.show(
                      context: context,
                      title: '저장했어요!',
                      message: '변경사항이 성공적으로 저장됐어요.',
                      emotion: SpaceDialogEmotion.success,
                      confirmText: '확인',
                    );
                  },
                ),
                SpaceButton(
                  text: '경고',
                  size: SpaceButtonSize.small,
                  type: SpaceButtonType.secondary,
                  onPressed: () {
                    SpaceDialog.show(
                      context: context,
                      title: '삭제할까요?',
                      message: '삭제하면 되돌릴 수 없어요',
                      emotion: SpaceDialogEmotion.warning,
                      confirmText: '삭제',
                      cancelText: '취소',
                      confirmButtonType: SpaceButtonType.destructive,
                    );
                  },
                ),
                SpaceButton(
                  text: '에러',
                  size: SpaceButtonSize.small,
                  type: SpaceButtonType.destructive,
                  onPressed: () {
                    SpaceDialog.show(
                      context: context,
                      title: '오류가 발생했어요',
                      message: '네트워크 연결을 확인해 주세요',
                      emotion: SpaceDialogEmotion.error,
                      confirmText: '다시 시도',
                      cancelText: '취소',
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // SnackBar 섹션
            Text('SnackBars', style: AppTextStyles.heading3.bold()),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                SpaceButton(
                  text: 'Success',
                  size: SpaceButtonSize.small,
                  onPressed: () {
                    SpaceSnackBar.success(context, '저장했어요!');
                  },
                ),
                SpaceButton(
                  text: 'Error',
                  size: SpaceButtonSize.small,
                  type: SpaceButtonType.destructive,
                  onPressed: () {
                    SpaceSnackBar.error(context, '저장에 실패했어요');
                  },
                ),
                SpaceButton(
                  text: 'Info',
                  size: SpaceButtonSize.small,
                  type: SpaceButtonType.secondary,
                  onPressed: () {
                    SpaceSnackBar.info(context, '새로운 업데이트가 있어요');
                  },
                ),
                SpaceButton(
                  text: 'Warning',
                  size: SpaceButtonSize.small,
                  type: SpaceButtonType.secondary,
                  onPressed: () {
                    SpaceSnackBar.warning(context, '입력값을 확인해 주세요');
                  },
                ),
                SpaceButton(
                  text: 'Undo',
                  size: SpaceButtonSize.small,
                  type: SpaceButtonType.text,
                  onPressed: () {
                    SpaceSnackBar.showWithUndo(
                      context: context,
                      message: '삭제했어요',
                      onUndo: () {
                        SpaceSnackBar.success(context, '복구했어요!');
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // 빈 상태 섹션
            Text('Empty State', style: AppTextStyles.heading3.bold()),
            SizedBox(height: 16.h),
            SpaceCard(
              style: SpaceCardStyle.outlined,
              padding: AppPadding.all16,
              child: SpaceEmptyState(
                icon: Icons.inbox,
                title: '아직 할 일이 없어요',
                description: '첫 번째 할 일을 만들어볼까요?',
                actionText: '할 일 만들기',
                onAction: () {
                  SpaceSnackBar.success(context, '할 일 추가!');
                },
              ),
            ),
            SizedBox(height: 12.h),
            SpaceCard(
              style: SpaceCardStyle.outlined,
              padding: AppPadding.all16,
              child: SpaceEmptyState(
                type: SpaceEmptyType.noSearch,
                icon: Icons.search_off,
                title: '검색 결과가 없어요',
                description: '다른 검색어로 찾아볼까요?',
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
