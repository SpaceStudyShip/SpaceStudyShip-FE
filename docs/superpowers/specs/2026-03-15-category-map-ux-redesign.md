# 카테고리 맵 UX 재설계 스펙

**작성일**: 2026-03-15
**이슈**: #56

## 개요

카테고리 시스템을 2열 그리드에서 **우주 맵 캔버스**(InteractiveViewer 기반 핀치 줌/패닝)로 재설계한다. 행성 SVG 아이콘들이 2D 캔버스에 배치되고, 중앙에 미분류 할일을 담당하는 "우주 정거장" 허브가 위치한다.

## 핵심 결정 사항

| 항목 | 결정 |
|------|------|
| 레이아웃 | 캔버스 자유 탐색 (옵시디언/Apple Watch 스타일) |
| 탐험 탭과 차별화 | 탐험 탭은 세로 지그재그, 카테고리 맵은 나선형 자유 배치 |
| 행성 위치 | 자동 배치 + 드래그로 조정 가능 (좌표 저장) |
| 행성 크기 | 할일 수에 비례 (48.w ~ 80.w) |
| 줌 레벨별 정보 | < 1.0 아이콘만, 1.0~1.5 +이름, > 1.5 +진행률 |
| 미분류 할일 | 캔버스 중앙 "우주 정거장" 고정 |
| 편집 인터랙션 | 롱프레스 → 컨텍스트 메뉴 (수정/위치이동/삭제) |
| 카테고리 상세 | 별도 화면 → DraggableScrollableSheet 바텀시트로 대체 |

---

## 1. 전체 구조

- **경로**: 기존 `/home/todo` 유지
- **AppBar**: "내 행성계" 타이틀 + `[+]` 카테고리 추가 + `[⋮]` 메뉴
- **캔버스**: `InteractiveViewer` — 핀치 줌 + 패닝
- **행성 탭** → DraggableScrollableSheet로 할일 목록
- **우주 정거장 탭** → 미분류 할일 바텀시트
- 기존 `CategoryTodoScreen` 라우트 제거

---

## 2. 캔버스 & InteractiveViewer

**줌 범위**: `minScale: 0.5` ~ `maxScale: 3.0`

| scale | 행성 | 우주 정거장 | 이름 | 진행률 |
|-------|------|-----------|------|--------|
| < 1.0 | 아이콘만 | 아이콘만 | 숨김 | 숨김 |
| 1.0~1.5 | 아이콘 + 이름 | 아이콘 + "미분류" | 표시 | 숨김 |
| > 1.5 | 아이콘 + 이름 + 진행률 | 아이콘 + "미분류" + 개수 | 표시 | 표시 |

- 텍스트 전환: `AnimatedOpacity`로 scale 임계값에 따라 페이드 인/아웃
- `TransformationController`에서 현재 scale 값 읽어서 조건부 렌더링
- 캔버스 크기: 뷰포트 대비 2~3배 (카테고리 수에 따라 동적), 최소 800x800 논리 픽셀
- 초기 로드 시: 모든 행성이 뷰포트 내에 보이도록 scale 자동 조정, 중앙 정거장 기준

### 줌 티어 최적화

`TransformationController.addListener`가 매 프레임 호출되므로, 직접 setState 하면 과도한 리빌드 발생.
**줌 티어 enum**으로 임계값 교차 시에만 상태 갱신:

```dart
enum ZoomTier { far, normal, close }
// < 1.0 → far, 1.0~1.5 → normal, > 1.5 → close
```

- `ValueNotifier<ZoomTier>`로 관리
- 현재 scale이 임계값을 넘을 때만 `value` 변경 → `ValueListenableBuilder`로 구독
- 각 행성 노드는 `ZoomTier`만 받아서 렌더링 결정

### 레이아웃 구조 (SpaceBackground 통합)

```dart
Scaffold(
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),  // 줌/패닝 영향 없음
      InteractiveViewer(
        // 캔버스 콘텐츠 (행성, 정거장)
      ),
    ],
  ),
)
```

`SpaceBackground`는 InteractiveViewer 밖에 배치하여 줌/패닝과 독립적으로 유지.

---

## 3. 행성 노드 (카테고리)

### 크기 계산
- 기본: `48.w`
- 할일 수 반영: `48.w + (todoCount * 4.w)`, 최대 `80.w`
- 할일 0개면 기본 크기 유지

### 비주얼
- `CategoryIcons.buildIcon(iconId)` — 기존 Planet SVG 사용
- 줌 레벨에 따라 아래에 이름/진행률 텍스트
- 탭 피드백: `TossDesignTokens.cardTapScale`

### 제스처 충돌 해결 전략

`InteractiveViewer`는 pan 제스처를 소비하므로 자식 위젯의 탭/롱프레스와 충돌 가능.

**해결 방법**:
- 각 행성 노드를 `GestureDetector(behavior: HitTestBehavior.opaque)`로 래핑
- `InteractiveViewer`의 `interactionEndFrictionCoefficient`와 `panEnabled`를 상태에 따라 제어
- 행성 노드 영역 내 터치 → `GestureDetector`가 우선 소비 (탭/롱프레스)
- 행성 노드 바깥 터치 → `InteractiveViewer`가 패닝 처리
- 드래그 모드 중에는 `InteractiveViewer.panEnabled = false`

### 인터랙션
- **탭** → 할일 바텀시트 열기
- **롱프레스** → 컨텍스트 메뉴 팝업
  - 수정 (이름/아이콘 변경 바텀시트)
  - 위치 이동 (드래그 모드 진입)
  - 삭제 (확인 다이얼로그)

### 드래그 모드
- 컨텍스트 메뉴에서 "위치 이동" 선택 시 진입
- 행성에 그림자 + scale 1.1 효과
- `InteractiveViewer.panEnabled = false` (충돌 방지)
- 드래그 중 좌표는 로컬 상태로만 반영 (UI 업데이트)
- **드래그 종료(손 떼면) 시에만** 좌표를 Provider에 저장 + 드래그 모드 해제

---

## 4. 우주 정거장 (미분류 허브)

- 캔버스 중앙 고정 (`(0.5, 0.5)`)
- 크기: `64.w` 고정 (할일 수로 스케일하지 않음)
- 플레이스홀더: `Icons.space_dashboard_rounded` → 추후 전용 SVG 교체
- **탭** → 미분류 할일 바텀시트 (행성 바텀시트와 동일 구조)
- **롱프레스** → 없음 (이동/삭제 불가)

---

## 5. 카테고리 할일 바텀시트

`CategoryTodoScreen`을 대체하는 `DraggableScrollableSheet`.

### 스냅 사이즈
- `0.4`: 미리보기 — 헤더 + 할일 2~3개
- `0.7`: 기본 — 전체 목록 스크롤
- `0.9`: 최대 확장

### 구조
```
┌─────────────────────────────┐
│         ── (DragHandle)      │
│  🪐 수학          3/7 완료   │
│─────────────────────────────│
│  + 할 일 추가                │
│─────────────────────────────│
│  ☐ 미적분 복습               │
│  ☐ 문제풀이 30번~50번        │
│  ☑ 공식 정리 (완료)          │
└─────────────────────────────┘
```

- 헤더: DragHandle + 행성 아이콘 + 카테고리명 + 진행률
- 할일 목록: 기존 `DismissibleTodoItem` 재사용
- 추가 버튼: 탭 → `TodoAddBottomSheet` (initialCategoryIds 전달)
- `showAppBottomSheet` 패턴 적용

### 캔버스 인터랙션 분리

바텀시트가 열린 상태에서 캔버스 터치 충돌 방지:
- 바텀시트 열림 → `InteractiveViewer.panEnabled = false`, 줌도 비활성화
- 바텀시트 닫힘 → 복원
- 바텀시트 바깥(캔버스 영역) 탭 → 바텀시트 dismiss

---

## 6. 자동 배치 알고리즘

중앙 우주 정거장 기준 **나선형 배치**.

- 중심점: `(0.5, 0.5)`
- 첫 번째 고리: 반지름 `0.15`, 최대 6개 (균등 각도)
- 두 번째 고리: 반지름 `0.30`, 최대 12개
- 카테고리 20개까지 수용
- 충돌 방지: 기존 행성과 최소 거리 체크, 겹치면 각도 회전

### 캔버스 크기 동적 조정
- 1~6개: `800 x 800`
- 7~12개: `1200 x 1200`
- 13개 이상: `1600 x 1600`

### 좌표 체계
- `0.0 ~ 1.0` 정규화 좌표로 저장 (기기 해상도 무관)
- 렌더링 시 캔버스 크기에 곱해서 실제 픽셀 위치 계산

---

## 7. 데이터 모델 변경

### TodoCategoryEntity
```dart
@freezed
class TodoCategoryEntity with _$TodoCategoryEntity {
  const factory TodoCategoryEntity({
    required String id,
    required String name,
    String? iconId,
    double? positionX,    // 추가 (nullable = 자동배치)
    double? positionY,    // 추가 (nullable = 자동배치)
    required DateTime createdAt,
    DateTime? updatedAt,  // 기존 코드와 동일: nullable
  }) = _TodoCategoryEntity;
}
```

### TodoCategoryModel
- `@JsonKey(name: 'position_x') double? positionX`
- `@JsonKey(name: 'position_y') double? positionY`

### 하위 호환성

기존 SharedPreferences에 저장된 카테고리 JSON에는 `position_x`/`position_y` 키가 없음.
- `json_serializable`의 기본 동작: 누락된 키 → `null` 할당 (nullable 필드)
- `null` position → 자동 배치 알고리즘 적용
- **별도 마이그레이션 불필요** — 기존 데이터는 자연스럽게 자동 배치로 처리됨

### Provider
- `updateCategoryPosition(String id, double x, double y)` 추가
- 기존 `updateCategory`의 `copyWith`으로 처리 (별도 UseCase 불필요)
- 드래그 종료 시에만 호출 (드래그 중은 로컬 상태)

### 맵 UI 상태 (Riverpod)

```dart
// 드래그 모드 중인 행성 ID (null = 일반 모드)
final draggingPlanetIdProvider = StateProvider<String?>((ref) => null);

// 바텀시트에서 열린 카테고리 ID (null = 닫힘)
final openCategoryIdProvider = StateProvider<String?>((ref) => null);
```

---

## 8. 파일 구조

### 새로 생성
```
lib/features/todo/presentation/screens/category_map_screen.dart        — 캔버스 메인
lib/features/todo/presentation/widgets/planet_map_node.dart             — 행성 노드 위젯
lib/features/todo/presentation/widgets/space_station_node.dart          — 우주 정거장 위젯
lib/features/todo/presentation/widgets/category_todo_bottom_sheet.dart  — 할일 바텀시트
lib/features/todo/presentation/widgets/planet_context_menu.dart         — 롱프레스 컨텍스트 메뉴
```

### 수정
```
lib/features/todo/domain/entities/todo_category_entity.dart    — positionX/Y 추가
lib/features/todo/data/models/todo_category_model.dart         — positionX/Y 추가
lib/features/todo/presentation/providers/todo_provider.dart    — updateCategoryPosition 추가
lib/routes/app_router.dart                                     — todo 라우트 변경
```

### 삭제
```
lib/features/todo/presentation/screens/todo_list_screen.dart       — 캔버스로 대체
lib/features/todo/presentation/screens/category_todo_screen.dart   — 바텀시트로 대체
lib/features/todo/presentation/widgets/category_card.dart          — 행성 노드로 대체
```

### 유지 (재사용)
```
category_add_bottom_sheet.dart     — 카테고리 추가/수정
category_select_bottom_sheet.dart  — 다중 카테고리 선택
todo_add_bottom_sheet.dart         — 할일 추가
dismissible_todo_item.dart         — 할일 아이템 (바텀시트 내 재사용)
```

---

## 9. 라우트 변경

### 제거
- `/home/todo/category/:categoryId` (CategoryTodoScreen)

### 유지
- `/home/todo` → `CategoryMapScreen` (기존 TodoListScreen 대체)
- `/home/todo/:id` (todoDetail, 플레이스홀더)

### 영향 범위 확인 필요
- `RoutePaths.categoryTodoPath()` 사용처를 grep으로 확인하고 모두 제거
- `CategoryTodoScreen` import 참조도 제거
- `CategoryCard` import 참조도 제거
- `TodoListScreen` import 참조를 `CategoryMapScreen`으로 교체

---

## 10. 접근성

- 각 행성 노드에 `Semantics(label: '$categoryName 카테고리, 할일 $todoCount개')` 적용
- 우주 정거장에 `Semantics(label: '미분류 할일 $count개')` 적용
- 줌 레벨과 무관하게 스크린 리더는 항상 전체 정보 읽기

---

## 11. 제약 사항

- 카테고리 최대 20개 (CategoryIcons.presets 기반). 20개 초과 시 추가 버튼 비활성화 + 안내 메시지
- 컨텍스트 메뉴는 Flutter `showMenu` 사용 (화면 가장자리 자동 클램핑 지원)
- 드래그 모드 중 다른 행성과 겹칠 경우 시각적 경고 없이 배치 허용 (v1)
