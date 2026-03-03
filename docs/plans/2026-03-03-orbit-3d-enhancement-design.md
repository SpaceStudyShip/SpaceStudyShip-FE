# 궤도 타이머 3D 입체감 강화 디자인

**Goal:** 항성-행성 공전 시스템의 pseudo-3D 효과를 강화하여 시작 직후부터 입체감이 느껴지도록 개선.

**현재 문제:** tilt가 0°에서 시작해 15분 후에야 최대 45°에 도달하므로, 초기에는 완전한 원 궤도 + 스케일 변화 없음 = 2D로 보임.

---

## 1. 초기 tilt 고정값

**현재:** `tilt = (π/4) × sin(progress × π)` → 0°~45°~0°

**변경:** `tilt = (π/12) + (π/6) × sin(progress × π)` → 15°~45°~15°

- 0분: tilt=15° (약간의 타원) → 즉시 3D 느낌
- 15분: tilt=45° (최대 타원)
- 스케일 변화: sin(15°)=0.26 → 시작부터 `1.0 ± 0.05` 원근 차이

**파일:** `orbit_timer_widget.dart` — `_tilt` getter 수정

## 2. 광원 회전 하이라이트

**현재:** `RadialGradient center: Alignment(-0.3, -0.3)` 고정

**변경:** `PlanetPainter`에 `lightAngle` 파라미터 추가

- `Alignment(cos(lightAngle) * -0.3, sin(lightAngle) * -0.3)`
- 행성 앞: lightAngle ≈ -0.8 (정면 하이라이트)
- 행성 뒤: lightAngle ≈ 2.3 (후면, 어두운 실루엣)
- OrbitTimerWidget에서 공전 각도 기반으로 lightAngle 계산·전달

**파일:** `planet_painter.dart`, `orbit_timer_widget.dart`

## 3. 항성 아래 타원 그림자

- 항성 중심에서 아래로 `starSize * 0.3` 오프셋
- 크기: `starSize × 0.7` (가로) × `starSize × 0.15` (세로, tilt 비례)
- 색상: 검정 10% opacity + MaskFilter.blur(8)
- 궤도 뒤쪽 반원: opacity 감소 (0.3→0.15)

**파일:** `orbit_timer_painter.dart` — `_drawStarShadow` 추가
