## 제목
🚀 [기능개선][전역] 이모지 전면 제거 마이그레이션

## 본문

📝 현재 문제점
---

- 프로젝트 전역에 이모지가 산재 (UI 텍스트·코드 주석·문서·이슈 템플릿·슬래시 커맨드 본문)
- DESIGN.md 에서 이모지 전면 금지 규칙을 확정했으나 기존 코드·문서가 이 규칙을 위반 중
- 이모지는 플랫폼·폰트별 렌더링 차이가 있어 우주 테마의 일관된 분위기를 해침
- aerospace 영문 레이블 voice 와 이모지가 공존하면 톤이 충돌
- `.claude/scripts/check_design_violations.py` 훅이 신규 이모지 삽입은 경고하지만 기존 것은 그대로 남음

🛠️ 해결 방안
---

- 프로젝트 전역을 스캔해 이모지 문자를 모두 제거하거나 대체
- UI 에서 감정·상태 표현이 필요했던 자리는 `FaIcon(FontAwesomeIcons.xxx)` 또는 Material `Icons.xxx` 로 전환
- 문서·주석·커밋 이력·이슈 템플릿은 이모지를 텍스트 레이블 또는 섹션 제목으로 대체
- 기존 Material 아이콘 위젯 (`Icons.emoji_events_rounded` 같은 Flutter 내장 아이콘) 은 이모지가 아니므로 **유지**
- 마이그레이션 완료 후 `/review-design-system` 검증을 통과해야 종료

⚙️ 작업 범위
---

- **코드 (lib/)** — Dart 파일 내 이모지 리터럴, 주석, 로그 메시지
- **테스트 (test/)** — 테스트 파일 내 이모지
- **문서 (docs/)** — 00~08 rules 파일, API 명세서, PRD, UX 가이드, TOSS_UI_UX_DESIGN.md
- **이슈 템플릿 (docs/issues/)** — 기존 이슈 파일 및 템플릿의 이모지 헤더
- **슬래시 커맨드 (.claude/commands/)** — 커맨드 본문에 쓰인 이모지
- **서브에이전트 (.claude/agents/)** — 보고 템플릿의 이모지
- **파이프라인 문서 (.claude/rules/09_PIPELINE.md)** — ✅ ❌ 등 체크 이모지
- **README / CLAUDE.md / DESIGN.md** — 루트 문서
- **제외 대상** — Material Icons 위젯 (`Icons.emoji_events_rounded` 등 이름에 "emoji" 가 들어간 Flutter 내장 아이콘은 실제 이모지가 아님)

📋 검증 기준
---

- `grep -rnP "[\x{1F300}-\x{1F9FF}\x{2600}-\x{27BF}\x{1F600}-\x{1F64F}\x{1FA00}-\x{1FAFF}]"` 결과 0건
- `flutter analyze` 경고 0개
- `flutter test` 전체 통과
- 기존 UI 시각 확인 — 아이콘 대체 후 레이아웃이 깨지지 않음

💡 추가 요청 사항
---

- 대체 아이콘 선택 시 DESIGN.md Section 7 "Aerospace Dictionary" 톤과 어울리는 아이콘 우선
- 상태 표현이 아이콘 + 색상 조합으로 모호해지지 않도록 Section 6 Luminance Stack 원칙 준수
- 마이그레이션 후 `.claude/scripts/check_design_violations.py` 의 EMOJI_PATTERN 이 정상 동작하는지 재검증

🙋‍♂️ 담당자
---

- 백엔드: 이름
- 프론트엔드: 이름
- 디자인: 이름
