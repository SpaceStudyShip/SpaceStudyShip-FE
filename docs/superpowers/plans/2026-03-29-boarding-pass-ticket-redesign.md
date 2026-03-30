# 지역 상세 화면 — 탑승권 티켓 리디자인 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** location_detail_screen.dart의 2x2 정보 그리드 + 해금 버튼을 우주 탑승권(boarding pass) 티켓 UI로 전면 리디자인. 하단 점선 스와이프로 찢어서 해금 + 상단 펀치 자국 표시.

**Architecture:** 기존 `_buildInfoGrid` + `_buildBottomBar`를 하나의 `BoardingPassTicket` 위젯으로 교체. 티켓은 상단 본체(정보 영역)와 하단 stub(찢기 영역)으로 구성. `TicketTearInteraction` 위젯이 스와이프 제스처 + 찢기 애니메이션을 담당. `TicketPunchClipper`(CustomClipper)가 해금 후 상단 펀치 자국을 표현.

**Tech Stack:** Flutter CustomClipper, GestureDetector, AnimationController, CustomPainter (점선), 기존 디자인 시스템 (AppColors, AppSpacing, AppTextStyles, TossDesignTokens)

---

## File Structure

```
lib/features/exploration/presentation/
├── widgets/
│   ├── boarding_pass_ticket.dart        ← [NEW] 티켓 전체 컴포지션 위젯
│   ├── ticket_punch_clipper.dart        ← [NEW] 펀치 자국 CustomClipper
│   ├── ticket_tear_interaction.dart     ← [NEW] 하단 스와이프 찢기 인터랙션
│   ├── ticket_dashed_line.dart          ← [NEW] 점선 구분선 CustomPainter
│   └── region_flag_icon.dart            (기존 유지)
├── screens/
│   └── location_detail_screen.dart      ← [MODIFY] 기존 그리드/버튼 → 티켓 교체
```

**역할 분리:**
- `boarding_pass_ticket.dart` — 티켓 레이아웃 + 정보 배치 (상태별 분기 포함)
- `ticket_punch_clipper.dart` — ClipPath용 CustomClipper (상단 반원 펀치 홈)
- `ticket_tear_interaction.dart` — 하단 stub 스와이프 감지 + 찢기 애니메이션 + 해금 콜백
- `ticket_dashed_line.dart` — 티켓 본체와 stub 사이 점선 그리기

---

## Task 1: 점선 구분선 CustomPainter

**Files:**
- Create: `lib/features/exploration/presentation/widgets/ticket_dashed_line.dart`

- [ ] **Step 1: 점선 위젯 구현**

```dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 티켓 본체와 stub 사이 점선 구분선
///
/// 수평 점선을 그리는 CustomPainter 기반 위젯입니다.
/// dash 길이와 간격을 커스텀할 수 있습니다.
class TicketDashedLine extends StatelessWidget {
  const TicketDashedLine({
    super.key,
    this.color,
    this.dashWidth = 6.0,
    this.dashGap = 4.0,
    this.strokeWidth = 1.0,
    this.height = 1.0,
  });

  final Color? color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color ?? AppColors.spaceDivider,
          dashWidth: dashWidth,
          dashGap: dashGap,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  final Color color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      dashWidth != oldDelegate.dashWidth ||
      dashGap != oldDelegate.dashGap ||
      strokeWidth != oldDelegate.strokeWidth;
}
```

- [ ] **Step 2: 빌드 확인**

Run: `flutter analyze lib/features/exploration/presentation/widgets/ticket_dashed_line.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/exploration/presentation/widgets/ticket_dashed_line.dart
git commit -m "feat: 티켓 점선 구분선 CustomPainter 위젯 추가 #65"
```

---

## Task 2: 펀치 자국 CustomClipper

**Files:**
- Create: `lib/features/exploration/presentation/widgets/ticket_punch_clipper.dart`

- [ ] **Step 1: 펀치 클리퍼 구현**

해금 후 티켓 상단 테두리에 반원 홈(펀치 자국)을 표현하는 CustomClipper.
좌우 대칭으로 반원 2개를 상단 테두리에 배치합니다.

```dart
import 'package:flutter/material.dart';

/// 티켓 상단 펀치 자국 CustomClipper
///
/// 해금된 티켓의 상단 테두리에 반원 홈을 표현합니다.
/// [punched]가 true일 때만 펀치 자국이 적용됩니다.
///
/// 펀치 위치: 상단 테두리 좌우 대칭 (25%, 75% 지점)
class TicketPunchClipper extends CustomClipper<Path> {
  TicketPunchClipper({
    required this.punched,
    this.punchRadius = 10.0,
    this.borderRadius = 12.0,
  });

  final bool punched;
  final double punchRadius;
  final double borderRadius;

  @override
  Path getClip(Size size) {
    final path = Path();

    if (!punched) {
      // 펀치 없음: 일반 둥근 사각형
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );
      return path;
    }

    // 펀치 있음: 상단에 반원 홈 2개
    final leftPunchX = size.width * 0.25;
    final rightPunchX = size.width * 0.75;
    final r = punchRadius;
    final br = borderRadius;

    // 시작: 좌측 상단 둥근 모서리
    path.moveTo(0, br);
    path.quadraticBezierTo(0, 0, br, 0);

    // 좌측 펀치까지 직선
    path.lineTo(leftPunchX - r, 0);

    // 좌측 펀치 반원 (위로 파임)
    path.arcToPoint(
      Offset(leftPunchX + r, 0),
      radius: Radius.circular(r),
      clockwise: false,
    );

    // 우측 펀치까지 직선
    path.lineTo(rightPunchX - r, 0);

    // 우측 펀치 반원 (위로 파임)
    path.arcToPoint(
      Offset(rightPunchX + r, 0),
      radius: Radius.circular(r),
      clockwise: false,
    );

    // 우측 상단 둥근 모서리
    path.lineTo(size.width - br, 0);
    path.quadraticBezierTo(size.width, 0, size.width, br);

    // 우측 하단 둥근 모서리
    path.lineTo(size.width, size.height - br);
    path.quadraticBezierTo(
      size.width, size.height, size.width - br, size.height,
    );

    // 좌측 하단 둥근 모서리
    path.lineTo(br, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - br);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TicketPunchClipper oldClipper) =>
      punched != oldClipper.punched ||
      punchRadius != oldClipper.punchRadius ||
      borderRadius != oldClipper.borderRadius;
}
```

- [ ] **Step 2: 빌드 확인**

Run: `flutter analyze lib/features/exploration/presentation/widgets/ticket_punch_clipper.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/exploration/presentation/widgets/ticket_punch_clipper.dart
git commit -m "feat: 티켓 상단 펀치 자국 CustomClipper 추가 #65"
```

---

## Task 3: 하단 스와이프 찢기 인터랙션 위젯

**Files:**
- Create: `lib/features/exploration/presentation/widgets/ticket_tear_interaction.dart`

- [ ] **Step 1: 찢기 인터랙션 위젯 구현**

하단 stub 영역의 스와이프 제스처를 감지하고, 찢기 애니메이션 + 해금 콜백을 처리하는 위젯.
스와이프 진행도를 시각적으로 보여주고, 임계값(70%) 초과 시 찢기 완료 처리.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';

/// 티켓 하단 stub 찢기 인터랙션 위젯
///
/// 좌→우 또는 우→좌 스와이프로 티켓을 찢어 해금합니다.
/// [tearThreshold]를 초과하면 찢기 완료로 판정합니다.
///
/// **상태별 표시:**
/// - 잠김 (연료 충분): "밀어서 탑승권 발급" + 스와이프 힌트
/// - 잠김 (연료 부족): "연료 부족" + 비활성
/// - 해금됨: "탑승 완료" 스탬프
/// - 클리어: "탐험 완료" 스탬프
class TicketTearInteraction extends StatefulWidget {
  const TicketTearInteraction({
    super.key,
    required this.isLocked,
    required this.isCleared,
    required this.hasEnoughFuel,
    required this.requiredFuel,
    required this.onTear,
    this.tearThreshold = 0.7,
  });

  final bool isLocked;
  final bool isCleared;
  final bool hasEnoughFuel;
  final int requiredFuel;
  final VoidCallback onTear;
  final double tearThreshold;

  @override
  State<TicketTearInteraction> createState() => _TicketTearInteractionState();
}

class _TicketTearInteractionState extends State<TicketTearInteraction>
    with SingleTickerProviderStateMixin {
  double _dragProgress = 0.0; // 0.0 ~ 1.0
  bool _isTearing = false;

  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: TossDesignTokens.animationNormal,
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.isLocked || !widget.hasEnoughFuel || _isTearing) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width;
    final delta = details.delta.dx.abs() / width;

    setState(() {
      _dragProgress = (_dragProgress + delta).clamp(0.0, 1.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!widget.isLocked || !widget.hasEnoughFuel || _isTearing) return;

    if (_dragProgress >= widget.tearThreshold) {
      // 찢기 완료
      setState(() => _isTearing = true);
      widget.onTear();
    } else {
      // 리셋 애니메이션
      _resetAnimation = Tween<double>(
        begin: _dragProgress,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _resetController,
        curve: TossDesignTokens.smoothCurve,
      ))
        ..addListener(() {
          setState(() => _dragProgress = _resetAnimation.value);
        });
      _resetController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 해금/클리어 상태: 스탬프 표시
    if (!widget.isLocked) {
      return _buildStampStub();
    }

    // 연료 부족: 비활성 stub
    if (!widget.hasEnoughFuel) {
      return _buildDisabledStub();
    }

    // 잠김 + 연료 충분: 스와이프 가능
    return _buildSwipeableStub();
  }

  Widget _buildSwipeableStub() {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: AppColors.spaceSurface,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppRadius.largeValue),
            bottomRight: Radius.circular(AppRadius.largeValue),
          ),
        ),
        child: Column(
          children: [
            // 진행도 바
            ClipRRect(
              borderRadius: AppRadius.chip,
              child: LinearProgressIndicator(
                value: _dragProgress,
                backgroundColor: AppColors.spaceDivider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _dragProgress >= widget.tearThreshold
                      ? AppColors.success
                      : AppColors.primary,
                ),
                minHeight: 4.h,
              ),
            ),
            SizedBox(height: AppSpacing.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe_rounded,
                  color: AppColors.textTertiary,
                  size: 16.w,
                ),
                SizedBox(width: AppSpacing.s4),
                Text(
                  '밀어서 탑승권 발급',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                SizedBox(width: AppSpacing.s4),
                Text(
                  '⛽ ${widget.requiredFuel}',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledStub() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.largeValue),
          bottomRight: Radius.circular(AppRadius.largeValue),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_rounded,
            color: AppColors.textDisabled,
            size: 14.w,
          ),
          SizedBox(width: AppSpacing.s4),
          Text(
            '연료 부족 (필요: ${widget.requiredFuel}통)',
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStampStub() {
    final isCleared = widget.isCleared;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.largeValue),
          bottomRight: Radius.circular(AppRadius.largeValue),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCleared ? Icons.verified_rounded : Icons.check_circle_rounded,
            color: isCleared ? AppColors.accentGold : AppColors.success,
            size: 16.w,
          ),
          SizedBox(width: AppSpacing.s4),
          Text(
            isCleared ? 'COMPLETED' : 'BOARDED',
            style: AppTextStyles.tag_12.copyWith(
              color: isCleared ? AppColors.accentGold : AppColors.success,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
```

**참고:** `AppRadius.largeValue`가 존재하지 않을 수 있음. 실제 구현 시 `spacing_and_radius.dart`를 확인하여 `AppRadius.large`의 raw 값(12.0)을 `Radius.circular(12.r)`로 직접 사용하거나, 해당 상수를 추가할 것. 아래 Task에서 해결.

- [ ] **Step 2: AppRadius에 raw 값 접근이 필요한지 확인**

Run: `grep -n 'largeValue\|large' lib/core/constants/spacing_and_radius.dart`

`AppRadius.large`가 `BorderRadius` 타입이라 `Radius.circular()`에 직접 쓸 수 없으면, `12.r`을 직접 사용하도록 코드를 수정.

- [ ] **Step 3: 빌드 확인**

Run: `flutter analyze lib/features/exploration/presentation/widgets/ticket_tear_interaction.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/features/exploration/presentation/widgets/ticket_tear_interaction.dart
git commit -m "feat: 티켓 하단 스와이프 찢기 인터랙션 위젯 추가 #65"
```

---

## Task 4: 탑승권 티켓 메인 위젯

**Files:**
- Create: `lib/features/exploration/presentation/widgets/boarding_pass_ticket.dart`

- [ ] **Step 1: 탑승권 티켓 위젯 구현**

티켓 전체 컴포지션: 상단 본체(펀치 클리핑 + 정보) + 점선 + 하단 stub(찢기 인터랙션).
`ExplorationNodeEntity`(planet, region)와 `ExplorationProgressEntity`를 받아 정보를 배치.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import 'region_flag_icon.dart';
import 'ticket_dashed_line.dart';
import 'ticket_punch_clipper.dart';
import 'ticket_tear_interaction.dart';

/// 우주 탑승권 티켓 위젯
///
/// 지역 상세 정보를 탑승권(boarding pass) 형태로 표시합니다.
///
/// **구조:**
/// ```
/// ┌──────╰────────────╯──────┐  ← 펀치 자국 (해금 시)
/// │  BOARDING PASS            │
/// │  FROM: 행성  →  TO: 지역  │
/// │  STATUS | FUEL | DATE     │
/// │  PROGRESS BAR             │
/// │  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │  ← 점선
/// │  밀어서 탑승권 발급         │  ← stub (스와이프)
/// └──────────────────────────┘
/// ```
class BoardingPassTicket extends StatelessWidget {
  const BoardingPassTicket({
    super.key,
    required this.planet,
    required this.region,
    required this.progress,
    required this.currentFuel,
    required this.onTear,
  });

  final ExplorationNodeEntity planet;
  final ExplorationNodeEntity region;
  final ExplorationProgressEntity progress;
  final int currentFuel;
  final VoidCallback onTear;

  @override
  Widget build(BuildContext context) {
    final isPunched = region.isUnlocked;

    return Column(
      children: [
        // 상단 본체 (펀치 클리핑)
        Expanded(
          child: ClipPath(
            clipper: TicketPunchClipper(
              punched: isPunched,
              punchRadius: 10.w,
              borderRadius: 12.r,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.spaceSurface,
                borderRadius: AppRadius.large,
              ),
              child: _buildTicketBody(),
            ),
          ),
        ),

        // 점선 구분선
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          child: TicketDashedLine(
            color: AppColors.spaceDivider.withValues(alpha: 0.7),
            dashWidth: 8.0,
            dashGap: 4.0,
          ),
        ),

        // 하단 stub (찢기 인터랙션)
        TicketTearInteraction(
          isLocked: !region.isUnlocked,
          isCleared: region.isCleared,
          hasEnoughFuel: currentFuel >= region.requiredFuel,
          requiredFuel: region.requiredFuel,
          onTear: onTear,
        ),
      ],
    );
  }

  Widget _buildTicketBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더: "BOARDING PASS" 라벨
        _buildHeader(),

        SizedBox(height: AppSpacing.s16),

        // FROM → TO 섹션
        _buildRoute(),

        SizedBox(height: AppSpacing.s16),

        // 정보 행: STATUS | FUEL | DATE
        _buildInfoRow(),

        SizedBox(height: AppSpacing.s16),

        // 진행도 (해금된 경우)
        if (region.isUnlocked) _buildProgressSection(),

        const Spacer(),

        // 하단: 티켓 번호 / 부가 정보
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'BOARDING PASS',
          style: AppTextStyles.tag_10.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // 상태 뱃지
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s8,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.15),
            borderRadius: AppRadius.chip,
          ),
          child: Text(
            _statusText,
            style: AppTextStyles.tag_10.copyWith(
              color: _statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoute() {
    return Row(
      children: [
        // FROM: 행성
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FROM',
                style: AppTextStyles.tag_10.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              Text(
                planet.name,
                style: AppTextStyles.label_16.copyWith(
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // 화살표
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.textTertiary,
            size: 20.w,
          ),
        ),

        // TO: 지역
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TO',
                style: AppTextStyles.tag_10.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RegionFlagIcon(
                    icon: region.icon,
                    size: 20.w,
                    isLocked: !region.isUnlocked,
                  ),
                  SizedBox(width: AppSpacing.s4),
                  Flexible(
                    child: Text(
                      region.name,
                      style: AppTextStyles.label_16.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    final dateText = region.unlockedAt != null
        ? DateFormat('yyyy.MM.dd').format(region.unlockedAt!)
        : '-';
    final difficultyText = _getDifficultyText(region.requiredFuel);
    final difficultyColor = _getDifficultyColor(region.requiredFuel);

    return Row(
      children: [
        // FUEL
        _TicketInfoCell(
          label: 'FUEL',
          value: '${region.requiredFuel}',
          valueColor: AppColors.accentGold,
          icon: Icons.local_gas_station_rounded,
        ),

        _buildVerticalDivider(),

        // DIFFICULTY
        _TicketInfoCell(
          label: 'DIFFICULTY',
          value: difficultyText,
          valueColor: difficultyColor,
        ),

        _buildVerticalDivider(),

        // DATE
        _TicketInfoCell(
          label: 'DATE',
          value: dateText,
          valueColor: AppColors.textSecondary,
          icon: Icons.calendar_today_rounded,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 32.h,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      color: AppColors.spaceDivider.withValues(alpha: 0.5),
    );
  }

  Widget _buildProgressSection() {
    final ratio = progress.progressRatio;
    final cleared = progress.clearedChildren;
    final total = progress.totalChildren;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'PROGRESS',
              style: AppTextStyles.tag_10.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            Text(
              '$cleared / $total',
              style: AppTextStyles.tag_12.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s4),
        ClipRRect(
          borderRadius: AppRadius.chip,
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppColors.spaceDivider,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress.isCompleted ? AppColors.success : AppColors.primary,
            ),
            minHeight: 4.h,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Text(
          '#${region.id.hashCode.abs() % 10000}'.padLeft(5, '0'),
          style: AppTextStyles.tag_10.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 1.0,
          ),
        ),
        const Spacer(),
        if (region.description.isNotEmpty)
          Flexible(
            child: Text(
              region.description,
              style: AppTextStyles.tag_10.copyWith(
                color: AppColors.textDisabled,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }

  // ─── Helpers ───

  String get _statusText {
    if (region.isCleared) return 'COMPLETED';
    if (region.isUnlocked) return 'BOARDED';
    return 'LOCKED';
  }

  Color get _statusColor {
    if (region.isCleared) return AppColors.accentGold;
    if (region.isUnlocked) return AppColors.success;
    return AppColors.textTertiary;
  }

  static String _getDifficultyText(int fuel) {
    if (fuel <= 2) return '쉬움';
    if (fuel <= 4) return '보통';
    return '어려움';
  }

  static Color _getDifficultyColor(int fuel) {
    if (fuel <= 2) return AppColors.success;
    if (fuel <= 4) return AppColors.warning;
    return AppColors.error;
  }
}

// ─── 티켓 정보 셀 ───

class _TicketInfoCell extends StatelessWidget {
  const _TicketInfoCell({
    required this.label,
    required this.value,
    required this.valueColor,
    this.icon,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.tag_10.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12.w, color: valueColor),
                SizedBox(width: 2.w),
              ],
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.paragraph14Semibold.copyWith(
                    color: valueColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 빌드 확인**

Run: `flutter analyze lib/features/exploration/presentation/widgets/boarding_pass_ticket.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/exploration/presentation/widgets/boarding_pass_ticket.dart
git commit -m "feat: 탑승권 티켓 메인 위젯 추가 #65"
```

---

## Task 5: location_detail_screen.dart에 티켓 통합

**Files:**
- Modify: `lib/features/exploration/presentation/screens/location_detail_screen.dart`

- [ ] **Step 1: import 추가 + 불필요한 import 제거**

기존 import 유지하되, 새 위젯 import 추가. `intl` import는 boarding_pass_ticket 내부로 이동했으므로 제거 가능 여부 확인 (다른 곳에서 사용하지 않으면 제거).

추가할 import:
```dart
import '../widgets/boarding_pass_ticket.dart';
```

제거 가능한 import (boarding_pass_ticket으로 이동):
```dart
// import 'package:intl/intl.dart'; — 확인 후 제거
```

- [ ] **Step 2: `_buildRegionPage` 메서드 수정**

기존 `_buildInfoGrid` + `_buildBottomBar` 호출을 `BoardingPassTicket`으로 교체.

기존 코드 (lines 213-237):
```dart
      child: Column(
        children: [
          // 상단: 행성 + 지역 아이콘 + 원형 진행도
          _buildHeroSection(planet, region, progress),

          SizedBox(height: AppSpacing.s32),

          // 지역명
          Text(
            region.name,
            style: AppTextStyles.heading_24.copyWith(color: Colors.white),
          ),

          SizedBox(height: AppSpacing.s32),

          // 2x2 정보 그리드 (남은 공간 채움)
          Expanded(child: _buildInfoGrid(region)),

          SizedBox(height: AppSpacing.s16),

          // 하단: < 해금하기 >
          _buildBottomBar(region, currentFuel, totalPages),

          SizedBox(height: AppSpacing.s16),
        ],
      ),
```

새 코드:
```dart
      child: Column(
        children: [
          // 상단: 행성 + 지역 아이콘 + 원형 진행도
          _buildHeroSection(planet, region, progress),

          SizedBox(height: AppSpacing.s24),

          // 지역명
          Text(
            region.name,
            style: AppTextStyles.heading_24.copyWith(color: Colors.white),
          ),

          SizedBox(height: AppSpacing.s24),

          // 탑승권 티켓 (정보 + 해금 인터랙션)
          Expanded(
            child: BoardingPassTicket(
              planet: planet,
              region: region,
              progress: progress,
              currentFuel: currentFuel,
              onTear: () => _handleUnlock(region, currentFuel),
            ),
          ),

          // 좌우 네비게이션 화살표
          SizedBox(height: AppSpacing.s12),
          _buildNavigationArrows(totalPages),

          SizedBox(height: AppSpacing.s16),
        ],
      ),
```

- [ ] **Step 3: `_buildBottomBar` → `_buildNavigationArrows`로 변경**

기존 `_buildBottomBar`는 < AppButton > 으로 구성. 티켓에 해금 기능이 들어갔으므로, 하단에는 좌우 화살표만 남김.

기존 `_buildBottomBar` 메서드 (lines 366-419) 전체를 삭제하고 새 메서드로 교체:

```dart
  /// 좌우 네비게이션 화살표
  Widget _buildNavigationArrows(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavArrowButton(
          icon: Icons.chevron_left_rounded,
          enabled: _currentPage > 0,
          onTap: _goToPrevious,
        ),
        SizedBox(width: AppSpacing.s24),
        _NavArrowButton(
          icon: Icons.chevron_right_rounded,
          enabled: _currentPage < totalPages - 1,
          onTap: () => _goToNext(totalPages),
        ),
      ],
    );
  }
```

- [ ] **Step 4: `_buildInfoGrid` 메서드 + `_InfoCard` 클래스 삭제**

`_buildInfoGrid` (lines 287-363)와 `_InfoCard` 클래스 (lines 441-494)를 삭제. 더 이상 사용하지 않음.

- [ ] **Step 5: `_handleUnlock`에서 해금 다이얼로그 유지**

기존 `_handleUnlock` 메서드는 `showUnlockDialog`를 호출. 이 동작은 유지 — 스와이프 찢기 후 확인 다이얼로그가 뜨도록 `onTear` 콜백에서 호출.

기존 코드 그대로 유지:
```dart
  void _handleUnlock(ExplorationNodeEntity region, int currentFuel) {
    if (currentFuel < region.requiredFuel) {
      AppSnackBar.error(context, '연료가 부족합니다! (필요: ${region.requiredFuel}통)');
      return;
    }

    showUnlockDialog(
      context: context,
      nodeName: region.name,
      requiredFuel: region.requiredFuel,
      onUnlock: () => ref
          .read(regionListNotifierProvider(widget.planetId).notifier)
          .unlockRegion(region.id, region.requiredFuel),
    );
  }
```

- [ ] **Step 6: 빌드 확인**

Run: `flutter analyze lib/features/exploration/presentation/screens/location_detail_screen.dart`
Expected: No issues found

- [ ] **Step 7: Commit**

```bash
git add lib/features/exploration/presentation/screens/location_detail_screen.dart
git commit -m "feat: 2x2 그리드를 탑승권 티켓 UI로 교체 #65"
```

---

## Task 6: AppRadius raw 값 접근 보장

**Files:**
- Modify: `lib/core/constants/spacing_and_radius.dart` (필요 시)

- [ ] **Step 1: AppRadius 확인**

Run: `grep -n 'large\|largeValue\|static' lib/core/constants/spacing_and_radius.dart`

`AppRadius.large`가 `BorderRadius` 타입인지 확인. `ticket_tear_interaction.dart`에서 `BorderRadius.only()`에 `Radius.circular()` 형태가 필요하므로:

- `AppRadius.large`가 `BorderRadius.circular(12.r)` 타입이면 → `BorderRadius.only()`에 직접 쓸 수 없음
- 해결: `ticket_tear_interaction.dart`와 `boarding_pass_ticket.dart`에서 `12.r`을 직접 사용하거나, `AppRadius`에 `static double largeValue = 12` 추가

- [ ] **Step 2: 필요 시 raw 값 상수 추가**

`spacing_and_radius.dart`에 기존 패턴에 맞게 추가:

```dart
  // 기존 코드 확인 후, 예시:
  static double get largeValue => 12.r;
```

또는 위젯 코드에서 직접 `12.r` 사용하도록 수정.

- [ ] **Step 3: 빌드 확인**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: AppRadius raw 값 접근 지원 #65"
```

---

## Task 7: 최종 통합 테스트 및 정리

**Files:**
- Review: 모든 새 파일 + 수정된 location_detail_screen.dart

- [ ] **Step 1: 전체 정적 분석**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 2: 미사용 import 정리**

location_detail_screen.dart에서 더 이상 사용하지 않는 import 제거:
- `package:intl/intl.dart` (boarding_pass_ticket.dart로 이동)
- 기타 _InfoCard 관련으로만 사용되던 import

Run: `flutter analyze`

- [ ] **Step 3: 디바이스 실행 확인**

Run: `flutter run` 또는 IDE에서 핫 리로드

확인 사항:
1. 잠긴 지역: 티켓 본체 + 점선 + "밀어서 탑승권 발급" stub 표시
2. 스와이프: 진행도 바가 채워지고, 70% 초과 시 해금 다이얼로그 표시
3. 해금된 지역: 상단 펀치 자국 + "BOARDED" 스탬프
4. 클리어 지역: 펀치 자국 + "COMPLETED" 스탬프 + 프로그레스 바 100%
5. 연료 부족: "연료 부족" 비활성 stub
6. 좌우 화살표 네비게이션 정상 동작
7. PageView 스와이프와 stub 스와이프 제스처 충돌 없음

- [ ] **Step 4: 최종 Commit**

```bash
git add -A
git commit -m "chore: 미사용 import 정리 및 최종 검증 #65"
```
