# atlas_of_emotions

A new Flutter project.

## 프로젝트 실행 방법

### 사전 요구사항

- Flutter SDK 설치 (최소 버전 3.9.2)
- Dart SDK (Flutter와 함께 설치됨)

### 의존성 설치

프로젝트를 처음 클론하거나 의존성이 변경된 경우:

```bash
flutter pub get
```

### 실행 방법

#### 웹 브라우저에서 실행 (Chrome)

```bash
flutter run -d chrome
```

#### 웹 서버로 실행

```bash
flutter run -d web-server
```

기본적으로 `http://localhost:8080`에서 실행됩니다.

#### 다른 플랫폼에서 실행

**Android:**
```bash
flutter run -d android
```

**iOS (macOS만 가능):**
```bash
flutter run -d ios
```

**사용 가능한 디바이스 확인:**
```bash
flutter devices
```

### 웹 빌드

프로덕션용 웹 빌드를 생성하려면:

```bash
flutter build web
```

빌드된 파일은 `build/web` 디렉토리에 생성됩니다.

### 주요 기능

- URL 기반 라우팅 (go_router 사용)
- 감정 분석 화면
- 회원가입 플로우
- 마이크 권한 관리
- 동영상 배경 재생

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
