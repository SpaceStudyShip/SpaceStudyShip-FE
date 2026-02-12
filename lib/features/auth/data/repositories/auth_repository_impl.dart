// TODO: 백엔드 API 연동 시 아래 주석 해제
// ignore_for_file: unused_import, unused_field
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../../auth/data/datasources/firebase_auth_datasource.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/logout_request_model.dart';
import '../../../../core/services/device/device_id_manager.dart';

/// Auth Repository 구현체
///
/// Firebase Auth + 백엔드 API를 조합하여 인증 흐름을 처리합니다.
///
/// **로그인 흐름**:
/// 1. Firebase 소셜 로그인 (Google/Apple)
/// 2. Firebase ID Token 획득
/// 3. 백엔드 `/api/auth/login` 호출
/// 4. JWT 토큰을 SecureStorage에 저장
/// 5. AuthResultEntity 반환 (nickname, isNewUser)
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
      provider: 'GOOGLE',
      firebaseSignIn: () => _firebaseAuthDataSource.signInWithGoogle(),
    );
  }

  @override
  Future<AuthResultEntity> signInWithApple() async {
    return _performSocialLogin(
      provider: 'APPLE',
      firebaseSignIn: () => _firebaseAuthDataSource.signInWithApple(),
    );
  }

  /// 소셜 로그인 공통 로직
  ///
  /// Firebase 로그인 → ID Token 획득 → 백엔드 로그인 → 토큰 저장
  Future<AuthResultEntity> _performSocialLogin({
    required String provider,
    required Future<dynamic> Function() firebaseSignIn,
  }) async {
    try {
      // 1. Firebase 소셜 로그인
      await firebaseSignIn();

      // ── Firebase-only 모드 ──
      // 백엔드 API 연동 전까지 Firebase 사용자 정보만 사용
      final user = _firebaseAuthDataSource.currentUser;

      if (kDebugMode) {
        debugPrint('✅ Firebase 로그인 성공 ($provider)');
        debugPrint('   email: ${user?.email}');
        debugPrint('   displayName: ${user?.displayName}');
      }

      return AuthResultEntity(
        userId: 0, // 백엔드 연동 전 임시값
        nickname: user?.displayName ?? '',
        isNewUser: false,
      );

      // TODO: 백엔드 API 연동 시 위 return 블록 삭제 후 아래 주석 해제
      // ──────────────────────────────────────────────
      // // 2. Firebase ID Token 획득
      // final idToken = await _firebaseAuthDataSource.getIdToken();
      //
      // // 3. FCM Token 및 Device ID 획득
      // String fcmToken = '';
      // try {
      //   fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      // } catch (e) {
      //   if (kDebugMode) {
      //     debugPrint('⚠️ FCM 토큰 획득 실패 (에뮬레이터일 수 있음): $e');
      //   }
      // }
      // final deviceId = await DeviceIdManager.getOrCreateDeviceId();
      // final deviceType = Platform.isIOS ? 'IOS' : 'ANDROID';
      //
      // // 4. 백엔드 로그인 API 호출
      // final response = await _authRemoteDataSource.login(
      //   LoginRequestModel(
      //     socialPlatform: provider,
      //     idToken: idToken,
      //     fcmToken: fcmToken,
      //     deviceType: deviceType,
      //     deviceId: deviceId,
      //   ),
      // );
      //
      // // 5. JWT 토큰 + userId 저장
      // await _tokenStorage.saveTokens(
      //   accessToken: response.tokens.accessToken,
      //   refreshToken: response.tokens.refreshToken,
      // );
      // await _tokenStorage.saveUserId(response.userId);
      //
      // if (kDebugMode) {
      //   debugPrint('✅ 백엔드 로그인 성공 ($provider)');
      //   debugPrint('   userId: ${response.userId}');
      //   debugPrint('   nickname: ${response.nickname}');
      //   debugPrint('   isNewUser: ${response.isNewUser}');
      // }
      //
      // // 6. Domain Entity로 변환하여 반환
      // return AuthResultEntity(
      //   userId: response.userId,
      //   nickname: response.nickname,
      //   isNewUser: response.isNewUser,
      // );
      // ──────────────────────────────────────────────
    } on DioException catch (e) {
      // TODO: 백엔드 API 연동 시 사용
      await _cleanupFirebaseSession(provider);
      throw DioExceptionHandler.handle(e);
    } on FirebaseAuthException {
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
      // TODO: 백엔드 API 연동 시 아래 주석 해제
      // ──────────────────────────────────────────────
      // final refreshToken = await _tokenStorage.getRefreshToken();
      // if (refreshToken != null) {
      //   try {
      //     await _authRemoteDataSource.logout(
      //       LogoutRequestModel(refreshToken: refreshToken),
      //     );
      //     if (kDebugMode) {
      //       debugPrint('✅ 백엔드 로그아웃 성공');
      //     }
      //   } catch (e) {
      //     debugPrint('⚠️ 백엔드 로그아웃 실패 (무시하고 계속 진행): $e');
      //   }
      // }
      // ──────────────────────────────────────────────

      // Firebase 로그아웃 (Google/Apple 세션 정리)
      await _firebaseAuthDataSource.signOut();

      // 로컬 토큰 삭제
      await _tokenStorage.clearTokens();

      if (kDebugMode) {
        debugPrint('✅ 로그아웃 완료 (Firebase + 토큰 삭제)');
      }
    } catch (e) {
      if (e is AppException) rethrow;

      throw AuthException(message: '로그아웃 중 오류가 발생했습니다.', originalException: e);
    }
  }

  // ============================================
  // Private Helpers
  // ============================================

  /// Firebase 세션 정리 (백엔드 호출 실패 시)
  Future<void> _cleanupFirebaseSession(String provider) async {
    try {
      await _firebaseAuthDataSource.signOut();
      debugPrint('🔄 백엔드 로그인 실패 - Firebase 세션 정리 완료 ($provider)');
    } catch (e) {
      debugPrint('⚠️ Firebase 세션 정리 중 에러 (무시): $e');
    }
  }
}
