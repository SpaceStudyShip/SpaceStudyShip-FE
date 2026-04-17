# Friend Detail D2 (원형 프로그레스) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 친구 상세 화면을 D2 디자인(원형 프로그레스 + 라이브 세션 강조)으로 전면 교체.

**Architecture:** `LiveSessionRing` 위젯 새로 만들고(CustomPaint), `friend_detail_screen.dart` body를 새로운 레이아웃으로 교체. private `_FriendAvatar` / `_StatusLine` 헬퍼로 헤더 행 구성, 통계는 `SpaceStatItem` 재사용. 응원 버튼은 `AppButton` + `AppSnackBar` mock. **TDD 사용 안 함** — 사용자 요청대로 위젯 코드만 작성, 테스트는 건너뜀.

**Tech Stack:** Flutter 3.9 · ScreenUtil · CustomPaint · 기존 `AppColors` / `AppTextStyles` / `AppSpacing` 상수

**Spec:** `docs/superpowers/specs/2026-04-14-friend-detail-d2-design.md`

---

## File Structure

### 신규 생성

| 파일 | 책임 |
|------|------|
| `lib/features/social/presentation/widgets/live_session_ring.dart` | 원형 프로그레스 + 중앙 LIVE / 시간 / 서브 텍스트. CustomPaint로 트랙·진행 아크 그림 |

### 수정

| 파일 | 변경 |
|------|------|
| `lib/features/social/presentation/screens/friend_detail_screen.dart` | body 전면 교체. private `_StatusBadge` / `_SubjectCard` / `_StatCard` 제거하고 `_FriendAvatar` / `_StatusLine` 신설. `LiveSessionRing` 사용. 응원 버튼 추가. 인라인 `TextStyle(fontSize:)` → `AppTextStyles` |

### 삭제

없음 (기존 파일들은 유지, 내부 private 클래스만 교체)

### 재사용 (변경 없이 import만)

- `lib/core/widgets/backgrounds/space_background.dart` — `SpaceBackground`
- `lib/core/widgets/atoms/space_stat_item.dart` — `SpaceStatItem` (`valueFirst: true` 모드)
- `lib/core/widgets/buttons/app_button.dart` — `AppButton` (응원 버튼)
- `lib/core/widgets/feedback/app_snackbar.dart` — `AppSnackBar.success`
- `lib/core/widgets/dialogs/app_dialog.dart` — `AppDialog.confirm` (기존 친구 삭제 흐름)

---

## Task 1: `LiveSessionRing` 위젯 신규 생성

원형 프로그레스 + 중앙 콘텐츠를 가진 단일 위젯. CustomPaint로 트랙과 진행 아크 그리고, 중앙에 Stack으로 라벨/시간/서브 텍스트 배치.

**Files:**
- Create: `lib/features/social/presentation/widgets/live_session_ring.dart`

- [ ] **Step 1: 위젯 파일 작성**

Create `lib/features/social/presentation/widgets/live_session_ring.dart`:

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 친구 상세 화면용 원형 라이브 세션 링
///
/// CustomPaint로 트랙(회색) + 진행 아크(상태 색)를 그리고,
/// 중앙에 라벨 / 시간 / 서브 텍스트를 Stack으로 올린다.
///
/// 진행률은 1시간(3600초)을 한 바퀴로 환산:
/// `(duration.inSeconds % 3600) / 3600`
///
/// 상태별:
/// - active=true → success 색 + 진행률 표시 + LIVE 라벨
/// - active=false → spaceDivider 색 + 진행률 0 + OFFLINE 라벨 + --:--
class LiveSessionRing extends StatelessWidget {
  const LiveSessionRing({
    super.key,
    required this.duration,
    required this.active,
    this.size = 200,
  });

  final Duration duration;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.spaceDivider;
    final progress =
        active ? (duration.inSeconds % 3600) / 3600 : 0.0;
    final widgetSize = size.w;

    return SizedBox(
      width: widgetSize,
      height: widgetSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widgetSize, widgetSize),
            painter: _RingPainter(
              progress: progress,
              progressColor: color,
              trackColor: AppColors.spaceDivider.withValues(alpha: 0.3),
              strokeWidth: 8.w,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                active ? 'LIVE' : 'OFFLINE',
                style: AppTextStyles.tag10Semibold.copyWith(
                  color: active
                      ? AppColors.textTertiary
                      : AppColors.textDisabled,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              Text(
                _formatTime(duration, active),
                style: AppTextStyles.timer_32.copyWith(color: color),
              ),
              SizedBox(height: AppSpacing.s4),
              Text(
                _formatSub(duration, active),
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d, bool active) {
    if (!active) return '--:--';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatSub(Duration d, bool active) {
    if (!active) return '집중 중이 아니에요';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}시간 ${m}분째 집중 중';
    return '${m}분째 집중 중';
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweep = 2 * pi * progress;
      const start = -pi / 2; // 12시 방향부터
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.progressColor != progressColor ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
```

- [ ] **Step 2: analyze 통과 확인**

Run:
```bash
flutter analyze lib/features/social/presentation/widgets/live_session_ring.dart
```

Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/features/social/presentation/widgets/live_session_ring.dart
git -c commit.gpgsign=false commit -m "feat : LiveSessionRing 친구 상세용 원형 라이브 세션 위젯 추가 #67"
```

---

## Task 2: `friend_detail_screen.dart` 전면 교체

private 클래스 정리 + 새 레이아웃 적용. 기존 친구 삭제 액션은 그대로 유지하고 body만 교체.

**Files:**
- Modify: `lib/features/social/presentation/screens/friend_detail_screen.dart` (전면 교체)

- [ ] **Step 1: 파일 전면 재작성**

Replace entire `lib/features/social/presentation/screens/friend_detail_screen.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../domain/entities/friend_entity.dart';
import '../widgets/live_session_ring.dart';

/// 친구 상세 화면 (D2 — 원형 프로그레스)
///
/// 구성: 헤더 행(아바타+이름+상태) → LiveSessionRing → 통계 2개 → 응원 버튼
class FriendDetailScreen extends StatelessWidget {
  const FriendDetailScreen({super.key, required this.friend});

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    final isStudying = friend.status == FriendStatus.studying;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            color: AppColors.textSecondary,
            onPressed: () => _showActionsSheet(context),
          ),
          SizedBox(width: AppSpacing.s4),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSpacing.s8),
                  _HeaderRow(friend: friend),
                  SizedBox(height: AppSpacing.s24),
                  Center(
                    child: LiveSessionRing(
                      duration: friend.studyDuration ?? Duration.zero,
                      active: isStudying,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          value: _formatDuration(
                            friend.weeklyStudyDuration ?? Duration.zero,
                          ),
                          label: '이번 주',
                        ),
                      ),
                      SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: _StatBox(
                          // TODO(#67): friend_entity에 streak 필드 추가 후 교체
                          value: '5일',
                          label: '연속 학습',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s16),
                  AppButton(
                    text: '응원 보내기',
                    onPressed: isStudying ? () => _onCheer(context) : null,
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.black,
                  ),
                  SizedBox(height: AppSpacing.s24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  void _onCheer(BuildContext context) {
    AppSnackBar.success(context, '${friend.name}님에게 응원을 보냈어요');
  }

  Future<void> _showActionsSheet(BuildContext context) async {
    final action = await showModalBottomSheet<_FriendAction>(
      context: context,
      backgroundColor: AppColors.spaceSurface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.modal),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.spaceDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSpacing.s12),
              ListTile(
                leading: Icon(
                  Icons.person_remove_outlined,
                  color: AppColors.error,
                ),
                title: Text(
                  '친구 삭제',
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, _FriendAction.delete),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted) return;
    if (action == _FriendAction.delete) {
      await _confirmDelete(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppDialog.confirm(
      context: context,
      title: '${friend.name}님을 친구에서 삭제할까요?',
      message: '삭제하면 우주선에서 내려요. 다시 추가하려면 친구 요청을 보내야 해요.',
      confirmText: '삭제',
      cancelText: '취소',
      isDestructive: true,
    );

    if (!context.mounted) return;
    if (ok == true) {
      Navigator.pop(context);
      AppSnackBar.success(context, '${friend.name}님을 삭제했어요');
    }
  }
}

enum _FriendAction { delete }

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.friend});

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    final isStudying = friend.status == FriendStatus.studying;
    final borderColor =
        isStudying ? AppColors.success : AppColors.spaceDivider;

    return Row(
      children: [
        _FriendAvatar(name: friend.name, borderColor: borderColor),
        SizedBox(width: AppSpacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.name,
                style: AppTextStyles.heading_20.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              _StatusLine(friend: friend),
            ],
          ),
        ),
      ],
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({required this.name, required this.borderColor});

  final String name;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : '?';
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.spaceElevated,
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.heading_24.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.friend});

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (friend.status) {
      FriendStatus.studying => (
        friend.currentSubject == null
            ? '지금 공부 중'
            : '지금 공부 중 · ${friend.currentSubject}',
        AppColors.success,
      ),
      FriendStatus.idle => ('대기 중', AppColors.textTertiary),
      FriendStatus.offline => ('오프라인', AppColors.textTertiary),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: AppSpacing.s4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.tag_12.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.spaceDivider),
      ),
      child: SpaceStatItem(
        value: value,
        label: label,
        valueFirst: true,
      ),
    );
  }
}
```

- [ ] **Step 2: analyze 통과 확인**

Run:
```bash
flutter analyze lib/features/social/
```

Expected: `No issues found!`

- [ ] **Step 3: hard-coded 검사**

Run:
```bash
grep -nE "fontSize:\s*\d+\.sp" lib/features/social/presentation/screens/friend_detail_screen.dart
grep -nE "Color\(0xFF" lib/features/social/presentation/screens/friend_detail_screen.dart
```

Expected: 둘 다 출력 없음 (모두 `AppTextStyles` / `AppColors`만 사용).

- [ ] **Step 4: 커밋**

```bash
git add lib/features/social/presentation/screens/friend_detail_screen.dart
git -c commit.gpgsign=false commit -m "feat : 친구 상세 화면 D2 디자인 (원형 라이브 세션 + 응원) 적용 #67"
```

---

## Task 3: 최종 검증

전체 social/ranking 빌드 + analyze + 기존 테스트 통과 확인.

**Files:** (read only)

- [ ] **Step 1: 전체 analyze**

Run:
```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: 기존 social 테스트 실행 (회귀 확인)**

Run:
```bash
flutter test test/features/social/
```

Expected: `All tests passed!` (기존 친구 상세 테스트가 새 레이아웃과 호환되는지 확인. 호환 안 되면 다음 단계로)

- [ ] **Step 3: 친구 상세 테스트 호환성 점검**

기존 `test/features/social/presentation/screens/friend_detail_screen_test.dart`에서 다음 위젯/텍스트가 더 이상 존재하지 않을 수 있다:
- "현재 과목" 라벨 (기존 `_SubjectCard` 안에 있던 것 — D2에선 헤더 status line으로 통합)
- "오늘 공부" 라벨 (기존 `_StatCard` 안의 라벨 — D2에선 LiveSessionRing이 대체)

확인:
```bash
grep -n "현재 과목\|오늘 공부" test/features/social/presentation/screens/friend_detail_screen_test.dart
```

만약 위 라벨을 검증하는 expect가 있고 Step 2에서 실패했다면 → 해당 expect를 D2 기준으로 갱신:
- `expect(find.text('현재 과목'), findsOneWidget)` → 삭제
- `expect(find.text('오늘 공부'), findsOneWidget)` → `expect(find.text('이번 주'), findsOneWidget)` 또는 `expect(find.byType(LiveSessionRing), findsOneWidget)` 로 교체
- "지금 공부 중"이 두 곳이 아니라 한 곳에서만 나오도록 검증

수정 후 재실행:
```bash
flutter test test/features/social/presentation/screens/friend_detail_screen_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 4: 테스트 변경이 있었으면 추가 커밋**

```bash
git add test/features/social/presentation/screens/friend_detail_screen_test.dart
git -c commit.gpgsign=false commit -m "test : 친구 상세 D2 레이아웃에 맞춰 검증 갱신 #67"
```

(Step 3에서 변경 없으면 이 단계 스킵)

---

## Self-Review

### 1. Spec 커버리지

| Spec 섹션 | 구현 위치 |
|----------|----------|
| 2.1 전체 레이아웃 | Task 2 (`FriendDetailScreen.build`) |
| 2.2 AppBar (back + more) | Task 2 (그대로 유지) |
| 2.3 헤더 행 (아바타 + 이름 + 상태) | Task 2 (`_HeaderRow` / `_FriendAvatar` / `_StatusLine`) |
| 2.4 원형 프로그레스 | Task 1 (`LiveSessionRing`) |
| 2.5 통계 2개 | Task 2 (`_StatBox` + `SpaceStatItem`) |
| 2.6 응원 버튼 | Task 2 (`AppButton` + `_onCheer`) |
| 3.1 신규 위젯 (`LiveSessionRing`) | Task 1 |
| 3.1 private 위젯 (`_FriendAvatar` / `_StatusLine`) | Task 2 |
| 3.3 재사용 (`SpaceBackground` / `SpaceStatItem` / `AppButton` / `AppSnackBar` / `AppDialog`) | Task 2 |
| 3.4 제거 (`_StatusBadge` / `_SubjectCard` / `_StatCard` / 인라인 fontSize) | Task 2 (전면 재작성으로 삭제) |
| 4. 데이터 바인딩 | Task 1 (LiveSessionRing) + Task 2 (`_HeaderRow`, `_StatBox`) |
| 5. 인터랙션 (back / more / 응원 / 응원 비활성) | Task 2 |
| 6. AppColors / AppTextStyles 매핑 | Task 1 + Task 2 (둘 다 상수만 사용) |
| 7. 엣지 케이스 (null duration, null subject, MM:SS vs HH:MM) | Task 1 (`_formatTime` / `_formatSub` / `active` 분기) |
| 8. In Scope 항목 전체 | Task 1, 2, 3 |

### 2. Placeholder 스캔

- 모든 step에 실제 코드 또는 실행 가능한 명령 포함됨
- "Similar to..." 사용 없음
- TBD/TODO 1개: `// TODO(#67): friend_entity에 streak 필드 추가 후 교체` — spec에서 명시한 의도적 mock
- "Similar to Task N" 없음
- 모든 file path는 절대/정확

### 3. 타입 일관성

- `LiveSessionRing` 시그니처: `({required Duration duration, required bool active, double size = 200})` — Task 1 정의, Task 2에서 동일하게 호출 ✓
- `_RingPainter` 필드: progress / progressColor / trackColor / strokeWidth — Task 1 내부 일관 ✓
- `FriendDetailScreen` 생성자: `({super.key, required FriendEntity friend})` — 기존과 동일 ✓
- `_FriendAvatar(name, borderColor)`, `_StatusLine(friend)`, `_StatBox(value, label)` — 모두 Task 2 안에서 정의 + 사용 ✓
- `SpaceStatItem(value, label, valueFirst: true)` — 기존 API와 일치 (확인 완료) ✓
- `AppButton(text, onPressed, backgroundColor, foregroundColor)` — 기존 API와 일치 ✓
- `AppSnackBar.success(context, message)` — 기존 API와 일치 ✓

타입 일관성 확인 완료.
