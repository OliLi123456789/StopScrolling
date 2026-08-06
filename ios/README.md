# Pause — iOS App Build & App Reviewer Submission Instructions

This folder contains the native Swift/SwiftUI implementation of **Pause** for iOS, structured to meet modern Apple App Store Guidelines and Screen Time intercept requirements.

## 1. Directory Structure
- **PauseApp.swift**: Main App orchestrator launching TabView content.
- **Info.plist**: Declares requested local permissions, including the Screen Time API description (`NSFamilyControlsUsageDescription`).
- **PauseApp.entitlements**: Declares the mandated `com.apple.developer.family-controls` entitlement required to utilize FamilyControls.
- **Models/**
  - **AppState.swift**: Core application state keeping configuration (Privacy-first local storage).
  - **ScreenTimeManager.swift**: Orchestrates Apple's native Screen Time APIs (`FamilyControls`, `ManagedSettings`) to apply app shields.
- **Views/**
  - **ScrollyticsView.swift**: Renders the Scrollytics trend dashboard, the editable managed apps list, standard legal Links, and the native **StoreKit 2** based billing sheets.
  - **OnboardingView.swift**: Holds the initial onboarding setup.
  - **PauseGateView.swift**: Renders the fullscreen breathing pause gates, mock scroll feeds, and after-scroll reflection check-ins.

## 2. Opening & Building in Xcode
To compile and submit to the Apple App Store, create a SwiftUI Xcode Project (`PauseApp`), drag these swift source files in, bind your App Store Developer Signing Certificate, and build!

## 3. Mandatory App Reviewer Notes
- **Authentication:** Pause requires **No login/password registration**. It operates 100% locally and anonymously. Reviewers can access every screen without credentials.
- **Privacy Policy:** [Pause Privacy Policy](https://github.com/OliLi123456789/StopScrolling/blob/main/PRIVACY.md)
- **Terms of Service:** [Pause Terms of Service](https://github.com/OliLi123456789/StopScrolling/blob/main/TERMS.md)
- **Account/Data Deletion:** Accessible immediately inside Settings configuration screen via the **Delete All My Data & Account** button.
