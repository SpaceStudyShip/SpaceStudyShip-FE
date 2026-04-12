import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/constants/space_icons.dart';
import 'package:space_study_ship/features/home/presentation/models/spaceship_data.dart';

void main() {
  group('SpaceshipData.sampleList', () {
    test('모든 샘플의 icon 값이 SpaceIcons.resolve 에서 placeholder 가 아님', () {
      for (final ship in SpaceshipData.sampleList) {
        final icon = SpaceIcons.resolve(ship.icon);
        expect(
          icon,
          isNot(Icons.help_outline_rounded),
          reason: 'Spaceship "${ship.id}" 의 icon "${ship.icon}" 이 매핑 실패',
        );
      }
    });

    test('모든 icon 값이 이모지가 아닌 String ID 임', () {
      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}\u{1F600}-\u{1F64F}\u{1FA00}-\u{1FAFF}]',
        unicode: true,
      );
      for (final ship in SpaceshipData.sampleList) {
        expect(
          emojiPattern.hasMatch(ship.icon),
          isFalse,
          reason: 'Spaceship "${ship.id}" 의 icon "${ship.icon}" 에 이모지가 남아있음',
        );
      }
    });
  });
}
