# Fastlane Gem 의존성 충돌 해결 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** GitHub Actions에서 Ruby 3.4.1 환경의 gem 충돌로 인한 Fastlane 설치/실행 실패 해결

**Architecture:** `gem install fastlane --force`만으로는 설치는 성공하지만 런타임 `CFPropertyList` 의존성 충돌이 남음. 충돌하는 사전 설치 gem을 제거한 후 fastlane을 클린 설치하는 방식으로 해결.

**Tech Stack:** GitHub Actions, Ruby 3.4.1, Fastlane, RubyGems

---

## 문제 분석

### 에러 1 (해결됨): 실행파일 충돌
```
ERROR: Error installing fastlane:
  "console" from fastlane conflicts with installed executable from retriable
```
- `--force`로 해결됨

### 에러 2 (미해결): 런타임 의존성 충돌
```
Gem::Molinillo::VersionConflict:
  Unable to satisfy: `CFPropertyList (= 3.0.9)` required by `user-specified dependency`
```
- `fastlane --version` 실행 시 발생
- Ruby 3.4.1 사전 설치 gem과 fastlane이 설치한 CFPropertyList 3.0.9 간 충돌
- **모든 fastlane 명령이 실패함** (version뿐 아니라 build, deploy 등 전부)

### 근본 원인
GitHub Actions `ubuntu-latest` + Ruby 3.4.1 환경에 `retriable` gem이 사전 설치되어 있고, 이 gem이 가져오는 `CFPropertyList` 버전이 fastlane이 요구하는 버전과 충돌.

---

## 해결 전략

**선택: 충돌 gem 사전 제거 + 클린 설치**

```bash
# 1. 충돌하는 사전 설치 gem 제거
gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
# 2. fastlane 클린 설치
gem install fastlane --no-document
# 3. 설치 검증
fastlane --version
```

장점:
- 최소 변경 (Install Fastlane 스텝만 수정)
- 후속 `fastlane` 호출 변경 불필요 (Bundler 방식과 달리)
- 근본 원인(충돌 gem) 직접 해결

대안 (향후 고려):
- Bundler 기반 (`Gemfile` + `bundle exec fastlane`) - 가장 견고하지만 모든 fastlane 호출 변경 필요

---

## 영향 범위 (4개 워크플로우)

| 파일 | fastlane 설치 라인 | fastlane 실행 라인 |
|------|-------------------|-------------------|
| `PROJECT-FLUTTER-ANDROID-TEST-APK.yaml` | 305 | 326 (`fastlane build`) |
| `PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml` | 513 | 634 (`fastlane deploy_internal`) |
| `PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml` | 457 | 497 (`fastlane upload_testflight`) |
| `PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml` | 500 | 538 (`fastlane upload_testflight`) |

---

### Task 1: ANDROID-TEST-APK 워크플로우 수정

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml:303-307`

**Step 1: Install Fastlane 스텝 교체**

기존:
```yaml
      - name: Install Fastlane
        run: |
          gem install fastlane --force
          echo "✅ Fastlane installed"
          fastlane --version
```

변경:
```yaml
      - name: Install Fastlane
        run: |
          gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
          gem install fastlane --no-document
          echo "✅ Fastlane installed"
          fastlane --version
```

**Step 2: 변경 확인**

Run: `grep -A4 "Install Fastlane" .github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml`
Expected: `gem uninstall` 라인 + `gem install fastlane --no-document` 확인

---

### Task 2: ANDROID-PLAYSTORE-CICD 워크플로우 수정

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml:511-515`

**Step 1: Install Fastlane 스텝 교체**

기존:
```yaml
      - name: Install Fastlane
        run: |
          gem install fastlane --force
          echo "✅ Fastlane 설치 완료"
          fastlane --version
```

변경:
```yaml
      - name: Install Fastlane
        run: |
          gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
          gem install fastlane --no-document
          echo "✅ Fastlane 설치 완료"
          fastlane --version
```

---

### Task 3: IOS-TESTFLIGHT 워크플로우 수정

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml:456-457`

**Step 1: Install Fastlane 스텝 교체**

기존:
```yaml
      - name: Install Fastlane
        run: gem install fastlane --force
```

변경:
```yaml
      - name: Install Fastlane
        run: |
          gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
          gem install fastlane --no-document
          fastlane --version
```

---

### Task 4: IOS-TEST-TESTFLIGHT 워크플로우 수정

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml:499-500`

**Step 1: Install Fastlane 스텝 교체**

기존:
```yaml
      - name: Install Fastlane
        run: gem install fastlane --force
```

변경:
```yaml
      - name: Install Fastlane
        run: |
          gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
          gem install fastlane --no-document
          fastlane --version
```

---

### Task 5: 커밋

**Step 1: 변경사항 확인**

Run: `grep -r "gem uninstall retriable" .github/workflows/`
Expected: 4개 파일 모두에서 매칭

**Step 2: 커밋**

```bash
git add .github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml \
       .github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml \
       .github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml \
       .github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml
git commit -m "fix: Fastlane gem 의존성 충돌 해결 (retriable/CFPropertyList 사전 제거)"
```

---

### Task 6: CI 워크플로우 트리거하여 검증

**Step 1: push 후 워크플로우 수동 실행**

ROMROM-ANDROID-TEST-APK 워크플로우를 수동 트리거하여 Install Fastlane 스텝 통과 확인.

Expected:
```
Successfully installed fastlane-2.232.x
✅ Fastlane installed
fastlane 2.232.x
```
