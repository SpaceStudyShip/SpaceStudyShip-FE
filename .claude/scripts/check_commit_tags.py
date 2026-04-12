#!/usr/bin/env python3
"""
PreToolUse hook: git commit 메시지에서 Claude 태그를 차단한다.

stdin 으로 JSON 입력을 받고, 커밋 메시지에 금지 패턴이 있으면 exit 2 로 차단.

금지 패턴:
- Co-Authored-By: Claude
- Generated with Claude Code
- Claude Sonnet / Claude Opus / Claude Haiku
- 🤖 이모지
"""
import json
import re
import sys

FORBIDDEN_PATTERNS = [
    (r"Co-Authored-By:\s*Claude", "Co-Authored-By: Claude 태그 금지"),
    (r"Generated with.*Claude", "Generated with Claude 푸터 금지"),
    (r"Claude\s*(Sonnet|Opus|Haiku)", "Claude 모델명 언급 금지"),
    (r"🤖", "🤖 이모지 금지"),
    (r"claude\.com/code", "claude.com/code URL 금지"),
]


def main() -> int:
    try:
        payload = json.loads(sys.stdin.read())
    except json.JSONDecodeError:
        return 0  # 입력 파싱 실패 시 차단하지 않음

    tool_name = payload.get("tool_name", "")
    if tool_name != "Bash":
        return 0

    command = payload.get("tool_input", {}).get("command", "")
    if "git commit" not in command:
        return 0

    violations = []
    for pattern, description in FORBIDDEN_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            violations.append(description)

    if violations:
        msg = "커밋 메시지 규칙 위반:\n"
        for v in violations:
            msg += f"  - {v}\n"
        msg += "\n.claude/rules/09_PIPELINE.md 의 Commit 규칙 참조. 태그를 제거하고 다시 시도하세요."
        print(msg, file=sys.stderr)
        return 2  # 차단

    return 0


if __name__ == "__main__":
    sys.exit(main())
