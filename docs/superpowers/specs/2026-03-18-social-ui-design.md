# 소셜 화면 UI 구체화 설계

> **이슈**: #64 소셜 화면 UI 구체화
> **브랜치**: `20260318_#64_소셜_화면_UI_구체화`
> **작성일**: 2026-03-18

## 개요

소셜 화면의 3개 탭(친구/그룹/랭킹)을 우주 테마에 맞게 구체화한다.
현재는 모두 `SpaceEmptyState` placeholder만 존재하며, 이를 실제 UI로 교체한다.
백엔드가 아직 없으므로 Mock 데이터로 구현하되, API 연결 시 Repository 구현체만 교체할 수 있도록 설계한다.

## 공통 변경사항

### AppBar 제거 → SafeArea 전환
- 기존 `AppBar` 위젯 제거
- `SafeArea`로 상단 여백만 확보
- 탭 바를 화면 상단에 직접 배치
- 탭 바 스타일: 기존 밑줄 인디케이터(`indicatorColor: AppColors.primary`) 유지

### 게스트 모드
- 기존과 동일하게 로그인 유도 화면 유지
- AppBar 제거에 맞춰 SafeArea + 중앙 정렬 `SpaceEmptyState` + 로그인 버튼으로 수정

### 디자인 시스템
- 색상: `AppColors` (`app_colors.dart`)
- 타이포: `AppTextStyles` (`text_styles.dart`)
- 간격: `AppSpacing`, `AppPadding`, `AppRadius` (`spacing_and_radius.dart`)
- 배경: `SpaceBackground` (기존 위젯)

---

## 1. 친구 탭 — 별자리 맵

### 컨셉
**북두칠성 별자리**가 항상 화면에 그려져 있고, 빈 자리에 친구가 채워지는 방식.
그룹 탭의 빈 좌석 컨셉과 동일한 구조.

### 레이아웃
- **별자리**: 북두칠성 패턴 (7자리) 이 항상 고정으로 표시됨
- **나(북극성)**: 고정 위치, 다른 별보다 크게 + 미세한 glow 효과 (`AppColors.primaryLight`)
- **친구 자리 (6자리)**: 북두칠성의 나머지 6개 위치에 친구가 순서대로 채워짐
  - 채워진 자리: 밝은 별 + 닉네임
  - 빈 자리: 어두운 빈 별 (그룹 빈 좌석과 동일한 톤)
- **연결선**: 별 사이를 잇는 얇은 선 (`AppColors.spaceDivider`, 0.5~1px), 항상 표시
- **최대 친구 수**: 6명 (북두칠성 7자리 - 나 1자리)
- **향후 확장**: 유료로 다른 별자리(카시오페이아, 오리온 등) 선택 가능 → 자리 수 변경

### 별 인터랙션
- **채워진 별 탭**: 친구 프로필 상세 화면으로 이동 (`/social/friends/:id`, 현재는 Placeholder)
- **빈 별 탭**: 친구 추가 동작
- **라벨**: 별 위에 친구 닉네임 표시 (`AppTextStyles.tag_12`, `AppColors.textSecondary`)
- **온라인 상태**: 별 색상으로 표현 (기존 시맨틱 색상 사용)
  - 온라인: `AppColors.online` glow
  - 자리비움: `AppColors.away` glow
  - 오프라인: `AppColors.offline`

### 빈 상태
- 북두칠성 패턴 + 북극성(나)만 밝게 표시, 나머지 6자리 모두 빈 별
- "친구를 추가해서 별자리를 완성해요" 문구
- 친구 추가 버튼

### 친구 추가
- 빈 별 탭 또는 하단 버튼으로 친구 추가 진입
- 현재는 UI 껍데기만 (백엔드 연결 대기)

### 친구 프로필 상세 (`/social/friends/:id`)
- 이번 스코프에서는 Placeholder 화면 유지
- 향후 별도 이슈로 구체화

---

## 2. 그룹 탭 — 우주선 티켓

### 컨셉
각 그룹이 우주선 탑승 티켓으로 표현된다. 가로 스크롤로 티켓을 넘기며, 탭하면 Hero 애니메이션으로 좌석 화면에 진입한다.

### 그룹 목록 화면 — 티켓 카드

**가로 스크롤 PageView** 형태로 티켓 카드 배치.

**티켓 카드 구성** (`exploration_detail_screen.dart` 티켓 스타일 참고):
- 상단: `CREW PASS` 라벨 + 티켓 코드 (`AppTextStyles.tag_12`, `AppColors.textTertiary`)
- 중앙: 그룹 이름 (`AppTextStyles.heading_20`)
- 좌석 현황: `2/4` 표시 + 미니 좌석 아이콘 (채워진/빈)
- 현재 활동 중 인원 수 (초록 점 + `AppTextStyles.tag_12`)
- 하단: 바코드 SVG (기존 `assets/icons/barcode_lavender.svg` 재활용)

**인터랙션**: 탭 → Hero 애니메이션으로 그룹 상세 화면 진입

### 그룹 상세 — 좌석 화면 (`/social/groups/:id`)

**상단 구조:**
- AppBar: 뒤로 버튼(좌) + 초대코드 텍스트 + 복사 아이콘(우, `assets/icons/icon_copy.svg`)
- 복사 탭 → 클립보드 복사 + 스낵바 피드백
- AppBar 아래: 그룹 제목 (`AppTextStyles.heading_20`)

**좌석 그리드:**
- 현재는 고정 4석 (2x2 그리드)으로 구현
- 단, 그리드 위젯은 `maxSeats` 값에 따라 열/행을 동적으로 결정하도록 설계 (향후 확장 대비)
- 채워진 좌석: 유저 아바타 + 닉네임 + 온라인 상태 (glow)
- 빈 좌석: 피그마 스타일 어두운 빈 좌석 아이콘
- 좌석 탭 동작:
  - 채워진 좌석 → 해당 유저 프로필로 이동
  - 빈 좌석 → 초대 동작 (초대코드 공유)

**유료 확장 (향후):**
- 6명 (3x2) → 9명 (3x3) → 12명 (4x3)
- `maxSeats` 값만 변경하면 그리드 자동 조정

### 그룹 생성
- 그룹 만들기 버튼 제공
- 현재는 UI만 구현 (초대 코드 방식으로 설계, 백엔드 대기)

### 빈 상태
- `SpaceEmptyState` 유지: "참여 중인 그룹이 없어요"
- 그룹 만들기 / 초대코드 입력 버튼

---

## 3. 랭킹 탭

### 구조
- **서브 탭**: 전체 랭킹 / 친구 랭킹
- **기간 필터**: 오늘 / 주간 / 월간 (ChoiceChip 스타일, `AppTextStyles.tag_12`, 선택 시 `AppColors.primary` 배경)

### 랭킹 리스트
- 기존 `RankingItem` 위젯 재활용
  - 1~3위: 메달 그라디언트 (gold/silver/bronze)
  - 유저 아바타 + 닉네임 + 공부시간
- **내 순위**: 리스트 하단에 고정 표시
  - 구분선 위에 배치
  - `AppColors.primary` 보더로 하이라이트

### 빈 상태
- 현재 `SpaceEmptyState` 유지: "랭킹 준비 중"

---

## 화면 전환 흐름

```
소셜 메인 (SafeArea + 탭)
├── 친구 탭 → 별자리 맵
│   └── 별 탭 → /social/friends/:id (프로필 상세)
├── 그룹 탭 → 티켓 가로 스크롤
│   └── 티켓 탭 → Hero → /social/groups/:id (좌석 화면)
│       ├── 채워진 좌석 탭 → 유저 프로필 이동
│       └── 빈 좌석 탭 → 초대 동작
└── 랭킹 탭 → 전체/친구 서브탭 + 기간 필터
```

---

## 백엔드 확장성

### Repository 인터페이스
- `FriendRepository`: 친구 목록, 추가, 삭제
- `GroupRepository`: 그룹 목록, 생성, 참여(초대코드), 멤버 조회
- `RankingRepository`: 전체/친구 랭킹 조회 (기간별)
- 현재는 Mock Repository로 더미 데이터 제공
- API 연결 시 Repository 구현체만 교체

### Mock 데이터 모델
```
Friend: { id, name, avatarUrl?, isOnline, status(online/away/offline), slotIndex(0~5) }
Group: { id, name, maxSeats(4), members: List<Member>, inviteCode }
Member: { id, name, avatarUrl?, isOnline, seatIndex }
RankingEntry: { rank, userId, name, avatarUrl?, studyTimeMinutes, isMe }
```

### 상태 처리
- **로딩**: Mock 데이터는 즉시 반환하되, Provider에서 `AsyncValue` 패턴 사용하여 향후 실제 API 전환 시 로딩 UI 자동 대응
- **에러**: 공통 에러 위젯 사용 (기존 패턴 따름)
- **랭킹 필터 상태**: 위젯 로컬 상태로 관리 (라우팅 미반영)

### Hero 태그
- 그룹 티켓 → 상세 전환: `group-ticket-{groupId}`

---

## 사용 에셋

- `assets/icons/icon_copy.svg` — 초대코드 복사 아이콘
- `assets/icons/barcode_lavender.svg` — 티켓 바코드
- 기존 `SpaceBackground` — 배경
- 기존 `RankingItem` — 랭킹 리스트 아이템
- 기존 `AppCard`, `AppButton` — 공통 UI 컴포넌트
