# 소셜 화면 — FocusFlight 스타일 우주 뷰 디자인 스펙

**이슈:** #67  
**브랜치:** `20260412_#67_소셜_화면_UI_UX_구체화_탑승권_테마_레이아웃_설계`  
**작성일:** 2026-04-14  
**상태:** 승인됨

---

## 배경 및 목적

기존 레이더 뷰(RadarScene + RadarBackground 등)를 폐기하고, FocusFlight 앱에서 영감을 받은 **우주선 비행 뷰**로 전면 교체한다.  
FocusFlight의 핵심 은유: "공부 중 = 하늘(우주)을 날고 있는 상태". 이 앱의 우주 테마와 자연스럽게 결합된다.

---

## 결정된 디자인 방향

### 메인 화면 (SocialSpaceView)

`SocialScreen`의 TabBar를 제거하고 전체 화면을 우주 뷰 하나로 교체한다.

```
┌─────────────────────────────┐
│ 소셜                        │  ← AppBar (탭 없음)
├─────────────────────────────┤
│  ✦    [나(YOU)]    ✦        │
│  [정민수]      [박지훈]      │  ← HIGH ORBIT (2h+)
│        ✦           ✦       │
│  [이수진]    [한지민]        │  ← LOW ORBIT (1h 미만)
│  ·  ·  ·  ·  ·  ·  ·  ·   │
├── ── ── DOCKED ── ── ── ────┤
│  [김하은] [오태양] [최유리] + │  ← 착륙 (오프라인/대기)
├─────────────────────────────┤
│ ● 나·공부중  ● 친구 4명  [+] │  ← 하단 상태바
└─────────────────────────────┘
```

### 우주선 배치 규칙

| 조건 | 위치 |
|------|------|
| 공부 중 90분 이상 | HIGH ORBIT (상단 영역) |
| 공부 중 90분 미만 | LOW ORBIT (중단 영역) |
| 오프라인 / 대기 | 지평선 아래 DOCKED 영역 |

- 나(ME) 우주선 = 파란색 테두리 (`primary`) + glow
- 공부 중인 친구 = 초록색 테두리 (`success`) + pulse 애니메이션
- 착륙 상태 = `spaceDivider` 테두리, opacity 0.4

우주선 아이콘: 이름 첫 글자 이니셜 (현재 아바타 없음, 더미 데이터 기준).  
같은 고도의 우주선들은 좌우 균등 배치 (각도 분산).

---

## 컴포넌트 구조

### 신규 위젯

| 위젯 | 파일 | 역할 |
|------|------|------|
| `SocialSpaceView` | `social_space_view.dart` | 메인 화면 전체 (SpaceBackground + 우주선 배치 + 하단 바) |
| `ShipNode` | `ship_node.dart` | 개별 우주선 노드 (공부 중 / 나) |
| `DockedShipNode` | `docked_ship_node.dart` | 착륙 상태 작은 아바타 |

### 삭제할 기존 위젯

- `social_radar_view.dart`
- `radar_background.dart`
- `radar_scene.dart`
- `radar_status_bar.dart`
- `me_node.dart`
- `friend_node.dart`

### 신규 화면

| 화면 | 파일 | 역할 |
|------|------|------|
| `FriendDetailScreen` | `friend_detail_screen.dart` | 친구 상세 정보 페이지 |

---

## FriendDetailScreen

우주선 탭 시 `Navigator.push`로 이동.

```
┌─────────────────────────────┐
│ ← 소셜                      │  ← 뒤로가기
│                             │
│         [  정  ]            │  ← 아바타 (72×72, 초록 테두리)
│         정민수               │
│       ● 지금 공부 중          │
│                             │
│ ┌──────────────────────────┐│
│ │ 현재 과목    수학  · 2h14m ││  ← 과목 카드
│ └──────────────────────────┘│
│ ┌───────────┐ ┌───────────┐ │
│ │  2h 14m   │ │ 14h 32m  │ │  ← 오늘 / 이번 주
│ │  오늘 공부  │ │  이번 주  │ │
│ └───────────┘ └───────────┘ │
└─────────────────────────────┘
```

---

## 데이터

### FriendEntity 수정

기존 entity에 `weeklyStudyDuration` 필드 추가.

```dart
@freezed
class FriendEntity with _$FriendEntity {
  const factory FriendEntity({
    required String id,
    required String name,
    required FriendStatus status,
    Duration? studyDuration,      // 오늘 공부 시간
    String? currentSubject,       // 현재 과목
    Duration? weeklyStudyDuration, // 이번 주 공부 시간 (신규)
  }) = _FriendEntity;
}
```

### 고도 계산 로직 (Provider)

```dart
// HIGH ORBIT: studying && studyDuration >= 90분
// LOW ORBIT:  studying && studyDuration < 90분
// DOCKED:     idle / offline
```

더미 데이터는 `friends_provider.dart`에서 관리.

---

## SocialScreen 변경

`TabController` / `TabBar` / `TabBarView` 완전 제거.  
`_buildFriendsTab()` 대신 `SocialSpaceView()` 직접 반환.  
게스트 모드 로그인 유도 화면은 유지.

---

## 색상 규칙

| 용도 | AppColors |
|------|-----------|
| 나(YOU) 테두리 | `primary` |
| 공부 중 친구 테두리 | `success` |
| 착륙 상태 테두리 | `spaceDivider` |
| 배경 | `spaceBackground` |
| 우주선 내부 | `spaceElevated` |
| 고도선 | `spaceDivider` (dashed) |
| 하단 바 배경 | `spaceSurface` |

그라데이션 사용 금지 — `AppColors` 상수만.

---

## 파일 변경 목록

```
lib/features/social/
├── domain/
│   └── entities/
│       └── friend_entity.dart              (수정 — weeklyStudyDuration 추가)
├── presentation/
│   ├── providers/
│   │   └── friends_provider.dart           (수정 — 더미 데이터 업데이트)
│   ├── screens/
│   │   ├── social_screen.dart              (수정 — TabBar 제거, SocialSpaceView 연결)
│   │   └── friend_detail_screen.dart       (신규)
│   └── widgets/
│       ├── social_space_view.dart           (신규)
│       ├── ship_node.dart                   (신규)
│       ├── docked_ship_node.dart            (신규)
│       ├── social_radar_view.dart           (삭제)
│       ├── radar_background.dart            (삭제)
│       ├── radar_scene.dart                 (삭제)
│       ├── radar_status_bar.dart            (삭제)
│       ├── me_node.dart                     (삭제)
│       └── friend_node.dart                 (삭제)
```

---

## 완료 조건

- [ ] 소셜 화면에 탭바 없이 우주 뷰 표시
- [ ] 내 우주선 (파란색) 이 공부 중일 때 우주에 표시
- [ ] 친구 우주선이 공부 시간에 따라 HIGH/LOW ORBIT 배치
- [ ] 오프라인/대기 친구는 지평선 아래 착륙 표시
- [ ] 우주선 탭 → FriendDetailScreen 이동
- [ ] FriendDetailScreen에 오늘/이번 주 공부 시간, 현재 과목 표시
- [ ] `AppColors` 외 하드코딩 색상 없음
- [ ] `flutter analyze` 경고 0개
- [ ] 게스트 모드 로그인 유도 화면 유지
