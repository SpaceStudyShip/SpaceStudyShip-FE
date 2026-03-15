import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: ListView(
              padding: AppPadding.all20,
              children: [
                // 페이지 타이틀
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.s32),
                  child: Text(
                    '설정',
                    style: AppTextStyles.heading_24.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),

                // 섹션 헤더: 화면 효과
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.s4,
                    bottom: AppSpacing.s12,
                  ),
                  child: Text(
                    '화면 효과',
                    style: AppTextStyles.subHeading_18.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),

                Divider(color: AppColors.spaceDivider),

                // 별 반짝임 토글
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '별 반짝임 효과',
                              style: AppTextStyles.label_16.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: AppSpacing.s8),
                            Text(
                              '배경의 별이 반짝입니다',
                              style: AppTextStyles.tag10Semibold.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: settings.starTwinkleEnabled,
                        activeTrackColor: AppColors.primary,
                        onChanged: (_) {
                          ref
                              .read(settingsNotifierProvider.notifier)
                              .toggleStarTwinkle();
                        },
                      ),
                    ],
                  ),
                ),

                Divider(color: AppColors.spaceDivider),
                SizedBox(height: FloatingNavMetrics.totalHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
