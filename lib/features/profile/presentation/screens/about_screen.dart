import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';

/// About / Credits 페이지
///
/// 앱 정보와 에셋 크레딧/라이선스를 표시합니다.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '앱 정보',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: AppPadding.all20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 앱 정보 섹션
                  _buildAppInfoSection(),
                  SizedBox(height: AppSpacing.s32),

                  // 크레딧 섹션
                  _buildSectionTitle('Credits'),
                  SizedBox(height: AppSpacing.s16),
                  _buildCreditItem(
                    title: 'Rocket Animation',
                    author: 'Sokol Laliçi',
                    source: 'LottieFiles',
                    license: 'Lottie Simple License',
                  ),
                  SizedBox(height: AppSpacing.s32),

                  // 라이선스 안내
                  _buildSectionTitle('Licenses'),
                  SizedBox(height: AppSpacing.s16),
                  _buildLicenseNote(),
                  SizedBox(height: AppSpacing.s16),
                  _buildOpenSourceButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '-';
        final buildNumber = snapshot.data?.buildNumber ?? '-';

        return Center(
          child: Column(
            children: [
              // 앱 아이콘
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    size: 40.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s16),
              Text(
                '우주공부선',
                style: AppTextStyles.heading_20.copyWith(color: Colors.white),
              ),
              SizedBox(height: AppSpacing.s4),
              Text(
                'v$version ($buildNumber)',
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subHeading_18.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildCreditItem({
    required String title,
    required String author,
    required String source,
    required String license,
  }) {
    return Container(
      padding: AppPadding.all16,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.spaceDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.label16Medium.copyWith(color: Colors.white),
          ),
          SizedBox(height: AppSpacing.s8),
          _buildInfoRow('Author', author),
          SizedBox(height: AppSpacing.s4),
          _buildInfoRow('Source', source),
          SizedBox(height: AppSpacing.s4),
          _buildInfoRow('License', license),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70.w,
          child: Text(
            label,
            style: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseNote() {
    return Container(
      padding: AppPadding.all16,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.spaceDivider, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20.w,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              'Animations powered by LottieFiles.com',
              style: AppTextStyles.tag_12.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenSourceButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => showLicensePage(
          context: context,
          applicationName: '우주공부선',
          applicationIcon: Padding(
            padding: AppPadding.all16,
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 48.sp,
              color: AppColors.primary,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: AppColors.spaceDivider),
          padding: AppPadding.buttonPadding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
        ),
        child: Text(
          '오픈소스 라이선스',
          style: AppTextStyles.label_16.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
