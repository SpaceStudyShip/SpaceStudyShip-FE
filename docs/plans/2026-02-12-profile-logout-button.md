# 프로필 화면 로그아웃 버튼 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 프로필 화면 메뉴 리스트 하단에 로그아웃 버튼을 추가하여, 확인 다이얼로그 후 로그아웃을 실행한다.

**Architecture:** ProfileScreen을 `ConsumerWidget`으로 변환하여 `authNotifierProvider`에 접근 → 로그아웃 메뉴 아이템 클릭 시 `AppDialog.confirm()` 표시 → 확인 시 `AuthNotifier.logout()` 호출 → GoRouter redirect가 로그인 화면으로 이동

**Tech Stack:** Flutter, Riverpod (`authNotifierProvider`), GoRouter redirect, `AppDialog`

---

### Task 1: ProfileScreen을 ConsumerWidget으로 변환 + 로그아웃 메뉴 추가

**Files:**
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart`

**Step 1: import 추가 및 위젯 타입 변환**

`StatelessWidget` → `ConsumerWidget`으로 변경하고, 필요한 import를 추가한다.

```dart
// 추가할 import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// 변경
class ProfileScreen extends ConsumerWidget {
  // build 시그니처 변경
  Widget build(BuildContext context, WidgetRef ref) {
```

**Step 2: [테스트] 로그인 화면 메뉴를 로그아웃 버튼으로 교체**

`_buildMenuList()`에서 기존 `[테스트] 로그인 화면` 항목을 제거하고, 구분 간격 + 로그아웃 버튼을 추가한다.

```dart
// 제거:
_buildMenuItem(
  icon: Icons.login_outlined,
  title: '[테스트] 로그인 화면',
  onTap: () => context.push(RoutePaths.login),
),

// 추가 (앱 정보 다음):
SizedBox(height: AppSpacing.s16),
_buildMenuItem(
  icon: Icons.logout_rounded,
  title: '로그아웃',
  onTap: () => _showLogoutDialog(context, ref),
  isDestructive: true,
),
```

**Step 3: `_buildMenuList`에 `WidgetRef ref` 파라미터 추가**

```dart
Widget _buildMenuList(BuildContext context, WidgetRef ref) {
```

호출부도 변경:

```dart
_buildMenuList(context, ref),
```

**Step 4: 로그아웃 확인 다이얼로그 메서드 추가**

```dart
Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
  final confirmed = await AppDialog.confirm(
    context: context,
    title: '로그아웃',
    message: '정말 로그아웃할까요?',
    emotion: AppDialogEmotion.warning,
    confirmText: '로그아웃',
    cancelText: '취소',
    isDestructive: true,
  );

  if (confirmed == true) {
    await ref.read(authNotifierProvider.notifier).logout();
  }
}
```

**Step 5: `_buildMenuItem`에 `isDestructive` 옵션 추가**

로그아웃 항목의 아이콘/텍스트를 빨간 계열로 표시하기 위해 optional 파라미터를 추가한다.

```dart
Widget _buildMenuItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  bool isDestructive = false,
}) {
  // icon color: isDestructive ? AppColors.error : AppColors.textSecondary
  // title color: isDestructive ? AppColors.error : Colors.white
  // chevron: isDestructive이면 숨김
}
```

**Step 6: flutter analyze 실행**

Run: `flutter analyze`
Expected: `No issues found!`

**Step 7: Commit**

```bash
git add lib/features/profile/presentation/screens/profile_screen.dart
git commit -m "feat: 프로필 화면에 로그아웃 버튼 추가"
```
