# 소셜 화면 구역 레이블 리네임 디자인 스펙

**이슈:** #67
**작성일:** 2026-04-14
**상태:** 승인됨

## 변경 내용

기술적 느낌의 영문 레이블을 우주선+항해 테마의 한국어로 교체한다.

| 현재 | 변경 | 조건 |
|------|------|------|
| `HIGH ORBIT` | `전속력` | 공부 중 90분 이상 |
| `LOW ORBIT` | `이륙 중` | 공부 중 90분 미만 |
| `DOCKED` | `충전 중` | 오프라인/대기 |
| `나 (YOU)` | `선장` | 내 ShipNode 레이블 |

## 변경 파일

- `lib/features/social/presentation/widgets/social_space_view.dart` — 구역 레이블 3개
- `lib/features/social/presentation/widgets/ship_node.dart` — isMe 레이블
- 관련 테스트 파일 동기화
