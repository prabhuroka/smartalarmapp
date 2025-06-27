# Smart Alarm App

A Flutter-based alarm app with smart features like question-based dismissal and notification scheduling.

## Features
- Set alarms with custom sounds
- Question-based alarm dismissal
- Smart difficulty adjustment
- Notification scheduling
- Statistics tracking

## Prerequisites
- Flutter SDK (3.19.0 or higher)
- Java JDK 11+
- Android Studio (optional but recommended)
- Xcode (for iOS builds)

## Setup Instructions

### 1. Clone the Repository

### 2.  Install Dependencies
-  flutter pub get

### 3. Android Configuration (if building for android)

- compileSdk = 35
- minSdk = 21
- targetSdk = 33

### 4. iOS Configuration (if building for iOS)
- cd ios
- pod install
- cd ..

### 5. Run the app
- flutter build apk --release
- flutter build appbundle
- flutter build ios 
-  flutter pub get
- flutter run

### Dependencies
- flutter_local_notifications: ^16.1.2
- timezone: ^0.9.2
- sqflite: ^2.3.0
- http: ^0.13.5
- intl: ^0.18.1
