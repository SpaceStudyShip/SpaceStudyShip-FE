import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/spacing_and_radius.dart';
import '../constants/text_styles.dart';
import '../../features/badge/presentation/widgets/badge_card.dart';
import '../../features/badge/domain/entities/badge_entity.dart';
import 'widgets.dart';

/// 토스 스타일 위젯 테스트 페이지
///
/// **목적**: 모든 공용 위젯을 한 화면에서 테스트하고 시각적으로 확인
///
/// **섹션 목록**:
/// 1. 버튼 (Buttons)
/// 2. 입력 (Inputs)
/// 3. 카드 (Cards)
/// 4. 로딩/스켈레톤 (Loading)
/// 5. 다이얼로그 (Dialogs)
/// 6. 스낵바 (SnackBars)
/// 7. 빈 상태 (Empty States)
/// 8. 우주 테마 위젯 (Space Theme)
/// 9. 컬렉션 위젯 (Collections)
class TestWidgetPage extends StatefulWidget {
  const TestWidgetPage({super.key});

  @override
  State<TestWidgetPage> createState() => _TestWidgetPageState();
}

class _TestWidgetPageState extends State<TestWidgetPage> {
  // TextField 컨트롤러들
  final _textController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // 상태 변수들
  bool _isLoading = false;
  bool _todoCompleted = false;

  @override
  void dispose() {
    _textController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      appBar: AppBar(
        title: Text(
          '🧪 위젯 테스트',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.spaceSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppPadding.all20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '1. 버튼 (Buttons)',
              description: '토스 스타일 스프링 애니메이션 버튼',
              content: _buildButtons(),
            ),
            _buildSection(
              title: '2. 입력 (Inputs)',
              description: '자동 포맷팅 지원 텍스트 필드',
              content: _buildInputs(),
            ),
            _buildSection(
              title: '3. 카드 (Cards)',
              description: '다양한 스타일의 카드 컨테이너',
              content: _buildCards(),
            ),
            _buildSection(
              title: '4. 로딩 (Loading)',
              description: '로딩 인디케이터와 스켈레톤 UI',
              content: _buildLoading(),
            ),
            _buildSection(
              title: '5. 다이얼로그 (Dialogs)',
              description: '확인/경고/에러 다이얼로그',
              content: _buildDialogs(),
            ),
            _buildSection(
              title: '6. 스낵바 (SnackBars)',
              description: '토스트 메시지 스타일',
              content: _buildSnackbars(),
            ),
            _buildSection(
              title: '7. 빈 상태 (Empty States)',
              description: '데이터 없음/검색 결과 없음/에러',
              content: _buildEmptyStates(),
            ),
            _buildSection(
              title: '8. 우주 테마 (Space Theme)',
              description: '연료 게이지, 스트릭, 타이머 등',
              content: _buildSpaceTheme(),
            ),
            _buildSection(
              title: '9. 컬렉션 (Collections)',
              description: '뱃지, 우주선, 랭킹 카드',
              content: _buildCollections(),
            ),
            SizedBox(height: 100.h), // 하단 여백
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
        SizedBox(height: AppSpacing.s8),
        Text(
          description,
          style: AppTextStyles.paragraph_14.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.s16),
        content,
        SizedBox(height: AppSpacing.s24),
        Divider(color: AppColors.spaceDivider, thickness: 1),
        SizedBox(height: AppSpacing.s24),
      ],
    );
  }

  // ============================================
  // 1. Buttons
  // ============================================
  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          text: 'Primary 버튼',
          onPressed: () => AppSnackBar.success(context, 'Primary 클릭!'),
        ),
        SizedBox(height: AppSpacing.s12),
        AppButton(
          text: 'Secondary 버튼',
          backgroundColor: AppColors.secondary,
          borderColor: AppColors.secondaryDark,
          onPressed: () => AppSnackBar.info(context, 'Secondary 클릭!'),
        ),
        SizedBox(height: AppSpacing.s12),
        AppButton(
          text: '로켓 발사',
          icon: Icon(Icons.rocket_launch, size: 20.w, color: Colors.white),
          iconPosition: IconPosition.leading,
          onPressed: () => AppSnackBar.success(context, '🚀 발사!'),
        ),
        SizedBox(height: AppSpacing.s12),
        AppButton(
          text: '로딩 상태',
          isLoading: _isLoading,
          onPressed: () {
            setState(() => _isLoading = true);
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _isLoading = false);
            });
          },
        ),
        SizedBox(height: AppSpacing.s12),
        const AppButton(text: '비활성 버튼', onPressed: null),
      ],
    );
  }

  // ============================================
  // 2. Inputs
  // ============================================
  Widget _buildInputs() {
    return Column(
      children: [
        AppTextField(
          controller: _textController,
          labelText: '일반 텍스트',
          hintText: '내용을 입력하세요',
          prefixIcon: Icons.edit,
        ),
        SizedBox(height: AppSpacing.s16),
        AppTextField(
          controller: _phoneController,
          labelText: '전화번호 (자동 포맷)',
          hintText: '010-0000-0000',
          prefixIcon: Icons.phone,
          autoFormat: AppInputFormat.phone,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: AppSpacing.s16),
        AppTextField(
          controller: _emailController,
          labelText: '이메일',
          hintText: 'email@example.com',
          prefixIcon: Icons.email,
          autoFormat: AppInputFormat.email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: AppSpacing.s16),
        AppTextField(
          labelText: '에러 상태',
          hintText: '에러 메시지 표시',
          errorText: '올바른 형식이 아니에요',
          prefixIcon: Icons.warning,
        ),
        SizedBox(height: AppSpacing.s16),
        const AppTextField(
          labelText: '비활성 상태',
          hintText: '입력 불가',
          enabled: false,
        ),
      ],
    );
  }

  // ============================================
  // 3. Cards
  // ============================================
  Widget _buildCards() {
    return Column(
      children: [
        AppCard(
          style: AppCardStyle.elevated,
          child: _cardContent('Elevated 카드', '그림자가 있는 카드'),
        ),
        SizedBox(height: AppSpacing.s12),
        AppCard(
          style: AppCardStyle.outlined,
          child: _cardContent('Outlined 카드', '테두리가 있는 카드'),
        ),
        SizedBox(height: AppSpacing.s12),
        AppCard(
          style: AppCardStyle.filled,
          child: _cardContent('Filled 카드', '배경색이 채워진 카드'),
        ),
        SizedBox(height: AppSpacing.s12),
        AppCard(
          onTap: () => AppSnackBar.info(context, '카드 탭!'),
          child: _cardContent('탭 가능한 카드', '눌러보세요'),
        ),
      ],
    );
  }

  Widget _cardContent(String title, String subtitle) {
    return Padding(
      padding: AppPadding.all16,
      child: Row(
        children: [
          Icon(Icons.credit_card, color: AppColors.primary, size: 24.w),
          SizedBox(width: AppSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.label_16.copyWith(color: Colors.white),
              ),
              Text(
                subtitle,
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

  // ============================================
  // 4. Loading
  // ============================================
  Widget _buildLoading() {
    return Column(
      children: [
        // 로딩 인디케이터들
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const AppLoading(type: AppLoadingType.spinner),
                SizedBox(height: AppSpacing.s8),
                Text(
                  'Spinner',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const AppLoading(type: AppLoadingType.dots),
                SizedBox(height: AppSpacing.s8),
                Text(
                  'Dots',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const AppLoading(type: AppLoadingType.progress, progress: 0.7),
                SizedBox(height: AppSpacing.s8),
                Text(
                  'Progress',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s24),

        // 스켈레톤 UI
        Text(
          '스켈레톤 UI',
          style: AppTextStyles.label_16.copyWith(color: Colors.white),
        ),
        SizedBox(height: AppSpacing.s12),
        AppSkeleton.listTile(),
        SizedBox(height: AppSpacing.s8),
        AppSkeleton.listTile(),
        SizedBox(height: AppSpacing.s16),
        AppSkeleton.card(height: 100),
      ],
    );
  }

  // ============================================
  // 5. Dialogs
  // ============================================
  Widget _buildDialogs() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: [
        _dialogButton('기본', () {
          AppDialog.show(
            context: context,
            title: '저장할까요?',
            message: '변경사항이 저장돼요',
            onConfirm: () => AppSnackBar.success(context, '저장됨!'),
          );
        }),
        _dialogButton('성공', () {
          AppDialog.show(
            context: context,
            title: '완료!',
            message: '성공적으로 처리됐어요',
            emotion: AppDialogEmotion.success,
          );
        }),
        _dialogButton('경고', () {
          AppDialog.show(
            context: context,
            title: '주의',
            message: '이 작업은 되돌릴 수 없어요',
            emotion: AppDialogEmotion.warning,
            cancelText: '취소',
          );
        }),
        _dialogButton('삭제', () async {
          final result = await AppDialog.confirm(
            context: context,
            title: '삭제할까요?',
            message: '삭제하면 복구할 수 없어요',
            emotion: AppDialogEmotion.error,
            confirmText: '삭제',
            isDestructive: true,
          );
          if (result == true && mounted) {
            AppSnackBar.error(context, '삭제됨');
          }
        }),
      ],
    );
  }

  Widget _dialogButton(String label, VoidCallback onTap) {
    return AppButton(text: label, width: 80.w, height: 40.h, onPressed: onTap);
  }

  // ============================================
  // 6. Snackbars
  // ============================================
  Widget _buildSnackbars() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: [
        _snackbarButton('성공', AppColors.success, () {
          AppSnackBar.success(context, '성공 메시지예요!');
        }),
        _snackbarButton('에러', AppColors.error, () {
          AppSnackBar.error(context, '에러가 발생했어요');
        }),
        _snackbarButton('정보', AppColors.info, () {
          AppSnackBar.info(context, '정보 메시지예요');
        }),
        _snackbarButton('경고', AppColors.warning, () {
          AppSnackBar.warning(context, '주의가 필요해요');
        }),
      ],
    );
  }

  Widget _snackbarButton(String label, Color color, VoidCallback onTap) {
    return AppButton(
      text: label,
      width: 80.w,
      height: 40.h,
      backgroundColor: color,
      borderColor: color,
      onPressed: onTap,
    );
  }

  // ============================================
  // 7. Empty States
  // ============================================
  Widget _buildEmptyStates() {
    return Column(
      children: [
        AppEmptyState(
          type: AppEmptyType.noData,
          title: '아직 데이터가 없어요',
          description: '새로운 항목을 추가해보세요',
          actionText: '추가하기',
          onAction: () => AppSnackBar.info(context, '추가!'),
        ),
        SizedBox(height: AppSpacing.s24),
        AppEmptyState(
          type: AppEmptyType.noSearch,
          title: '검색 결과가 없어요',
          description: '다른 키워드로 검색해보세요',
        ),
      ],
    );
  }

  // ============================================
  // 8. Space Theme
  // ============================================
  Widget _buildSpaceTheme() {
    return Column(
      children: [
        // Fuel Gauge
        Wrap(
          spacing: 16.w,
          runSpacing: 12.h,
          alignment: WrapAlignment.center,
          children: const [
            FuelGauge(currentFuel: 5, maxFuel: 5, showLabel: false),
            FuelGauge(currentFuel: 3, maxFuel: 5, showLabel: false),
            FuelGauge(currentFuel: 1, maxFuel: 5, showLabel: false),
          ],
        ),
        SizedBox(height: AppSpacing.s24),

        // Streak Badge
        Wrap(
          spacing: 16.w,
          runSpacing: 12.h,
          alignment: WrapAlignment.center,
          children: const [
            StreakBadge(days: 7, showLabel: false),
            StreakBadge(days: 30, showLabel: false),
            StreakBadge(days: 100, showLabel: false),
          ],
        ),
        SizedBox(height: AppSpacing.s24),

        // Status Card
        StatusCard(
          location: '달 기지',
          locationFlag: '🌙',
          fuel: 75,
          streakDays: 14,
        ),
        SizedBox(height: AppSpacing.s24),

        // Timer Display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            TimerDisplay(
              duration: Duration(hours: 1, minutes: 1, seconds: 1),
              size: TimerDisplaySize.small,
            ),
            TimerDisplay(
              duration: Duration(hours: 1, minutes: 1, seconds: 1),
              size: TimerDisplaySize.medium,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s24),

        // Todo Item
        TodoItem(
          title: '알고리즘 문제 풀기',
          isCompleted: _todoCompleted,
          subtitle: '예상 시간: 30분',
          onToggle: () => setState(() => _todoCompleted = !_todoCompleted),
          onTap: () => AppSnackBar.info(context, '할일 상세'),
        ),
        SizedBox(height: AppSpacing.s24),

        // Booster Banner
        BoosterBanner(
          multiplier: 1.5,
          remainingMinutes: 45,
          onTap: () => AppSnackBar.info(context, '부스터 정보'),
        ),
      ],
    );
  }

  // ============================================
  // 9. Collections
  // ============================================
  Widget _buildCollections() {
    return Column(
      children: [
        // Badge Cards
        Text(
          '뱃지 컬렉션',
          style: AppTextStyles.label_16.copyWith(color: Colors.white),
        ),
        SizedBox(height: AppSpacing.s12),
        SizedBox(
          height: 100.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              BadgeCard(
                icon: '🏆',
                name: '첫 발걸음',
                isUnlocked: true,
                rarity: BadgeRarity.normal,
                onTap: () => AppSnackBar.info(context, '첫 발걸음 뱃지'),
              ),
              SizedBox(width: AppSpacing.s12),
              BadgeCard(
                icon: '🌟',
                name: '스타 학습자',
                isUnlocked: true,
                rarity: BadgeRarity.rare,
                onTap: () {},
              ),
              SizedBox(width: AppSpacing.s12),
              BadgeCard(
                icon: '🔥',
                name: '7일 연속',
                isUnlocked: true,
                rarity: BadgeRarity.epic,
                onTap: () {},
              ),
              SizedBox(width: AppSpacing.s12),
              const BadgeCard(
                icon: '👑',
                name: '???',
                isUnlocked: false,
                rarity: BadgeRarity.legendary,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.s24),

        // Spaceship Cards
        Text(
          '우주선 컬렉션',
          style: AppTextStyles.label_16.copyWith(color: Colors.white),
        ),
        SizedBox(height: AppSpacing.s12),
        SizedBox(
          height: 120.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SpaceshipCard(
                icon: '🚀',
                name: '기본선',
                isUnlocked: true,
                isSelected: true,
                rarity: SpaceshipRarity.normal,
                onTap: () {},
              ),
              SizedBox(width: AppSpacing.s12),
              SpaceshipCard(
                icon: '🛸',
                name: 'UFO',
                isUnlocked: true,
                rarity: SpaceshipRarity.rare,
                onTap: () {},
              ),
              SizedBox(width: AppSpacing.s12),
              SpaceshipCard(
                icon: '🚁',
                name: '헬리콥터',
                isUnlocked: true,
                isAnimated: true,
                rarity: SpaceshipRarity.epic,
                onTap: () {},
              ),
              SizedBox(width: AppSpacing.s12),
              const SpaceshipCard(
                icon: '🌌',
                name: '???',
                isUnlocked: false,
                rarity: SpaceshipRarity.legendary,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.s24),

        // Ranking Items
        Text('랭킹', style: AppTextStyles.label_16.copyWith(color: Colors.white)),
        SizedBox(height: AppSpacing.s12),
        RankingItem(
          rank: 1,
          userName: '김우주',
          avatarEmoji: '🧑‍🚀',
          studyTime: const Duration(hours: 8, minutes: 30),
          onTap: () {},
        ),
        SizedBox(height: AppSpacing.s8),
        RankingItem(
          rank: 2,
          userName: '이스타',
          avatarEmoji: '👨‍💻',
          studyTime: const Duration(hours: 7, minutes: 15),
          onTap: () {},
        ),
        SizedBox(height: AppSpacing.s8),
        RankingItem(
          rank: 3,
          userName: '박코딩',
          avatarEmoji: '👩‍💻',
          studyTime: const Duration(hours: 6, minutes: 45),
          onTap: () {},
        ),
        SizedBox(height: AppSpacing.s8),
        RankingItem(
          rank: 4,
          userName: '나',
          avatarEmoji: '🙋',
          studyTime: const Duration(hours: 5, minutes: 0),
          isCurrentUser: true,
          onTap: () {},
        ),
      ],
    );
  }
}
