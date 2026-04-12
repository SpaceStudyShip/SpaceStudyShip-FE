import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/constants/space_icons.dart';

void main() {
  group('SpaceIcons.resolve', () {
    test('String ID 로 IconData 반환', () {
      expect(SpaceIcons.resolve(SpaceIcons.rocket), Icons.rocket_launch_rounded);
      expect(SpaceIcons.resolve(SpaceIcons.lock), Icons.lock_rounded);
      expect(SpaceIcons.resolve(SpaceIcons.trophy), Icons.emoji_events_rounded);
      expect(SpaceIcons.resolve(SpaceIcons.fuel), Icons.local_gas_station_rounded);
    });

    test('알 수 없는 키는 기본 placeholder 반환', () {
      expect(SpaceIcons.resolve('not_a_real_id'), Icons.help_outline_rounded);
      expect(SpaceIcons.resolve(''), Icons.help_outline_rounded);
    });

    test('레거시 이모지 키는 더 이상 매핑되지 않고 placeholder 반환', () {
      expect(SpaceIcons.resolve('\u{1F680}'), Icons.help_outline_rounded);
      expect(SpaceIcons.resolve('\u{1F512}'), Icons.help_outline_rounded);
    });
  });

  group('SpaceIcons.colorOf', () {
    test('행성 ID 로 고유 색상 반환', () {
      expect(SpaceIcons.colorOf(SpaceIcons.rocket), isA<Color>());
      expect(SpaceIcons.colorOf(SpaceIcons.star), isA<Color>());
    });
  });

  group('SpaceIcons.gradientOf', () {
    test('행성 ID 로 2색 그라데이션 반환', () {
      final gradient = SpaceIcons.gradientOf(SpaceIcons.rocket);
      expect(gradient, hasLength(2));
      expect(gradient, everyElement(isA<Color>()));
    });
  });

  group('SpaceIcons 상수', () {
    test('모든 public String 상수가 _idToIcon 맵에 존재', () {
      const ids = [
        SpaceIcons.rocket,
        SpaceIcons.ufo,
        SpaceIcons.satellite,
        SpaceIcons.helicopter,
        SpaceIcons.star,
        SpaceIcons.sparkleStar,
        SpaceIcons.sun,
        SpaceIcons.moon,
        SpaceIcons.galaxy,
        SpaceIcons.earth,
        SpaceIcons.planet,
        SpaceIcons.fuel,
        SpaceIcons.fire,
        SpaceIcons.lock,
        SpaceIcons.check,
        SpaceIcons.sparkle,
        SpaceIcons.trophy,
        SpaceIcons.astronaut,
        SpaceIcons.group,
        SpaceIcons.note,
        SpaceIcons.home,
        SpaceIcons.tool,
        SpaceIcons.footstep,
        SpaceIcons.book,
        SpaceIcons.telescope,
        SpaceIcons.sailboat,
        SpaceIcons.dizzy,
        SpaceIcons.target,
        SpaceIcons.airplane,
        SpaceIcons.goldMedal,
        SpaceIcons.medal,
        SpaceIcons.map,
        SpaceIcons.oilDrum,
        SpaceIcons.bolt,
        SpaceIcons.owl,
        SpaceIcons.bird,
      ];
      for (final id in ids) {
        expect(
          SpaceIcons.resolve(id),
          isNot(Icons.help_outline_rounded),
          reason: 'ID "$id" 가 _idToIcon 에서 매핑되지 않음',
        );
      }
    });
  });
}
