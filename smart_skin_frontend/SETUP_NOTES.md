# Smart Skin Frontend - Setup Guide

## Backend URL (lib/constants/constants.dart)
- Android emulator: http://10.0.2.2:8080/api
- iOS simulator: http://localhost:8080/api
- Physical device: http://<YOUR_IP>:8080/api

## Android Permissions (android/app/src/main/AndroidManifest.xml)
Add inside <manifest>:
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.CAMERA"/>
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>

Add to <application> for HTTP dev:
  android:usesCleartextTraffic="true"

## iOS Permissions (ios/Runner/Info.plist)
  <key>NSCameraUsageDescription</key>
  <string>Camera access for skin analysis</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Photo library for skin photos</string>
  <key>NSAppTransportSecurity</key>
  <dict><key>NSAllowsArbitraryLoads</key><true/></dict>

## Install & Run
  flutter pub get
  flutter run
