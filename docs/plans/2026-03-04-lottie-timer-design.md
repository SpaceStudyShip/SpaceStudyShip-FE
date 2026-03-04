# 타이머 Lottie 애니메이션 전환 디자인

**Goal:** CustomPaint 궤도 시스템을 Lottie 애니메이션 기반으로 교체하여, 우주공부선 테마에 맞는 시각적 경험을 제공한다.

---

## 1. LottieTimerWidget

- Lottie 애니메이션을 재생/정지하는 타이머 비주얼 위젯
- running: 애니메이션 연속 재생 (repeat)
- paused: 현재 프레임에서 정지
- idle: 첫 프레임 고정 표시
- 탭 시 TimerAnimationSelector 바텀시트 호출
- 시간 표시는 AppBar에서 처리 (위젯 내 시간 텍스트 없음)

**파일:** `lib/features/timer/presentation/widgets/lottie_timer_widget.dart`

## 2. TimerAnimationSelector

- SpaceshipSelector 패턴 참고한 바텀시트
- 2종 애니메이션 선택:
  - `assets/lotties/Earth_and_Connections.json`
  - `assets/lotties/Planet_earth_and rocket.json`
- 선택 상태 SharedPreferences 저장 (키: `timer_lottie_asset`)
- Lottie 미리보기 + 이름 표시

**파일:** `lib/features/timer/presentation/widgets/timer_animation_selector.dart`

## 3. 삭제 대상

- `lib/features/timer/presentation/widgets/orbit_timer_widget.dart`
- `lib/features/timer/presentation/widgets/orbit_timer_painter.dart`
- `lib/features/timer/presentation/widgets/planet_painter.dart`
- `lib/features/timer/presentation/models/planet_style.dart`
- `docs/plans/2026-03-03-orbit-3d-enhancement-design.md`
- `docs/plans/2026-03-03-orbit-3d-enhancement-impl.md`

## 4. 수정 대상

- `lib/features/timer/presentation/screens/timer_screen.dart` — OrbitTimerWidget → LottieTimerWidget 교체
