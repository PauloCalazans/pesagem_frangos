# Flutter 3.44 Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the application analyze, test, and build with Flutter 3.44.9 and Dart 3.12.2 while preserving its existing behavior and Android application ID.

**Architecture:** Upgrade package and Android build metadata at their source, then replace only Flutter APIs removed since the 2021 release. Keep the UI structure and calculation behavior unchanged; use widget tests and the Android build as regression gates.

**Tech Stack:** Flutter 3.44.9, Dart 3.12.2, Material, shared_preferences, Android Gradle Plugin 9.0.1, Kotlin 2.3.20, Gradle 9.1.0.

## Global Constraints

- Preserve Android application ID and namespace `com.sisdan.pesagemfrangos`.
- Preserve version `1.0.1+2` and existing Portuguese UI behavior.
- Do not commit automatically because the checkout already contains user changes.
- Validate with `flutter analyze`, `flutter test`, and `flutter build apk --debug`.

---

### Task 1: Establish a meaningful regression test

**Files:**
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `MyApp` from `lib/main.dart`.
- Produces: a widget smoke test that asserts the initial `Pesagem` screen and its first-step controls.

- [ ] **Step 1: Replace the obsolete counter test**

Use `SharedPreferences.setMockInitialValues({})`, initialize global `mPrefs`, pump `MyApp`, and assert `Pesagem`, `Sexo`, and `AVANÇAR` are visible.

- [ ] **Step 2: Run the test to verify RED**

Run: `flutter test --no-version-check`
Expected: FAIL during compilation because the old package lock and removed Flutter APIs are still present.

### Task 2: Upgrade Dart and Flutter dependencies

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`

**Interfaces:**
- Consumes: Dart 3.12.2 package solver.
- Produces: Dart SDK constraint `^3.12.2`, `cupertino_icons ^1.0.9`, and `shared_preferences ^2.5.5`.

- [ ] **Step 1: Update direct constraints in `pubspec.yaml`**
- [ ] **Step 2: Run `flutter pub upgrade --major-versions`**
- [ ] **Step 3: Re-run the test and confirm only application API errors remain**

### Task 3: Migrate removed Flutter APIs

**Files:**
- Modify: `lib/util/util.dart`
- Modify: `lib/widgets/stepper_custom.dart`
- Modify: `lib/ui/home_page.dart`
- Modify: `lib/ui/add_pesopadrao_page.dart`

**Interfaces:**
- Consumes: current Material 3 names (`TextButton`, `colorScheme.surface`, `textTheme.bodyMedium`, `PopScope`).
- Produces: the same dialogs, step navigation, labels, and exit confirmation without removed APIs.

- [ ] **Step 1: Replace both `FlatButton` calls with `TextButton`**
- [ ] **Step 2: Remove `AnimatedSize.vsync` and redundant non-null assertions/imports**
- [ ] **Step 3: Replace legacy theme names with `colorScheme.surface`, `bodyMedium`, and explicit foreground colors**
- [ ] **Step 4: Replace `WillPopScope` with `PopScope` and preserve the async confirmation dialog**
- [ ] **Step 5: Run `dart format`, `flutter analyze`, and `flutter test`**

### Task 4: Upgrade the Android host project

**Files:**
- Modify: `android/settings.gradle`
- Modify: `android/build.gradle`
- Modify: `android/app/build.gradle`
- Modify: `android/gradle/wrapper/gradle-wrapper.properties`
- Modify: `android/gradle.properties`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `.metadata`

**Interfaces:**
- Consumes: Flutter's declarative Gradle plugins and SDK-provided compile/min/target SDK values.
- Produces: a Gradle 9.1 / AGP 9.0.1 Android build retaining `com.sisdan.pesagemfrangos`.

- [ ] **Step 1: Port the Flutter 3.44 declarative plugin configuration to the project's existing Groovy DSL and preserve the application ID**
- [ ] **Step 2: Remove the obsolete `io.flutter.app.FlutterApplication` manifest entry**
- [ ] **Step 3: Update Gradle wrapper and project migration metadata**
- [ ] **Step 4: Run `flutter build apk --debug`**

### Task 5: Final verification

**Files:**
- Review: all modified files

**Interfaces:**
- Consumes: completed upgrade.
- Produces: fresh evidence that analysis, tests, and Android compilation succeed.

- [ ] **Step 1: Run `flutter analyze --no-version-check`**
- [ ] **Step 2: Run `flutter test --no-version-check`**
- [ ] **Step 3: Run `flutter build apk --debug --no-pub`**
- [ ] **Step 4: Review `git diff --check`, `git status --short`, and the final diff**
