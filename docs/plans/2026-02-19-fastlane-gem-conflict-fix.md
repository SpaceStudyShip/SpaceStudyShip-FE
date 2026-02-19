# Fastlane Gem 의존성 충돌 해결 (v2 - deploy 브랜치 동기화)

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** GitHub Actions에서 Fastlane gem 충돌을 GEM_HOME+GEM_PATH 완전 격리로 해결하고, **deploy 브랜치에 동기화**하여 실제 CI에서 실행되도록 보장

**Architecture:** 이전 GEM_HOME 수정은 main에만 적용되었으나, 배포 워크플로우는 `push: ["deploy"]` 트리거로 deploy 브랜치의 YAML을 읽음. deploy 브랜치에는 구 코드가 남아있어 수정이 실행된 적 없음. GEM_PATH 추가로 격리 강화 후 deploy 브랜치 동기화.

**Tech Stack:** GitHub Actions, Ruby 3.3.0/3.4.1, Fastlane, RubyGems, GITHUB_ENV/GITHUB_PATH

---

## 문제 이력 및 시도한 해결책

| 시도 | 방법 | 설치 | 실행 | 실패 원인 |
|------|------|------|------|-----------|
| 1차 | `gem install fastlane --force` | OK | FAIL | CFPropertyList 3.0.9 런타임 충돌 |
| 2차 | `gem uninstall` + `gem install --no-document` | FAIL | - | retriable 재설치 → console 충돌 |
| 3차 | `gem uninstall` + `gem install --force --no-document` | OK | FAIL | CFPropertyList 3.0.9 여전히 충돌 |
| 4차 | GEM_HOME 격리 (main만 적용) | **미실행** | **미실행** | deploy 브랜치 미동기화로 구 코드 실행됨 |

### 근본 원인 (2가지)

**원인 1: Ruby default gem 충돌**

`CFPropertyList 3.0.9`는 Ruby의 **default gem**으로 설치 자체에 내장. `gem uninstall`은 사용자 설치 gem만 제거하고 default gem spec은 남겨둠. 런타임에 gem resolver가 default spec과 충돌.

```
Ruby default gems (제거 불가)
  ├─ CFPropertyList 3.0.9 (default gem spec)
  └─ retriable (console 실행파일 포함)

gem install fastlane --force
  └─ CFPropertyList 3.0.9 설치  ← default spec과 중복 → resolver 충돌
```

**원인 2: deploy 브랜치 YAML 미동기화 (핵심!)**

```
main 브랜치:   854e6a4 fix: GEM_HOME 격리  ← 수정 완료
deploy 브랜치: 6a1ed62 (854e6a4 이전)       ← 구 코드 (gem uninstall + --force)

워크플로우 트리거:
  push: ["deploy"]  → deploy 브랜치의 YAML 읽음 → 구 코드 실행
  workflow_run      → main 브랜치의 YAML 읽음 → 수정된 코드 실행 (이 경로는 OK)
```

CI 로그 증거:
- iOS TestFlight (macOS/Ruby 3.3.0): `gem uninstall ... && gem install fastlane --force --no-document` 실행 → 구 코드
- Android Play Store (Ubuntu/Ruby 3.4.1): 동일한 구 코드 실행
- 두 환경 모두 `CFPropertyList (= 3.0.9)` 충돌 에러로 실패

---

## 최종 해결: GEM_HOME + GEM_PATH 완전 격리 + deploy 동기화

### 격리 코드 (강화 버전)

```bash
export GEM_HOME="$HOME/.gem"
export GEM_PATH="$GEM_HOME"
export PATH="$GEM_HOME/bin:$PATH"
echo "GEM_HOME=$GEM_HOME" >> $GITHUB_ENV
echo "GEM_PATH=$GEM_HOME" >> $GITHUB_ENV
echo "$GEM_HOME/bin" >> $GITHUB_PATH
gem install fastlane --no-document
fastlane --version
```

**기존 대비 변경점:**
- `GEM_PATH=$GEM_HOME` 추가: Ruby gem resolver가 **오직** `$GEM_HOME` 디렉토리만 참조하도록 강제. 시스템 default gem spec 완전 차단.
- `GITHUB_ENV`에 `GEM_PATH`도 기록: 후속 스텝에서도 격리 유지.

**원리:**
- `GEM_HOME`: gem 설치 위치를 별도 디렉토리로 변경
- `GEM_PATH`: gem **탐색** 경로를 `GEM_HOME`만으로 제한 (default gem spec 무시)
- `GITHUB_ENV` + `GITHUB_PATH`: 후속 스텝(Upload to TestFlight/Play Store)에도 환경 전파

---

## 변경 대상

### Task 1: 4개 워크플로우 Install Fastlane 스텝 강화 (main)

**Step 1: ANDROID-TEST-APK 수정**

**File:** `.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml`
- Install: line 303-311

기존 (main):
```yaml
      - name: Install Fastlane
        run: |
          export GEM_HOME="$HOME/.gem"
          export PATH="$GEM_HOME/bin:$PATH"
          echo "GEM_HOME=$GEM_HOME" >> $GITHUB_ENV
          echo "$GEM_HOME/bin" >> $GITHUB_PATH
          gem install fastlane --no-document
          echo "✅ Fastlane installed"
          fastlane --version
```

변경:
```yaml
      - name: Install Fastlane
        run: |
          export GEM_HOME="$HOME/.gem"
          export GEM_PATH="$GEM_HOME"
          export PATH="$GEM_HOME/bin:$PATH"
          echo "GEM_HOME=$GEM_HOME" >> $GITHUB_ENV
          echo "GEM_PATH=$GEM_HOME" >> $GITHUB_ENV
          echo "$GEM_HOME/bin" >> $GITHUB_PATH
          gem install fastlane --no-document
          echo "✅ Fastlane installed"
          fastlane --version
```

Usage (line 330): `fastlane build --verbose` — 변경 불필요 (GITHUB_PATH로 bin 경로 전파됨)

**Step 2: ANDROID-PLAYSTORE-CICD 수정**

**File:** `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`
- Install: line 511-519

동일 패턴 적용 (GEM_PATH 2줄 추가). echo 메시지: "✅ Fastlane 설치 완료"
Usage (line 638): `fastlane deploy_internal` — 변경 불필요

**Step 3: IOS-TESTFLIGHT 수정**

**File:** `.github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml`
- Install: line 456-463

동일 패턴 적용 (GEM_PATH 2줄 추가)
Usage (line 503): `fastlane upload_testflight` — 변경 불필요

**Step 4: IOS-TEST-TESTFLIGHT 수정**

**File:** `.github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml`
- Install: line 499-506

동일 패턴 적용 (GEM_PATH 2줄 추가)
Usage (line 544): `fastlane upload_testflight` — 변경 불필요

### Task 2: main 커밋

```bash
git add .github/workflows/PROJECT-FLUTTER-*.yaml
git commit -m "fix: GEM_PATH 추가로 Fastlane gem 격리 강화"
```

### Task 3: deploy 브랜치 동기화

```bash
git checkout deploy
git merge main --no-edit
git checkout main
```

### Task 4: 양쪽 브랜치 push

```bash
git push origin main deploy
```

---

## 검증 방법

1. push 후 deploy 브랜치에 GEM_HOME+GEM_PATH 코드가 존재하는지 확인:
   ```bash
   git log --oneline deploy | head -3
   ```
2. CI "Install Fastlane" 스텝 로그 확인:
   ```
   ✅ Fastlane installed
   fastlane 2.232.x
   ```
3. 후속 스텝 (`Upload to Play Store` / `Upload to TestFlight`) 정상 통과 확인
