# Fastlane Gem 의존성 충돌 해결 보고서

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** GitHub Actions Ruby 3.4.1 환경에서 default gem 충돌로 인한 Fastlane 설치/실행 실패를 GEM_HOME 격리로 해결

**Architecture:** Ruby 3.4.1의 default gem(CFPropertyList 3.0.9)이 fastlane 의존성과 충돌. `gem uninstall`로는 default gem spec 제거 불가. GEM_HOME을 별도 디렉토리로 설정하여 시스템 gem과 완전 격리.

**Tech Stack:** GitHub Actions, Ruby 3.4.1, Fastlane, RubyGems, GITHUB_ENV/GITHUB_PATH

---

## 문제 이력 및 시도한 해결책

| 시도 | 방법 | 설치 | 실행 | 실패 원인 |
|------|------|------|------|-----------|
| 1차 | `gem install fastlane --force` | OK | FAIL | CFPropertyList 3.0.9 런타임 충돌 |
| 2차 | `gem uninstall` + `gem install --no-document` | FAIL | - | retriable 재설치 → console 충돌 |
| 3차 | `gem uninstall` + `gem install --force --no-document` | OK | FAIL | CFPropertyList 3.0.9 여전히 충돌 |

### 근본 원인

`CFPropertyList 3.0.9`는 Ruby 3.4.1의 **default gem**으로 Ruby 설치 자체에 내장. `gem uninstall`은 사용자 설치 gem만 제거하고 default gem specification은 남겨둠. 런타임에 gem resolver가 default spec의 3.0.9와 fastlane이 설치한 3.0.8 사이에서 충돌.

```
Ruby 3.4.1 default gems (제거 불가)
  ├─ CFPropertyList 3.0.9 (default gem spec)  ← gem uninstall로 제거 불가
  └─ retriable (console 실행파일 포함)

gem install fastlane
  └─ CFPropertyList 3.0.8 설치  ← 3.0.9 default spec과 런타임 충돌
```

---

## 최종 해결: GEM_HOME 격리

```bash
export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:$PATH"
echo "GEM_HOME=$GEM_HOME" >> $GITHUB_ENV
echo "$GEM_HOME/bin" >> $GITHUB_PATH
gem install fastlane --no-document
fastlane --version
```

**원리:**
- `GEM_HOME`을 별도 디렉토리로 지정 → 시스템 default gem 무시
- `export`로 현재 스텝에서 즉시 적용
- `GITHUB_ENV` + `GITHUB_PATH`로 후속 스텝(Build APK, Upload 등)에도 전파
- `--force`, `gem uninstall` 모두 불필요 (충돌 자체가 발생하지 않음)

---

## 변경 대상 (4개 워크플로우)

### Task 1: ANDROID-TEST-APK

**File:** `.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml`
- Install: line 303-308
- Usage: line 327 (`fastlane build --verbose`)

기존:
```yaml
      - name: Install Fastlane
        run: |
          gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
          gem install fastlane --force --no-document
          echo "✅ Fastlane installed"
          fastlane --version
```

변경:
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

### Task 2: ANDROID-PLAYSTORE-CICD

**File:** `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`
- Install: line 511-516
- Usage: line 635 (`fastlane deploy_internal`)

동일 패턴 적용 (echo 메시지: "✅ Fastlane 설치 완료")

### Task 3: IOS-TESTFLIGHT

**File:** `.github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml`
- Install: line 456-461
- Usage: line 500 (`fastlane upload_testflight`)

동일 패턴 적용

### Task 4: IOS-TEST-TESTFLIGHT

**File:** `.github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml`
- Install: line 499-504
- Usage: line 541 (`fastlane upload_testflight`)

동일 패턴 적용

### Task 5: 커밋

```bash
git add .github/workflows/PROJECT-FLUTTER-*.yaml
git commit -m "fix: GEM_HOME 격리로 Fastlane gem 충돌 근본 해결"
```

### Task 6: 문서 업데이트 + 커밋

보고서 문서 최종 업데이트 후 커밋.

---

## 검증 방법

1. push 후 ANDROID-TEST-APK 워크플로우 수동 트리거
2. "Install Fastlane" 스텝 통과 확인:
   ```
   ✅ Fastlane installed
   fastlane 2.232.x
   ```
3. 후속 스텝 (`Build APK` / `Upload to Play Store` / `Upload to TestFlight`) 정상 통과 확인
   - `GITHUB_PATH`에 의해 `fastlane` 명령이 격리된 GEM_HOME에서 실행되는지 확인
