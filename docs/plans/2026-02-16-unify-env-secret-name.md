# ENV Secret Name Unification Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Unify the GitHub Actions secret name for `.env` file content across all 4 CI/CD workflows to `ENV_FILE`.

**Architecture:** Simple find-and-replace across 4 workflow YAML files. No logic changes, only secret reference name standardization.

**Tech Stack:** GitHub Actions YAML workflows

---

## Problem

The 4 workflow files reference the `.env` file content secret inconsistently:

| Workflow | Current Usage | Line(s) |
|----------|--------------|---------|
| `PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml` | `secrets.ENV_FILE` | 47 |
| `PROJECT-FLUTTER-ANDROID-TEST-APK.yaml` | `secrets.ENV` | 194 |
| `PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml` | `secrets.ENV_FILE \|\| secrets.ENV` | 142 |
| `PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml` | `secrets.ENV_FILE \|\| secrets.ENV` | 121 |

## Decision: Use `ENV_FILE`

**Why `ENV_FILE` over `ENV`:**
1. More descriptive - clearly indicates "this is the .env FILE content"
2. `ENV` is too generic - could be confused with environment-related secrets
3. Production workflow (PlayStore) already uses `ENV_FILE`
4. iOS workflows already prefer `ENV_FILE` as primary (fallback is secondary)

## Pre-requisite (Manual - GitHub Settings)

Before deploying, ensure the GitHub repository has:
- Secret named `ENV_FILE` with the `.env` file content
- (Optional) Remove old `ENV` secret after all workflows are updated and verified

---

### Task 1: Fix Android Test APK workflow

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml:193-196`

**Step 1: Update secret reference from `ENV` to `ENV_FILE`**

Change the "Create .env file" step (lines 193-196):

```yaml
# Before:
      - name: Create .env file
        run: |
          cat << 'EOF' > ${{ env.ENV_FILE_PATH }}
          ${{ secrets.ENV }}
          EOF
          echo "✅ ${{ env.ENV_FILE_PATH }} file created"

# After:
      - name: Create .env file
        run: |
          cat << 'EOF' > ${{ env.ENV_FILE_PATH }}
          ${{ secrets.ENV_FILE }}
          EOF
          echo "✅ ${{ env.ENV_FILE_PATH }} file created"
```

Also update the workflow header comment (line 28) to match:

```yaml
# Before:
#   - ENV                       : .env 파일 내용 (앱에서 사용하는 환경변수)

# After:
#   - ENV_FILE                  : .env 파일 내용 (앱에서 사용하는 환경변수)
```

**Step 2: Verify no other `secrets.ENV` references remain**

Run: `grep -n 'secrets\.ENV' .github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml`
Expected: No matches

**Step 3: Commit**

```bash
git add .github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml
git commit -m "fix: Android Test APK 워크플로우 ENV → ENV_FILE 시크릿 이름 통일"
```

---

### Task 2: Fix iOS TestFlight workflow (remove fallback)

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml`

**Step 1: Remove fallback pattern in prepare-build job**

Change line 142:

```yaml
# Before:
          ${{ secrets.ENV_FILE || secrets.ENV }}

# After:
          ${{ secrets.ENV_FILE }}
```

**Step 2: Remove fallback pattern in build-ios job**

Change line 326-327:

```yaml
# Before:
          ${{ secrets.ENV_FILE || secrets.ENV }}

# After:
          ${{ secrets.ENV_FILE }}
```

**Step 3: Update workflow header comment**

The Secrets section (around lines 34-38) references `ENV`. Update:

```yaml
# Before:
#   - ENV                             : .env 파일 내용 (앱에서 사용하는 환경변수)

# After:
#   - ENV_FILE                        : .env 파일 내용 (앱에서 사용하는 환경변수)
```

**Step 4: Verify no `secrets.ENV[^_]` references remain**

Run: `grep -n 'secrets\.ENV[^_F]' .github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml`
Expected: No matches

**Step 5: Commit**

```bash
git add .github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml
git commit -m "fix: iOS TestFlight 워크플로우 ENV fallback 제거, ENV_FILE로 통일"
```

---

### Task 3: Fix iOS Test TestFlight workflow (remove fallback)

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml`

**Step 1: Remove fallback pattern in prepare-test-build job**

Change line 121:

```yaml
# Before:
          ${{ secrets.ENV_FILE || secrets.ENV }}

# After:
          ${{ secrets.ENV_FILE }}
```

**Step 2: Remove fallback pattern in build-ios-test job**

Change line 351:

```yaml
# Before:
          ${{ secrets.ENV_FILE || secrets.ENV }}

# After:
          ${{ secrets.ENV_FILE }}
```

**Step 3: Update workflow header comment**

```yaml
# Before:
#   - ENV                             : .env 파일 내용 (앱에서 사용하는 환경변수)

# After:
#   - ENV_FILE                        : .env 파일 내용 (앱에서 사용하는 환경변수)
```

**Step 4: Verify no `secrets.ENV[^_]` references remain**

Run: `grep -n 'secrets\.ENV[^_F]' .github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml`
Expected: No matches

**Step 5: Commit**

```bash
git add .github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml
git commit -m "fix: iOS Test TestFlight 워크플로우 ENV fallback 제거, ENV_FILE로 통일"
```

---

### Task 4: Verify Android PlayStore workflow (already correct)

**Files:**
- Read: `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`

**Step 1: Confirm already using `ENV_FILE`**

Run: `grep -n 'secrets\.ENV' .github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`
Expected: Only `secrets.ENV_FILE` references (line 47)

No changes needed. This file is already correct.

---

### Task 5: Final cross-file verification

**Step 1: Check all workflows use only `ENV_FILE`**

Run: `grep -rn 'secrets\.ENV' .github/workflows/PROJECT-FLUTTER-*.yaml`

Expected output (all should be `ENV_FILE`, no bare `ENV`):
```
PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml:47:          echo "${{ secrets.ENV_FILE }}" > .env
PROJECT-FLUTTER-ANDROID-TEST-APK.yaml:194:          ${{ secrets.ENV_FILE }}
PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml:142:          ${{ secrets.ENV_FILE }}
PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml:327:          ${{ secrets.ENV_FILE }}
PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml:121:          ${{ secrets.ENV_FILE }}
PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml:351:          ${{ secrets.ENV_FILE }}
```

No bare `secrets.ENV` (without `_FILE` suffix) should appear.

---

## Post-Deployment Checklist

- [ ] Ensure `ENV_FILE` secret exists in GitHub repository settings
- [ ] Run each workflow once to verify `.env` file is created correctly
- [ ] (Optional) Remove old `ENV` secret from GitHub after confirming all workflows work
