import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/constants/space_icons.dart';
import 'package:space_study_ship/features/badge/data/seed/badge_seed_data.dart';

void main() {
  group('BadgeSeedData.allBadges', () {
    test('25개 이상의 뱃지가 정의됨', () {
      expect(BadgeSeedData.allBadges.length, greaterThanOrEqualTo(25));
    });

    test('모든 뱃지 id 가 고유함', () {
      final ids = BadgeSeedData.allBadges.map((b) => b.id).toList();
      final unique = ids.toSet();
      expect(unique.length, ids.length, reason: '중복 id 존재');
    });

    test('모든 뱃지 icon 값이 SpaceIcons.resolve 에서 placeholder 가 아님', () {
      for (final badge in BadgeSeedData.allBadges) {
        final icon = SpaceIcons.resolve(badge.icon);
        expect(
          icon,
          isNot(Icons.help_outline_rounded),
          reason: 'Badge "${badge.id}" 의 icon "${badge.icon}" 이 매핑 실패',
        );
      }
    });

    test('모든 icon 값이 이모지가 아닌 String ID 임', () {
      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}\u{1F600}-\u{1F64F}\u{1FA00}-\u{1FAFF}]',
        unicode: true,
      );
      for (final badge in BadgeSeedData.allBadges) {
        expect(
          emojiPattern.hasMatch(badge.icon),
          isFalse,
          reason: 'Badge "${badge.id}" 의 icon "${badge.icon}" 에 이모지가 남아있음',
        );
      }
    });
  });
}
