# Calendar + Todo 연동 설계 문서

## 목표

홈 화면 하단 시트를 캘린더 통합 시트로 개편하여, 투두메이트 스타일의 날짜 기반 할일 관리 기능을 구현한다. SpaceshipAvatar(앱 정체성)를 유지하면서 depth 0에서 캘린더에 접근 가능하도록 한다.

## 핵심 결정 사항

| 항목 | 결정 |
|------|------|
| 캘린더 위치 | 홈 화면 DraggableScrollableSheet 내부 |
| 캘린더 라이브러리 | `table_calendar` |
| 날짜 모델 | `scheduledDate: DateTime?` (nullable, 미지정 허용) |
| 캘린더 뷰 | 접힌 상태: 주간 1줄 / 펼친 상태: 월간 풀 캘린더 |
| 기존 TodoListScreen | 카테고리 관리 전용으로 유지 (변경 최소) |

## 데이터 모델 변경

### TodoEntity

```dart
@freezed
class TodoEntity with _$TodoEntity {
  const factory TodoEntity({
    required String id,
    required String title,
    @Default(false) bool completed,
    String? categoryId,
    int? estimatedMinutes,
    int? actualMinutes,
    DateTime? scheduledDate,   // ← 신규: 예정일 (null = 미지정)
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TodoEntity;
}
```

- **null**: 날짜 미지정 할일 (기존 할일 호환)
- **기본값**: 새 할일 생성 시 오늘 날짜
- **마이그레이션**: SharedPreferences JSON에서 `scheduledDate` 키 없으면 자동 null 처리 (Freezed default)

### TodoModel

TodoModel에도 동일하게 `scheduledDate` 추가 + `toEntity()`/`toModel()` 변환 Extension 갱신

## UI 설계

### 홈 화면 하단 시트 — 접힌 상태

```
┌──────────────────────────┐
│     🚀 SpaceshipAvatar    │  ← 유지
├──────────────────────────┤
│ ◀ 10  11  12 ⓬ 14  15  16 ▶│  ← 주간 캘린더 스트립
│      ·       ·  ●      ·   │     (● = 오늘, · = 할일 있음)
│ ──────────────────────── │
│ 📋 오늘의 할일     더보기 > │
│ □ 알고리즘 풀기            │
│ ☑ 독서 30분               │
└──────────────────────────┘
```

- 주간 스트립: 가로 스크롤, 오늘 날짜 하이라이트
- 날짜 탭 → 해당 날짜 할일로 전환
- "더보기" → TodoListScreen (카테고리 관리)

### 홈 화면 하단 시트 — 펼친 상태

```
┌──────────────────────────┐
│ [월간 ▼]   ◀ 2026년 2월 ▶  │  ← 월간/주간 토글
│ 일  월  화  수  목  금  토  │
│                   1   2   3 │
│  4   5   6   7   8   9  10 │
│ 11  12 ⓬  14  15  16  17  │
│ 18  19  20  21  22  23  24 │
│ 25  26  27  28             │
│ ──────────────────────── │
│ 📋 2/16 할일        + 추가 │
│ □ Flutter 캘린더 구현      │
│ □ 알고리즘 풀기            │
│ ──────────────────────── │
│ 📋 날짜 미지정             │
│ □ 언젠가 읽을 책 정리      │
└──────────────────────────┘
```

- table_calendar의 `CalendarFormat.month` / `CalendarFormat.week` 전환
- 할일 있는 날짜에 도트 마커
- 선택된 날짜의 할일 목록
- "날짜 미지정" 섹션 (scheduledDate == null)
- "+ 추가" → 선택된 날짜로 scheduledDate 자동 지정

### TodoAddBottomSheet 변경

- 기존: 제목 + 카테고리 칩
- 변경: 제목 + 카테고리 칩 + **날짜 선택 칩** (기본: 오늘)

## 기존 화면 영향 분석

| 화면 | 변경 | 설명 |
|------|------|------|
| HomeScreen | **대폭 변경** | 시트에 주간/월간 캘린더 통합 |
| TodoListScreen | 최소 변경 | 카테고리 관리 전용 유지, "날짜 미지정" 표시 추가 가능 |
| TodoAddBottomSheet | 중간 변경 | 날짜 선택 UI 추가 |
| CategoryTodoScreen | 변경 없음 | 카테고리별 할일 표시 유지 |
| TimerScreen | 변경 없음 | 할일 선택 시 scheduledDate 무관 |

## 캘린더 라이브러리: table_calendar

- pub.dev 인기 1위 Flutter 캘린더
- 월간 ↔ 주간 전환 기본 지원
- 도트 마커 커스터마이징
- 한국어 로케일 (intl 패키지 연동)
- 우주 테마 커스텀 스타일링 가능

## 작업 순서

1. TodoEntity/TodoModel에 `scheduledDate` 필드 추가 + build_runner
2. `table_calendar` 의존성 추가 + intl 로케일 초기화
3. 홈 화면 시트에 주간 캘린더 스트립 추가 (접힌 상태)
4. 시트 펼친 상태에서 월간 캘린더 표시
5. 날짜 선택 → 해당 날짜 할일 필터링
6. TodoAddBottomSheet에 날짜 선택 추가
7. 캘린더에 할일 도트 마커 표시
8. 날짜 미지정 할일 섹션 처리
