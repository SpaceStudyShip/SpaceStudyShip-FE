# 타이머 모드 선택 (기본 타이머 + Lottie) 디자인

**Goal:** 기존 원형 프로그레스 링 타이머를 Lottie 애니메이션과 함께 선택 가능하게 하여, 사용자가 원하는 타이머 스타일을 선택할 수 있게 한다.

---

## 1. TimerAnimationSelector 바텀시트

- 현재 Lottie 2종 목록 맨 위에 **"기본 타이머"** 항목 추가
- 기본 타이머 미리보기: 64x64 크기의 정적 원형 링 (CustomPaint)
- 선택 값: `'basic'` (Lottie asset 경로가 아닌 특수 값)

## 2. TimerScreen 분기

- `timerAnimationNotifierProvider` 값에 따라:
  - `'basic'` → TimerRingPainter + 중앙 시간 텍스트 (원래 타이머)
  - Lottie asset 경로 → LottieTimerWidget (현재)

## 3. TimerRingPainter 복원

- 삭제한 `timer_ring_painter.dart` 복원
- 기존 코드 그대로 사용

## 4. 상태 저장

- 기존 `timerAnimationNotifierProvider`가 SharedPreferences에 `'basic'` 또는 Lottie 경로 저장
- 기본값: `'basic'` (기존 사용자 경험 유지)

## 5. 수정 대상

- `timer_animation_selector.dart` — 기본 타이머 항목 추가 + 미리보기
- `timer_screen.dart` — 모드에 따라 위젯 분기
- `timer_ring_painter.dart` — 복원
- `timer_animation_provider.dart` — 기본값 변경
