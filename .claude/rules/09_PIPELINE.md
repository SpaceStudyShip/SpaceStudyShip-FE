# 09 — Workflow Pipeline

> **역할:** Space Study Ship 프로젝트의 작업 파이프라인 정의. Claude 가 복잡한 작업을 받았을 때 따라야 할 단계를 명시한다.
> **Last Updated:** 2026-04-13

---

## 파이프라인 전체 흐름

```
사용자 요청
  │
  ├─ 단순 작업 (1-파일 수정·버그 픽스·문서 업데이트)
  │   └─ 바로 Edit/Write 진행
  │
  └─ 복잡 작업 (신규 기능·리팩터링·여러 파일 수정)
      │
      ├─ 1. superpowers:brainstorming
      │     → docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md
      │
      ├─ 2. superpowers:writing-plans
      │     → docs/superpowers/plans/YYYY-MM-DD-<topic>-plan.md
      │     (Phase / Task 분할, 각 Task 는 단일 책임)
      │
      ├─ 3. superpowers:execute-plan
      │     → Plan 을 subagent 로 분산 실행
      │     (각 subagent 는 하나의 Task 담당)
      │
      ├─ 4. 각 Task 내부: superpowers:test-driven-development
      │     → RED (실패 테스트 작성)
      │     → GREEN (최소 구현으로 통과)
      │     → REFACTOR (개선)
      │
      ├─ 5. superpowers:verification-before-completion
      │     → flutter analyze 통과 확인
      │     → design-guardian grep 셀프체크
      │     → 모든 테스트 통과 확인
      │
      └─ 6. /commit
            → Claude 태그 금지 (hook 으로 강제)
            → 메시지 포맷: "<type> : <한글 설명>"
```

---

## 단계별 규칙

### 1. Brainstorming — superpowers:brainstorming

**언제:** 요구사항이 모호하거나 여러 가지 접근이 가능한 경우.

**산출물:** `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`

**스킵 조건:**
- 수정 범위가 단일 파일 안에서 끝나는 버그 픽스
- 이미 spec 이 존재하는 재작업 (기존 spec update 로 충분할 때)

**금지:**
- Spec 없이 바로 plan 으로 넘어가기
- Spec 작성 도중 코드 작성 시작

---

### 2. Writing Plans — superpowers:writing-plans

**언제:** Spec 이 승인된 직후.

**산출물:** `docs/superpowers/plans/YYYY-MM-DD-<topic>-plan.md`

**Plan 구조 (Phase → Task):**

```markdown
## Phase 1: <기반 작업>
- Task 1.1: <단일 책임 작업>
  - Files: [수정/생성할 파일 목록]
  - Tests: [작성할 테스트 목록]
  - Depends on: -

- Task 1.2: ...
```

**각 Task 는:**
- 하나의 서브에이전트가 단독으로 수행 가능해야 한다
- 명확한 완료 조건 (tests pass + analyze clean)
- 다른 Task 의존성을 명시

**금지:**
- Plan 없이 구현 시작
- Task 간 암묵적 의존성 (명시되지 않은 순서)

---

### 3. Execute Plan — superpowers:execute-plan

**언제:** Plan 이 승인된 직후.

**방식:** Plan 의 각 Task 를 서브에이전트에게 위임. 의존성이 없는 Task 는 **병렬** 디스패치, 있는 것은 순차.

**각 subagent 에게 전달:**
- Task 내용
- 관련 파일 경로
- DESIGN.md 및 관련 rules 참조 지시
- TDD 사이클 필수

**주의:**
- Main context 는 subagent 결과만 수신 (풀 로그 수신 금지)
- 실패 시 재시도 또는 main thread 로 escalate

---

### 4. TDD — superpowers:test-driven-development

**필수 사이클:**

1. **RED**: 실패하는 테스트 먼저 작성
   - `test/` 디렉토리에 _test.dart 파일
   - Widget 이면 `flutter_test`, Unit 이면 `test`
   - `flutter test` 실행해서 **실패 확인**

2. **GREEN**: 최소 구현으로 테스트 통과
   - 과도한 설계 금지, 테스트가 요구하는 것만
   - `flutter test` 통과 확인

3. **REFACTOR**: 구조 개선
   - 중복 제거, 네이밍 개선, 추상화
   - 매번 `flutter test` 재실행

**Coverage 목표:** 80% 이상 (`~/.claude/rules/testing.md` 기준)

**금지:**
- 구현 먼저 쓰고 테스트 나중에
- 테스트 없이 기능 추가
- 실패 확인 없이 GREEN 로 넘어가기

---

### 5. Verification — superpowers:verification-before-completion

**체크리스트 (자동 + 수동):**

- [ ] `flutter analyze` — 경고 0개
- [ ] `flutter test` — 모든 테스트 통과
- [ ] `flutter-design-guardian` grep 셀프체크 통과
- [ ] UI 작업이라면 실제 디바이스/에뮬레이터에서 시각 확인
- [ ] DESIGN.md 9.C "제출 전 최종 검증" 항목 모두 통과

**금지:**
- 검증 없이 "완료" 선언
- 테스트 일부만 돌리고 통과 판정

---

### 6. Commit — /commit

**형식:**
```
<type> : <한글 설명> #<이슈번호>
```

**타입:** `feat` / `fix` / `refactor` / `style` / `chore` / `docs` / `test`

**절대 금지 (hook 으로 차단):**
- `Co-Authored-By: Claude`
- `🤖 Generated with Claude Code`
- `Claude Sonnet` / `Claude Opus` / `Claude Haiku` 등 모델명
- 이모지 (🚀 ✅ ❌ 등)

**다중 파일 변경 시:**
- 가능하면 논리적 단위로 나눠 커밋
- `git add <specific>` 우선, `git add -A` 금지

---

## 스킵 가이드

**파이프라인 전체 스킵 가능:**
- 타입 체크만 고치는 one-liner
- 오타 수정
- 주석 추가/수정
- 문서 업데이트 (단, DESIGN.md·rules 변경은 full 파이프라인)

**부분 스킵 가능:**
- 스펙 있지만 plan 없음 → writing-plans 부터 시작
- Plan 까지 있음 → execute-plan 부터 시작

**절대 스킵 불가:**
- Verification 단계 (flutter analyze / test)
- Commit 태그 검증
