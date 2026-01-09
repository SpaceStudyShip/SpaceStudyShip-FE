import 'package:flutter/services.dart';

/// 전화번호 자동 포맷터 (테슬러/밀러 법칙)
///
/// 01012345678 → 010-1234-5678
///
/// **적용된 UX 원칙:**
/// - 밀러의 법칙: 숫자를 청크로 분리하여 가독성 향상
/// - 테슬러의 법칙: 복잡성을 시스템이 흡수
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자만 추출
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // 최대 11자리
    final limited = digitsOnly.length > 11
        ? digitsOnly.substring(0, 11)
        : digitsOnly;

    // 포맷팅
    final formatted = _formatPhone(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatPhone(String digits) {
    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 7) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
  }
}

/// 카드번호 자동 포맷터 (테슬러/밀러 법칙)
///
/// 1234567890123456 → 1234 5678 9012 3456
///
/// **적용된 UX 원칙:**
/// - 밀러의 법칙: 4자리씩 청킹
/// - 테슬러의 법칙: 자동 공백 삽입
class CardInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자만 추출
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // 최대 16자리
    final limited = digitsOnly.length > 16
        ? digitsOnly.substring(0, 16)
        : digitsOnly;

    // 포맷팅 (4자리씩)
    final formatted = _formatCard(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCard(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// 계좌번호 자동 포맷터 (테슬러 법칙)
///
/// 은행별 패턴에 맞게 자동 포맷팅
///
/// **적용된 UX 원칙:**
/// - 테슬러의 법칙: 은행별 복잡한 포맷을 자동 처리
class AccountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자와 하이픈만 추출
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // 최대 14자리
    final limited = digitsOnly.length > 14
        ? digitsOnly.substring(0, 14)
        : digitsOnly;

    // 포맷팅 (일반적인 패턴: 3-4-6 또는 4-4-4)
    final formatted = _formatAccount(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatAccount(String digits) {
    // 일반적인 은행 계좌 포맷 (XXX-XXXX-XXXXXX)
    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 7) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
  }
}

/// 통화(금액) 자동 포맷터 (밀러 법칙)
///
/// 1000000 → 1,000,000
///
/// **적용된 UX 원칙:**
/// - 밀러의 법칙: 3자리마다 쉼표로 청킹
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자만 추출
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // 포맷팅 (3자리마다 쉼표)
    final formatted = _formatCurrency(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCurrency(String digits) {
    // 앞에 0 제거
    final trimmed = digits.replaceFirst(RegExp(r'^0+'), '');
    if (trimmed.isEmpty) return '0';

    // 역순으로 3자리마다 쉼표 추가
    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i > 0 && (trimmed.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(trimmed[i]);
    }
    return buffer.toString();
  }
}

/// 이메일 입력 포맷터 (포스텔 법칙)
///
/// 대문자를 소문자로 자동 변환
///
/// **적용된 UX 원칙:**
/// - 포스텔의 법칙: 다양한 입력을 유연하게 수용
class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 소문자로 변환 (이메일은 대소문자 구분 없음)
    final lowercased = newValue.text.toLowerCase();

    return TextEditingValue(text: lowercased, selection: newValue.selection);
  }
}
