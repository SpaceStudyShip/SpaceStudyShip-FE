#!/usr/bin/env python3
"""
PostToolUse hook: Edit/Write 로 저장된 .dart 파일에서 DESIGN.md 위반을 경고한다.

차단하지는 않고 경고만 출력 (stderr, exit 0). 차단이 필요하면 exit 2 로 변경.

검사 항목:
1. Color(0xFF 하드코딩 (app_colors.dart 제외)
2. TextStyle( 인라인 (app_text_styles.dart 제외, .copyWith 제외)
3. BoxShadow / elevation
4. ElevatedButton / OutlinedButton / TextButton / Card(
5. 이모지
"""
import json
import os
import re
import sys

EMOJI_PATTERN = re.compile(
    r"[\U0001F300-\U0001F9FF"
    r"\U00002600-\U000027BF"
    r"\U0001F600-\U0001F64F"
    r"\U0001FA00-\U0001FAFF]"
)

CHECKS = [
    {
        "pattern": re.compile(r"Color\(0x[0-9A-Fa-f]{8}"),
        "exempt_files": {"app_colors.dart"},
        "message": "Color(0xFF) 리터럴 → AppColors.* 사용",
    },
    {
        "pattern": re.compile(r"Colors\.(blue|red|green|grey|yellow|orange|purple|pink|cyan|indigo|teal|amber|brown|white70|white60|white54|white38|black87)"),
        "exempt_files": set(),
        "message": "Material 색상 직접 사용 → AppColors.* 사용",
    },
    {
        "pattern": re.compile(r"TextStyle\("),
        "exempt_files": {"text_styles.dart", "app_text_styles.dart"},
        "exempt_lines": re.compile(r"\.copyWith\("),
        "message": "TextStyle(...) 인라인 정의 → AppTextStyles.* 사용",
    },
    {
        "pattern": re.compile(r"BoxShadow\("),
        "exempt_files": set(),
        "message": "BoxShadow 금지 → 루미넌스 스태킹 (spaceSurface → spaceElevated) 사용",
    },
    {
        "pattern": re.compile(r"(ElevatedButton|OutlinedButton|TextButton)\("),
        "exempt_files": set(),
        "message": "Material 버튼 직접 사용 → AppButton 사용",
    },
    {
        "pattern": re.compile(r"\bCard\("),
        "exempt_files": set(),
        "message": "Material Card 사용 → AppCard 사용",
    },
]


def check_file(path: str) -> list[str]:
    if not path.endswith(".dart"):
        return []

    basename = os.path.basename(path)
    violations = []

    try:
        with open(path, encoding="utf-8") as f:
            lines = f.readlines()
    except (OSError, UnicodeDecodeError):
        return []

    for i, line in enumerate(lines, start=1):
        # 주석 라인 스킵
        stripped = line.strip()
        if stripped.startswith("//") or stripped.startswith("///"):
            continue

        for check in CHECKS:
            if basename in check["exempt_files"]:
                continue
            if "exempt_lines" in check and check["exempt_lines"].search(line):
                continue
            if check["pattern"].search(line):
                violations.append(f"  {path}:{i} — {check['message']}")

        if EMOJI_PATTERN.search(line):
            violations.append(f"  {path}:{i} — 이모지 발견 (전면 금지)")

    return violations


def main() -> int:
    try:
        payload = json.loads(sys.stdin.read())
    except json.JSONDecodeError:
        return 0

    tool_name = payload.get("tool_name", "")
    if tool_name not in ("Edit", "Write", "MultiEdit"):
        return 0

    tool_input = payload.get("tool_input", {})
    file_path = tool_input.get("file_path", "")
    if not file_path or not file_path.endswith(".dart"):
        return 0

    violations = check_file(file_path)
    if violations:
        print(
            "⚠️  DESIGN.md 위반 감지 (저장은 완료, 수정 권장):",
            file=sys.stderr,
        )
        for v in violations:
            print(v, file=sys.stderr)
        print(
            "\n상세: DESIGN.md Section 2-4 및 /review-design-system 참조",
            file=sys.stderr,
        )

    return 0  # 경고만, 차단 안 함


if __name__ == "__main__":
    sys.exit(main())
