# 소셜 화면 — 레이더 뷰 디자인 스펙

**이슈:** #67  
**브랜치:** `20260412_#67_소셜_화면_UI_UX_구체화_탑승권_테마_레이아웃_설계`  
**작성일:** 2026-04-13  
**상태:** 승인됨

---

## 배경 및 목적

기존 소셜 화면(`SocialScreen`)은 친구/그룹/랭킹 탭만 있고 전부 빈 상태(SpaceEmptyState)로 채워진 플레이스홀더 수준이다. 이번 작업은 **친구 탭**에 "우주 정거장 레이더" 느낌의 몰입감 있는 UI를 설계·구현하는 것이다.

---

## 결정된 디자인 방향

### 레이더 풀스크린 (Option A)

친구 탭 전체를 레이더로 채운다. "나"를 중심으로 친구들이 링 위에 배치된다.

```
┌─────────────────────────────┐
│ 소셜                        │  ← AppBar
│ [친구] [그룹] [랭킹]         │  ← TabBar (유지)
├─────────────────────────────┤
│                             │
│   (외부링) 정·오·한          │
│  (내부링) 김·박  이          │
│        [나(YOU)]            │  ← 중앙 고정
│                             │
│  grid 배경 + 링 3개          │
│                             │
├─────────────────────────────┤
│ ● 공부중 4명  ◌ 대기 3명  [+친구 추가] │  ← 하단 상태바
└─────────────────────────────┘
```

---

## 컴포넌트 구조

### `SocialRadarView` (신규 위젯)
- 친구 탭의 본문 전체를 담당하는 최상위 위젯
- 내부: `RadarBackground` + `RadarScene` + `RadarStatusBar`

### `RadarBackground`
- `spaceBackground` 배경
- 28px 간격 grid 선 (`primary.withOpacity(0.04)`)

### `RadarScene`
- 링 3개 (`ring-1`: 반지름 50, `ring-2`: 95 dashed, `ring-3`: 140)
- 링 색상: `spaceDivider` / `spaceElevated` / `spaceSurface`
- 중앙: `MeNode` (나)
- 친구 노드: `FriendNode` 리스트

### `MeNode`
- 크기: 56×56, 원형
- 배경: `spaceElevated`
- 테두리: `primary` 2.5px, glow `primary.withOpacity(0.3)`
- 텍스트: 프로필 이니셜 or 아바타

### `FriendNode`
- 상태: `studying` / `idle` / `offline`
- `studying`: 테두리 `success`, glow, pulse 애니메이션
- `idle` / `offline`: 테두리 `spaceDivider`, opacity 0.6
- 크기: 내부링 36×36 / 외부링 30×30
- 링 배치: 공부 중인 친구는 내부링, 아닌 친구는 외부링

### `RadarStatusBar`
- 배경: `spaceSurface`
- 상단 경계: `spaceDivider` 1px
- 좌측: `● 공부중 N명` (success 도트)
- 중앙: `◌ 대기 N명` (offline 도트)
- 우측: `+ 친구 추가` 버튼 (`primary` 배경, pill shape)

---

## 색상 규칙

| 용도 | AppColors |
|------|-----------|
| 배경 | `spaceBackground` |
| 카드/표면 | `spaceSurface`, `spaceElevated` |
| 구분선·링 | `spaceDivider` |
| 나(YOU) 테두리 | `primary` |
| 공부중 테두리·타이머 | `success` |
| 연결선 (공부중) | `success.withOpacity(0.35)` |
| 연결선 (대기) | `spaceDivider` |
| 오프라인 | `offline (#9E9E9E)` |
| 텍스트 계층 | `textPrimary` / `textSecondary` / `textTertiary` |

그라데이션 사용 금지 — `AppColors` 상수만 사용.

---

## 노드 배치 로직

- 친구 수에 따라 링 위에 균등 각도로 배치
- 공부 중(`studying`) 친구 → 내부링 우선
- 오프라인·대기 친구 → 외부링
- 친구가 없을 때: `SpaceEmptyState` fallback

```
내부링 최대 수용: 6명
외부링 최대 수용: 10명
초과 시: 외부링에 "+N" 노드로 표시
```

---

## 애니메이션

| 요소 | 애니메이션 | 스펙 |
|------|-----------|------|
| 공부중 노드 pulse | scale 1.0 → 1.8, opacity 0.7 → 0 | 2.5초 반복, ease-out |
| 진입 애니메이션 | FadeSlideIn (기존 위젯 재사용) | 0.3초 |
| 연결선 | 정적 (애니메이션 없음) | — |

---

## 탭 범위

| 탭 | 이번 작업 |
|----|---------|
| 친구 | 레이더 뷰 구현 |
| 그룹 | 변경 없음 (기존 EmptyState 유지) |
| 랭킹 | 변경 없음 (기존 EmptyState 유지) |

---

## 데이터

현재 백엔드 API 미완성이므로 **더미 데이터**로 구현.  
API 완성 시 Provider만 교체하면 되도록 인터페이스를 미리 정의.

```dart
// domain/entities/friend_entity.dart (신규)
@freezed
class FriendEntity with _$FriendEntity {
  const factory FriendEntity({
    required String id,
    required String name,
    required FriendStatus status,  // studying / idle / offline
    Duration? studyDuration,       // 오늘 공부 시간
    String? currentSubject,        // 현재 공부 과목
  }) = _FriendEntity;
}

enum FriendStatus { studying, idle, offline }
```

---

## 파일 변경 목록

```
lib/features/social/
├── domain/
│   └── entities/
│       └── friend_entity.dart            (신규)
├── presentation/
│   ├── providers/
│   │   └── friends_provider.dart         (신규 — 더미 데이터)
│   ├── screens/
│   │   └── social_screen.dart            (수정 — 친구탭 연결)
│   └── widgets/
│       ├── social_radar_view.dart         (신규)
│       ├── radar_background.dart          (신규)
│       ├── radar_scene.dart               (신규)
│       ├── me_node.dart                   (신규)
│       ├── friend_node.dart               (신규)
│       └── radar_status_bar.dart          (신규)
```

---

## 완료 조건

- [ ] 친구 탭에 레이더 뷰가 표시됨
- [ ] "나" 노드가 중앙에 고정
- [ ] 더미 친구 데이터로 노드가 링 위에 배치됨
- [ ] `studying` 친구에 pulse 애니메이션 동작
- [ ] `AppColors` 외 하드코딩 색상 없음
- [ ] `flutter analyze` 경고 0개
- [ ] 게스트 모드에서 기존 로그인 유도 화면 유지
