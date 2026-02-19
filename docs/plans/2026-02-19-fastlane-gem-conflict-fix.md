# Fastlane Gem 의존성 충돌 해결 보고서

**이슈:** #197 - Android 테스트 APK 빌드 시 Fastlane 설치 실패 (gem 충돌)
**커밋:** `39b11d2`
**날짜:** 2026-02-19
**환경:** GitHub Actions `ubuntu-latest`, Ruby 3.4.1

---

## 1. 문제 설명

GitHub Actions 워크플로우에서 Fastlane 설치 시 두 가지 gem 충돌이 발생하여 빌드 파이프라인 전체가 실패.

---

## 2. 에러 분석

### 에러 1: 실행파일 충돌 (설치 단계)

```
ERROR: Error installing fastlane:
  "console" from fastlane conflicts with installed executable from retriable
```

- **원인:** Ruby 3.4.1에 사전 설치된 `retriable` gem의 `console` 실행파일과 fastlane의 `console` 실행파일 이름 충돌
- **시점:** `gem install fastlane` 실행 시
- **결과:** fastlane 설치 자체가 실패 (exit code 1)

### 에러 2: 런타임 의존성 충돌 (실행 단계)

```
Gem::Molinillo::VersionConflict:
  Unable to satisfy: `CFPropertyList (= 3.0.9)` required by `user-specified dependency`
```

- **원인:** `--force`로 설치 성공 후에도 사전 설치된 `CFPropertyList` 버전과 fastlane이 요구하는 3.0.9 버전 간 resolver 충돌
- **시점:** `fastlane --version` 등 모든 fastlane 명령 실행 시
- **결과:** fastlane이 설치되었지만 실행 불가 → `fastlane build`, `fastlane deploy_internal`, `fastlane upload_testflight` 전부 실패

### 근본 원인

GitHub Actions `ubuntu-latest` + Ruby 3.4.1 환경에 `retriable` gem이 기본 포함되어 있고, 이 gem의 의존성 체인에 포함된 `CFPropertyList`가 fastlane이 요구하는 버전과 충돌.

```
Ruby 3.4.1 기본 환경
  └─ retriable gem (사전 설치)
       ├─ console 실행파일  ← 에러 1: fastlane console과 이름 충돌
       └─ CFPropertyList    ← 에러 2: fastlane 요구 버전과 resolver 충돌
```

---

## 3. 해결 방법

### 채택: 충돌 gem 사전 제거 + 클린 설치

```bash
# 1. 충돌하는 사전 설치 gem 완전 제거
gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true

# 2. fastlane 클린 설치 (충돌 없는 깨끗한 환경)
gem install fastlane --no-document

# 3. 설치 검증
fastlane --version
```

**플래그 설명:**
| 플래그 | 역할 |
|--------|------|
| `--all` | 해당 gem의 모든 버전 제거 |
| `--ignore-dependencies` | 의존성 체크 무시하고 강제 제거 |
| `--executables` | 실행파일도 함께 제거 |
| `--force` | 확인 프롬프트 없이 즉시 제거 |
| `2>/dev/null \|\| true` | gem이 없어도 에러 무시 (멱등성 보장) |
| `--no-document` | 문서 생성 건너뛰기 (CI 설치 속도 향상) |

### 검토한 대안

| 방법 | 장점 | 단점 | 채택 여부 |
|------|------|------|-----------|
| `--force`만 추가 | 최소 변경 | 에러 2 해결 불가 | X |
| 충돌 gem 사전 제거 | 최소 변경 + 근본 해결 | 향후 다른 gem 충돌 가능 | **O** |
| Bundler (`Gemfile` + `bundle exec`) | 가장 견고 | 모든 fastlane 호출 변경 필요 | 향후 고려 |
| Ruby 버전 다운그레이드 (3.1.x) | 간단 | 근본 해결 아님, 보안 패치 누락 | X |
| GEM_HOME 격리 | 완전 격리 | GITHUB_ENV/PATH 설정 필요, 복잡 | X |

---

## 4. 변경 파일 (4개)

### 4-1. PROJECT-FLUTTER-ANDROID-TEST-APK.yaml (line 303-308)

```yaml
# 변경 전
- name: Install Fastlane
  run: |
    gem install fastlane
    echo "✅ Fastlane installed"
    fastlane --version

# 변경 후
- name: Install Fastlane
  run: |
    gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
    gem install fastlane --no-document
    echo "✅ Fastlane installed"
    fastlane --version
```

- fastlane 사용처: `fastlane build --verbose` (line 326)

### 4-2. PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml (line 511-516)

```yaml
# 변경 전
- name: Install Fastlane
  run: |
    gem install fastlane
    echo "✅ Fastlane 설치 완료"
    fastlane --version

# 변경 후
- name: Install Fastlane
  run: |
    gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
    gem install fastlane --no-document
    echo "✅ Fastlane 설치 완료"
    fastlane --version
```

- fastlane 사용처: `fastlane deploy_internal` (line 634)

### 4-3. PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml (line 456-457)

```yaml
# 변경 전
- name: Install Fastlane
  run: gem install fastlane

# 변경 후
- name: Install Fastlane
  run: |
    gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
    gem install fastlane --no-document
    fastlane --version
```

- fastlane 사용처: `fastlane upload_testflight` (line 497)

### 4-4. PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml (line 499-500)

```yaml
# 변경 전
- name: Install Fastlane
  run: gem install fastlane

# 변경 후
- name: Install Fastlane
  run: |
    gem uninstall retriable CFPropertyList --all --ignore-dependencies --executables --force 2>/dev/null || true
    gem install fastlane --no-document
    fastlane --version
```

- fastlane 사용처: `fastlane upload_testflight` (line 538)

---

## 5. 검증 방법

1. push 후 ANDROID-TEST-APK 워크플로우 수동 트리거
2. "Install Fastlane" 스텝에서 아래 출력 확인:
   ```
   Successfully installed fastlane-2.232.x
   ✅ Fastlane installed
   fastlane 2.232.x
   ```
3. 후속 `fastlane build` / `fastlane deploy_internal` / `fastlane upload_testflight` 스텝 정상 통과 확인

---

## 6. 향후 개선 사항

- **Bundler 마이그레이션**: `Gemfile`에 fastlane 버전을 고정하고 `bundle exec fastlane`으로 호출하면 gem 충돌을 근본적으로 방지. GitHub Actions Runner의 Ruby/gem 환경 변경에 영향받지 않음.
- **모니터링**: Ruby 버전 업데이트 시 (`ruby/setup-ruby@v1`이 새 버전 제공) 유사 충돌 재발 가능성 있으므로 CI 실패 시 gem 충돌 우선 확인.
