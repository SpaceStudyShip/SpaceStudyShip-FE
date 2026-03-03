# 항성-행성 공전 타이머 UI 디자인

## 컨셉

타이머 화면을 우주 테마에 맞게 리디자인. 중앙에 **항성**(공부 에너지의 원천)을 배치하고, **행성**이 궤도를 따라 공전하여 타이머 진행 상태를 시각화한다. pseudo-3D 원근감 궤도로 시간 경과에 따른 시각적 변화를 제공.

## 핵심 요소

| 요소 | 렌더링 | 크기 | 역할 |
|------|--------|------|------|
| 항성 (중앙) | CustomPaint 그라데이션 구체 | ~60w | 타이머의 중심, 에너지 원천 |
| 행성 (공전) | CustomPaint 그라데이션 구체 | ~20w (원근 변화) | 진행률 표시 |
| 궤도 | CustomPaint 타원/원 | 반지름 ~120w | 경로 표시, 진행 구간 강조 |
| 시간 텍스트 | Text (timer_48) | 48sp | 항성 바로 아래, 가독성 최우선 |
| 꼬리 | CustomPaint 그라데이션 arc | 행성 뒤 ~20° | running 시 공전 방향 표시 |

## pseudo-3D 궤도 시스템

### 공전 주기
- **30분 = 1바퀴** (연료 시스템과 동기화)
- `angle = (elapsed.inSeconds % 1800) / 1800 * 2π`

### 기울기 변화 (30분 1사이클)
- 0분: tilt=0° → 완전한 원 (2D)
- 7분: tilt=22° → 약간 타원
- 15분: tilt=45° → 최대 타원 (가장 3D 느낌)
- 22분: tilt=22° → 다시 줄어듦
- 30분: tilt=0° → 원형으로 복귀 → 반복

### 위치/크기 계산
```
x = radius * cos(angle)
y = radius * sin(angle) * cos(tilt)   // Y축 압축 = 타원 효과

depthFactor = sin(angle)               // -1(뒤) ~ +1(앞)
scale = 1.0 + 0.2 * depthFactor * sin(tilt)  // 원근 스케일링
opacity = 0.7 + 0.3 * (depthFactor + 1) / 2  // 원근 투명도
```

### Z-order
- `depthFactor > 0`: 행성이 항성 앞에 그려짐 (크게)
- `depthFactor < 0`: 행성이 항성 뒤에 그려짐 (작게, 반투명)

## 렌더링: CustomPaint 그라데이션 구체

### 항성 (중앙)
```
RadialGradient:
  center: Alignment(-0.3, -0.3)  // 좌상단 하이라이트
  colors: [highlightColor, baseColor, shadowColor]
  stops: [0.0, 0.5, 1.0]
+ 외곽 글로우: 블러 필터, baseColor 20% opacity
```

기본 항성 색상: `AppColors.accentGold` 계열 (태양 느낌)

### 행성 (공전체)
동일한 그라데이션 구체 로직, 작은 크기.

기본 행성 색상: `AppColors.primary` 계열 (파랑)

### PlanetStyle 추상화
```dart
class PlanetStyle {
  final Color baseColor;
  final Color highlightColor;
  final Color shadowColor;
  final Color? glowColor;
}
```
향후 탐험 시스템 연동 시 행성별 PlanetStyle 매핑으로 커스터마이징 가능.

## 상태별 시각 변화

### Idle
- 항성: 정지, 은은한 기본 글로우
- 행성: 3시 방향 고정 (angle=0), 정상 크기
- 궤도: `AppColors.spaceDivider` 색상 점선
- 글로우/꼬리: 없음
- 텍스트: `Colors.white`, `00:00:00`

### Running
- 항성: pulse 글로우 (3초 주기, 밝기 0.8↔1.0)
- 행성: 궤도 따라 공전 + 크기/투명도 원근 변화
- 궤도: `AppColors.primary` 실선 + 진행 구간 글로우
- 꼬리: 행성 뒤 ~20° 그라데이션 arc (primary → 투명)
- 텍스트: `AppColors.primary`

### Paused
- 항성: pulse 정지, 기본 글로우만
- 행성: 현재 위치 고정 + 불투명도 깜박임 (1.0↔0.3, 1초 주기)
- 궤도: `AppColors.timerPaused` (주황) 실선
- 글로우/꼬리: fade out
- 텍스트: `Colors.white`

## 레이아웃

기존 타이머 화면 구조 유지. 타이머 링 영역만 교체.

```
┌────────────────────────────────┐
│  [AppBar] 타이머         📋    │
│                                │
│             🌍 (작게, 뒤)       │
│          ·  ·  ·  ·  ·        │
│        ·                 ·     │
│      ·       ⭐️           ·   │ ← 항성 (CustomPaint)
│      ·     00:45:30       ·   │ ← 시간 텍스트
│        ·                 ·     │
│          ·  ·🌍·  ·  ·        │ ← 행성 (크게, 앞)
│                                │
│       [일시정지]    [종료]       │
│                                │
│    ┌──────────────────────┐    │
│    │ 오늘 │ 이번주 │ 연속 │    │
│    └──────────────────────┘    │
└────────────────────────────────┘
```

변경 범위:
- 기존 `TimerRingPainter` → `OrbitTimerPainter`로 교체
- 기존 버튼, 통계 카드, AppBar: 변경 없음

## 파일 구조

```
lib/features/timer/presentation/
├── widgets/
│   ├── timer_ring_painter.dart         ← 기존 유지
│   ├── orbit_timer_painter.dart        ← 신규: 궤도 + 글로우 + 꼬리
│   ├── planet_painter.dart             ← 신규: 그라데이션 구체 렌더링
│   └── orbit_timer_widget.dart         ← 신규: 전체 조합 (항성+행성+궤도+상태)
├── screens/
│   └── timer_screen.dart               ← 수정: OrbitTimerWidget으로 교체

lib/features/timer/presentation/models/
│   └── planet_style.dart               ← 신규: PlanetStyle 데이터 클래스
```

## 성능 고려

- AnimationController 2개: 행성 공전 (UI 틱 기반), 항성 pulse (3초 주기)
- 행성 위치: 기존 1초 타이머 틱과 동기화 (별도 컨트롤러 불필요)
- pseudo-3D 계산: cos/sin 4회 — 무시 가능
- `RepaintBoundary`로 궤도 영역 격리 (SpaceBackground 리페인트 방지)
- `shouldRepaint`: progress, isRunning, tilt 변경 시에만

## 향후 확장 (별도 이슈)

- 탐험 시스템 연동: 해금한 행성을 타이머에 설정
- 행성별 고유 PlanetStyle (색상, 패턴)
- 다중 행성 궤도 (장시간 공부 시 행성 추가)
