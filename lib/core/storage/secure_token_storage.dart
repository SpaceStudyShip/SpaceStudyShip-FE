import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'secure_token_storage.g.dart';

/// JWT 토큰 보안 저장소
///
/// flutter_secure_storage를 활용하여 Access Token과 Refresh Token을
/// 안전하게 저장합니다.
class SecureTokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  // ============================================
  // Storage Keys
  // ============================================

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _memberIdKey = 'member_id';
  static const String _isNewMemberKey = 'is_new_member';

  // ============================================
  // Token 저장
  // ============================================

  /// Access Token과 Refresh Token을 동시에 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    if (kDebugMode) {
      debugPrint('✅ 토큰 저장 완료 (accessToken length: ${accessToken.length})');
    }
  }

  /// Access Token만 저장
  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  /// Refresh Token만 저장
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// 회원 ID 저장 (백엔드 응답의 memberId)
  Future<void> saveMemberId(int memberId) async {
    await _storage.write(key: _memberIdKey, value: memberId.toString());
  }

  /// 신규 회원 여부 저장
  Future<void> saveIsNewMember(bool value) async {
    await _storage.write(key: _isNewMemberKey, value: value ? 'true' : 'false');
  }

  // ============================================
  // Token 조회
  // ============================================

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<int?> getMemberId() async {
    final value = await _storage.read(key: _memberIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  /// 신규 회원 여부 조회 (fail-safe: 값 없거나 'true' 아니면 false)
  Future<bool> getIsNewMember() async {
    final value = await _storage.read(key: _isNewMemberKey);
    return value == 'true';
  }

  // ============================================
  // Token 삭제
  // ============================================

  /// 모든 토큰 삭제 (로그아웃, 강제 로그아웃 시 호출)
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _memberIdKey),
      _storage.delete(key: _isNewMemberKey),
    ]);
    if (kDebugMode) {
      debugPrint('✅ 토큰 삭제 완료');
    }
  }

  /// 토큰 존재 여부 확인
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  // ============================================
  // 재설치 감지 및 Keychain 초기화 (iOS)
  // ============================================

  static const String _freshInstallKey = 'has_run_before';

  /// 앱 재설치 시 이전 토큰을 삭제
  ///
  /// iOS는 앱 삭제 후에도 Keychain 데이터가 남아있어
  /// 재설치 시 만료된 토큰으로 인증을 시도할 수 있음.
  /// SharedPreferences는 양 플랫폼 모두 앱 삭제 시 제거되므로
  /// 플래그 부재 = 신규 설치로 판단하여 토큰을 초기화.
  ///
  /// **반드시 main()에서 runApp() 전에 호출.**
  Future<void> clearTokensIfReinstalled() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRunBefore = prefs.getBool(_freshInstallKey) ?? false;

    if (!hasRunBefore) {
      await clearTokens();
      await prefs.setBool(_freshInstallKey, true);
      if (kDebugMode) {
        debugPrint('🔄 재설치 감지 — Keychain 토큰 초기화 완료');
      }
    }
  }
}

/// SecureTokenStorage Provider
///
/// 앱 생애주기 동안 유지 (keepAlive) — 인터셉터 콜백에서 안전하게 접근 가능
@Riverpod(keepAlive: true)
SecureTokenStorage secureTokenStorage(Ref ref) {
  return SecureTokenStorage();
}
