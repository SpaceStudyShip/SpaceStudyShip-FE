# About/Credits 페이지 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 프로필 하위에 About 페이지를 추가하여 앱 정보와 에셋 크레딧/라이선스를 표시한다.

**Architecture:** `features/profile/presentation/screens/about_screen.dart` 신규 생성. 기존 라우트 패턴(`RoutePaths` + `GoRoute`)을 따르고, 프로필 메뉴에 진입점 추가. `package_info_plus`(이미 설치됨)로 앱 버전 표시.

**Tech Stack:** Flutter, GoRouter, package_info_plus, 기존 프로젝트 위젯/상수

---

## Task 1: 라우트 등록 (route_paths + app_router)

**Files:**
- Modify: `lib/routes/route_paths.dart:62-65`
- Modify: `lib/routes/app_router.dart:240-245`

**Step 1: RoutePaths에 about 경로 추가**

`route_paths.dart`의 Profile 하위 화면 섹션에 추가:

```dart
  // Profile 하위 화면
  static const settings = '/profile/settings';
  static const badges = '/profile/badges';
  static const spaceships = '/profile/spaceships';
  static const statistics = '/profile/statistics';
  static const about = '/profile/about';  // 추가
```

**Step 2: app_router.dart에 GoRoute 추가**

Profile 브랜치의 routes 마지막(statistics 아래)에 추가:

```dart
                  GoRoute(
                    path: 'statistics',
                    name: 'statistics',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '통계'),
                  ),
                  // 추가:
                  GoRoute(
                    path: 'about',
                    name: 'about',
                    builder: (context, state) =>
                        const AboutScreen(),
                  ),
```

import 추가:
```dart
import '../features/profile/presentation/screens/about_screen.dart';
```

**Step 3: Commit**

```bash
git add lib/routes/route_paths.dart lib/routes/app_router.dart
git commit -m "feat: About 페이지 라우트 등록"
```

(Note: AboutScreen이 아직 없으므로 이 시점에서는 analyze가 실패할 수 있음. Task 2와 함께 커밋해도 됨.)

---

## Task 2: AboutScreen 생성

**Files:**
- Create: `lib/features/profile/presentation/screens/about_screen.dart`

**Step 1: about_screen.dart 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// About / Credits 페이지
///
/// 앱 정보와 에셋 크레딧/라이선스를 표시합니다.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
      body: SafeArea(
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
                url: 'https://lottiefiles.com/free-animation/rocket-lunch-x9j9TboyaP',
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
    );
  }

  Widget _buildAppInfoSection() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
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
    required String url,
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
            style: AppTextStyles.tag_12.copyWith(color: AppColors.textSecondary),
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
          style: AppTextStyles.label_16.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
```

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: `No issues found!`

**Step 3: Commit (Task 1과 합쳐서)**

```bash
git add lib/routes/route_paths.dart lib/routes/app_router.dart lib/features/profile/presentation/screens/about_screen.dart
git commit -m "feat: About/Credits 페이지 추가 (앱 정보 + 에셋 크레딧 + 라이선스)"
```

---

## Task 3: 프로필 메뉴에 About 진입점 추가

**Files:**
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart:131-155`

**Step 1: 메뉴 리스트에 About 항목 추가**

`_buildMenuList` 메서드의 마지막 항목 뒤에 추가:

```dart
  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.bar_chart_outlined,
          title: '통계',
          onTap: () => context.push(RoutePaths.statistics),
        ),
        _buildMenuItem(
          icon: Icons.emoji_events_outlined,
          title: '배지 컬렉션',
          onTap: () => context.push(RoutePaths.badges),
        ),
        _buildMenuItem(
          icon: Icons.rocket_launch_outlined,
          title: '우주선 컬렉션',
          onTap: () => context.push(RoutePaths.spaceships),
        ),
        _buildMenuItem(
          icon: Icons.info_outline_rounded,
          title: '앱 정보',
          onTap: () => context.push(RoutePaths.about),
        ),
        _buildMenuItem(
          icon: Icons.login_outlined,
          title: '[테스트] 로그인 화면',
          onTap: () => context.push(RoutePaths.login),
        ),
      ],
    );
  }
```

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/screens/profile_screen.dart
git commit -m "feat: 프로필 메뉴에 '앱 정보' 항목 추가"
```

---

## 영향 범위 요약

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `route_paths.dart` | 1줄 추가 | `about` 경로 상수 |
| `app_router.dart` | ~6줄 추가 | GoRoute + import |
| `about_screen.dart` | 신규 생성 | About/Credits 전체 화면 |
| `profile_screen.dart` | ~4줄 추가 | 메뉴 항목 추가 |

**변경 파일 수:** 4개 (1개 신규)
**위험도:** 낮음 (신규 화면 추가, 기존 코드 영향 없음)
