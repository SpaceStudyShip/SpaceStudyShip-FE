import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/constants/text_styles.dart';
import 'core/services/device/device_info_service.dart';
import 'core/services/device/device_id_manager.dart';

void main() async {
  // Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  debugPrint('🚀 [Firebase] 초기화 시작...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('✅ [Firebase] 초기화 완료!');

  // 기기 정보 출력
  debugPrint('📱 [Device] 기기 정보 수집 중...');
  final deviceName = await DeviceInfoService.getDeviceName();
  final deviceType = DeviceInfoService.getDeviceType();
  final osVersion = await DeviceInfoService.getOSVersion();
  final isPhysical = await DeviceInfoService.isPhysicalDevice();
  final deviceId = await DeviceIdManager.getOrCreateDeviceId();

  debugPrint('📱 [Device] 기기 이름: $deviceName');
  debugPrint('📱 [Device] 기기 타입: $deviceType');
  debugPrint('📱 [Device] OS 버전: $osVersion');
  debugPrint('📱 [Device] 실제 기기: ${isPhysical ? "예" : "아니오 (시뮬레이터/에뮬레이터)"}');
  debugPrint('📱 [Device] 기기 고유 ID: $deviceId');

  // FCM 권한 요청 및 토큰 발급
  final messaging = FirebaseMessaging.instance;

  // 1. 알림 권한 요청 (iOS 필수)
  debugPrint('📱 [FCM] 알림 권한 요청 중...');
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint('📱 [FCM] 알림 권한 상태: ${settings.authorizationStatus.name}');

  // 2. 권한이 승인된 경우에만 토큰 발급 시도
  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    try {
      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        debugPrint('✅ [FCM] 토큰 발급 성공!');
        debugPrint('🔑 [FCM Token] $fcmToken');
        debugPrint('📋 [FCM] 이 토큰을 백엔드 서버에 전송하세요.');
      } else {
        debugPrint('⚠️ [FCM] 토큰이 null입니다.');
        debugPrint('💡 [안내] iOS 시뮬레이터에서는 FCM 토큰을 발급받을 수 없습니다.');
        debugPrint('💡 [안내] 실제 iPhone/iPad에서 테스트해주세요.');
      }
    } catch (e) {
      debugPrint('❌ [FCM] 토큰 가져오기 실패: $e');
      if (e.toString().contains('apns-token-not-set')) {
        debugPrint('💡 [안내] APNS 토큰이 설정되지 않았습니다.');
        debugPrint('💡 [안내] iOS 시뮬레이터에서는 푸시 알림을 지원하지 않습니다.');
        debugPrint('💡 [안내] 실제 iOS 기기에서 테스트하거나 Android를 사용해주세요.');
      }
    }

    // FCM 토큰 갱신 리스너 등록 (권한이 있는 경우에만)
    messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 [FCM] 토큰 갱신됨!');
      debugPrint('🔑 [New FCM Token] $newToken');
      debugPrint('📋 [FCM] 갱신된 토큰을 백엔드 서버에 업데이트하세요.');
    });
  } else {
    debugPrint('⚠️ [FCM] 알림 권한이 거부되었습니다.');
    debugPrint('💡 [안내] 설정에서 알림 권한을 허용해주세요.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        title: 'Font Test',
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
