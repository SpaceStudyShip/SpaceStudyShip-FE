import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import 'region_flag_icon.dart';
import 'ticket_dashed_line.dart';
import 'ticket_punch_clipper.dart';
import 'ticket_tear_interaction.dart';

/// 우주 탑승권 티켓 위젯
///
/// 지역 상세 정보를 탑승권(boarding pass) 형태로 표시합니다.
/// 해금 시 펀치 자국이 애니메이션으로 나타납니다.
class BoardingPassTicket extends StatefulWidget {
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
  final Future<bool> Function() onTear;

  @override
  State<BoardingPassTicket> createState() => _BoardingPassTicketState();
}

class _BoardingPassTicketState extends State<BoardingPassTicket>
    with SingleTickerProviderStateMixin {
  late final AnimationController _punchController;
  bool _wasPunched = false;

  @override
  void initState() {
    super.initState();
    _punchController = AnimationController(
      vsync: this,
      duration: TossDesignTokens.entranceNormal,
    );
    _wasPunched = widget.region.isUnlocked;
    if (_wasPunched) {
      _punchController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant BoardingPassTicket oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 잠김 → 해금 전환 감지: 펀치 애니메이션 재생
    if (widget.region.isUnlocked && !_wasPunched) {
      _wasPunched = true;
      _punchController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _punchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 본체 (펀치 클리핑 — 애니메이션)
        Expanded(
          child: AnimatedBuilder(
            animation: _punchController,
            builder: (context, child) {
              final punchProgress = CurvedAnimation(
                parent: _punchController,
                curve: TossDesignTokens.springCurve,
              ).value;

              return ClipPath(
                clipper: TicketPunchClipper(
                  punched: widget.region.isUnlocked,
                  punchRadius: 10.w * punchProgress,
                  borderRadius: 12.r,
                ),
                child: child,
              );
            },
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
          isLocked: !widget.region.isUnlocked,
          isCleared: widget.region.isCleared,
          hasEnoughFuel: widget.currentFuel >= widget.region.requiredFuel,
          onTear: widget.onTear,
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

        // 정보 행: FUEL | DIFFICULTY | DATE
        _buildInfoRow(),

        SizedBox(height: AppSpacing.s16),

        // 진행도 (해금된 경우)
        if (widget.region.isUnlocked) _buildProgressSection(),

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
                widget.planet.name,
                style: AppTextStyles.label_16.copyWith(color: Colors.white),
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
                    icon: widget.region.icon,
                    size: 20.w,
                    isLocked: !widget.region.isUnlocked,
                  ),
                  SizedBox(width: AppSpacing.s4),
                  Flexible(
                    child: Text(
                      widget.region.name,
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
    final dateText = widget.region.unlockedAt != null
        ? DateFormat('yyyy.MM.dd').format(widget.region.unlockedAt!)
        : '-';
    final difficultyText = _getDifficultyText(widget.region.requiredFuel);
    final difficultyColor = _getDifficultyColor(widget.region.requiredFuel);

    return Row(
      children: [
        _TicketInfoCell(
          label: 'FUEL',
          value: '${widget.region.requiredFuel}',
          valueColor: AppColors.accentGold,
          icon: Icons.local_gas_station_rounded,
        ),

        _buildVerticalDivider(),

        _TicketInfoCell(
          label: 'DIFFICULTY',
          value: difficultyText,
          valueColor: difficultyColor,
        ),

        _buildVerticalDivider(),

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
    final ratio = widget.progress.progressRatio;
    final cleared = widget.progress.clearedChildren;
    final total = widget.progress.totalChildren;

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
              widget.progress.isCompleted
                  ? AppColors.success
                  : AppColors.primary,
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
          '#${(widget.region.id.hashCode.abs() % 10000).toString().padLeft(4, '0')}',
          style: AppTextStyles.tag_10.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 1.0,
          ),
        ),
        const Spacer(),
        if (widget.region.description.isNotEmpty)
          Flexible(
            child: Text(
              widget.region.description,
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
    if (widget.region.isCleared) return 'COMPLETED';
    if (widget.region.isUnlocked) return 'BOARDED';
    return 'LOCKED';
  }

  Color get _statusColor {
    if (widget.region.isCleared) return AppColors.accentGold;
    if (widget.region.isUnlocked) return AppColors.success;
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
