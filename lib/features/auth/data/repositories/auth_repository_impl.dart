import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/services/device/device_id_manager.dart';
import '../../../../core/services/device/device_info_service.dart';
import '../../../../core/services/fcm/firebase_messaging_service.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/check_nickname_response_model.dart';
import '../models/login_request_model.dart';
import '../models/logout_request_model.dart';
import '../models/update_nickname_request_model.dart';

/// Auth Repository 구현체
///
/// Firebase Auth + 백엔드 API를 조합하여 인증 흐름을 처리합니다.
///
/// **로그인 흐름**:
/// 1. Firebase 소셜 로그인 (Google/Apple)
/// 2. Firebase ID Token 획득
/// 3. 백엔드 `/api/auth/login` 호출
/// 4. JWT 토큰을 SecureStorage에 저장
/// 5. AuthResultEntity 반환 (memberId, nickname, isNewMember)
///
/// **로그아웃 흐름**:
/// 1. 백엔드 `/api/auth/logout` 호출 (refreshToken 전달)
/// 2. Firebase 로그아웃 (Google/Apple 세션 정리)
/// 3. SecureStorage에서 토큰 삭제
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;
  final AuthRemoteDataSource _authRemoteDataSource;
  final SecureTokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource firebaseAuthDataSource,
    required AuthRemoteDataSource authRemoteDataSource,
    required SecureTokenStorage tokenStorage,
  }) : _firebaseAuthDataSource = firebaseAuthDataSource,
       _authRemoteDataSource = authRemoteDataSource,
       _tokenStorage = tokenStorage;

  // ============================================
  // 소셜 로그인
  // ============================================

  @override
  Future<AuthResultEntity> signInWithGoogle() async {
    return _performSocialLogin(
      socialType: 'GOOGLE',
      firebaseSignIn: () => _firebaseAuthDataSource.signInWithGoogle(),
    );
  }

  @override
  Future<AuthResultEntity> signInWithApple() async {
    return _performSocialLogin(
      socialType: 'APPLE',
      firebaseSignIn: () => _firebaseAuthDataSource.signInWithApple(),
    );
  }

  /// 소셜 로그인 공통 로직
  ///
  /// Firebase 로그인 → ID Token 획득 → 백엔드 로그인 → 토큰 저장
  Future<AuthResultEntity> _performSocialLogin({
    required String socialType,
    required Future<dynamic> Function() firebaseSignIn,
  }) async {
    try {
      // 1. Firebase 소셜 로그인
      await firebaseSignIn();

      // 2. Firebase ID Token 획득
      final idToken = await _firebaseAuthDataSource.getIdToken();

      // 3. 백엔드 로그인 API 호출
      final deviceInfo = await _collectDeviceInfo();
      final response = await _authRemoteDataSource.login(
        LoginRequestModel(
          socialType: socialType,
          idToken: idToken,
          fcmToken: deviceInfo.fcmToken,
          deviceType: deviceInfo.deviceType,
          deviceId: deviceInfo.deviceId,
        ),
      );

      // 4. JWT 토큰 + 메타정보 저장 (부분 실패 시 전체 롤백)
      try {
        await _tokenStorage.saveTokens(
          accessToken: response.tokens.accessToken,
          refreshToken: response.tokens.refreshToken,
        );
        await _tokenStorage.saveMemberId(response.memberId);
        await _tokenStorage.saveIsNewMember(response.isNewMember);
      } catch (e) {
        // 저장 도중 실패 → 로컬 토큰/Firebase 세션 함께 정리 (반쯤 인증 상태 방지)
        debugPrint('❌ 토큰 저장 실패 - 롤백 진행: $e');
        try {
          await _tokenStorage.clearTokens();
        } catch (_) {}
        await _cleanupFirebaseSession(socialType);
        throw AuthException(
          message: '로그인 정보 저장에 실패했습니다.',
          originalException: e,
        );
      }

      if (kDebugMode) {
        debugPrint('✅ 백엔드 로그인 성공 ($socialType)');
        debugPrint('   memberId: ${response.memberId}');
        debugPrint('   nickname: ${response.nickname}');
        debugPrint('   isNewMember: ${response.isNewMember}');
      }

      return AuthResultEntity(
        memberId: response.memberId,
        nickname: response.nickname,
        isNewMember: response.isNewMember,
      );
    } on DioException catch (e) {
      // 백엔드 호출 실패 → Firebase 세션 정리 (재로그인 가능 상태로)
      await _cleanupFirebaseSession(socialType);
      throw DioExceptionHandler.handle(e);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'ERROR_ABORTED_BY_USER') {
        throw const AuthCancelledException();
      }
      // FirebaseAuthException은 AuthNotifier에서 FirebaseAuthErrorHandler로 처리
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(message: '로그인 중 오류가 발생했습니다.', originalException: e);
    }
  }

  // ============================================
  // 로그아웃
  // ============================================

  @override
  Future<void> signOut() async {
    try {
      // 1. 백엔드 로그아웃 (refreshToken 전달)
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          await _authRemoteDataSource.logout(
            LogoutRequestModel(refreshToken: refreshToken),
          );
          if (kDebugMode) {
            debugPrint('✅ 백엔드 로그아웃 성공');
          }
        } catch (e) {
          // 백엔드 로그아웃 실패해도 로컬 정리는 계속 진행
          debugPrint('⚠️ 백엔드 로그아웃 실패 (무시하고 계속 진행): $e');
        }
      }

      // 2. Firebase 로그아웃 (Google/Apple 세션 정리)
      await _firebaseAuthDataSource.signOut();

      // 3. 로컬 토큰 삭제
      await _tokenStorage.clearTokens();

      if (kDebugMode) {
        debugPrint('✅ 로그아웃 완료 (백엔드 + Firebase + 토큰 삭제)');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(message: '로그아웃 중 오류가 발생했습니다.', originalException: e);
    }
  }

  // ============================================
  // 닉네임
  // ============================================

  @override
  Future<String> updateNickname(String nickname) async {
    try {
      final response = await _authRemoteDataSource.updateNickname(
        UpdateNicknameRequestModel(nickname: nickname),
      );
      if (kDebugMode) {
        debugPrint('닉네임 변경 성공: ${response.nickname}');
      }
      return response.nickname;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(
          message: '닉네임 변경 중 오류가 발생했습니다.', originalException: e);
    }
  }

  @override
  Future<bool> checkNickname(String nickname) async {
    try {
      final CheckNicknameResponseModel response =
          await _authRemoteDataSource.checkNickname(nickname);
      return response.available;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(
          message: '닉네임 중복 확인 중 오류가 발생했습니다.', originalException: e);
    }
  }

  // ============================================
  // 회원 탈퇴
  // ============================================

  @override
  Future<void> withdraw() async {
    try {
      await _authRemoteDataSource.withdraw();

      // 204 성공 시에만 도달.
      // 멱등 보장: Firebase signOut 실패도 무시하고 토큰 삭제는 진행.
      try {
        await _firebaseAuthDataSource.signOut();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('withdraw 후 Firebase signOut 실패 (무시): $e');
        }
      }
      await _tokenStorage.clearTokens();

      if (kDebugMode) {
        debugPrint('회원 탈퇴 완료 (백엔드 + Firebase + 토큰 삭제)');
      }
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(
          message: '회원 탈퇴 중 오류가 발생했습니다.', originalException: e);
    }
  }

  // ============================================
  // Private Helpers
  // ============================================

  /// 디바이스 메타 정보 수집 (fcmToken / deviceType / deviceId)
  ///
  /// `docs/api-docs.json` LoginRequest 의 3 필드를 채우기 위해 사용.
  /// FCM 토큰 발급 실패 시 빈 문자열로 fallback (백엔드가 `minLength: 0` 허용).
  Future<({String fcmToken, String deviceType, String deviceId})>
  _collectDeviceInfo() async {
    final fcmToken =
        (await FirebaseMessagingService.instance().getFcmToken()) ?? '';
    final deviceType = DeviceInfoService.getDeviceType();
    final deviceId = await DeviceIdManager.getOrCreateDeviceId();

    if (kDebugMode) {
      debugPrint(
        'LoginRequest device info — '
        'type=$deviceType, id=$deviceId, fcmEmpty=${fcmToken.isEmpty}',
      );
    }

    return (fcmToken: fcmToken, deviceType: deviceType, deviceId: deviceId);
  }

  /// Firebase 세션 정리 (백엔드 호출 실패 시)
  Future<void> _cleanupFirebaseSession(String socialType) async {
    try {
      await _firebaseAuthDataSource.signOut();
      debugPrint('🔄 백엔드 로그인 실패 - Firebase 세션 정리 완료 ($socialType)');
    } catch (e) {
      debugPrint('⚠️ Firebase 세션 정리 중 에러 (무시): $e');
    }
  }
}
