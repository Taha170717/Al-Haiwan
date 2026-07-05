# Google Sign-In Setup Guide

## Issue
You got error `ApiException: 10` which means "DEVELOPER_ERROR" - your app's SHA-1 certificate fingerprint doesn't match what's registered in Google Cloud Console.

## Solution

### Step 1: Get Your Debug SHA-1 Fingerprint (Windows PowerShell)

```powershell
cd D:\al_haiwan\android
.\gradlew signingReport
```

This will output something like:
```
Variant: debug
Config: debug
Store: ~/.android/keystore
...
SHA1: 12:34:56:78:9A:BC:DE:F0:12:34:56:78:9A:BC:DE:F0:12:34:56:78
```

**COPY the SHA1 value** (exactly as shown with colons)

---

### Step 2: Register SHA-1 in Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Click **Project Settings** (⚙️ gear icon, top-left)
4. Go to **Your apps** section
5. Click your **Android app** (al-haiwan)
6. Scroll down to **SHA certificate fingerprints**
7. Click **Add fingerprint**
8. Paste your SHA1 from Step 1
9. Click **Save**

---

### Step 3: Download google-services.json

1. Stay in Firebase Console **Project Settings**
2. Look for **Download google-services.json** button (usually near top)
3. Click it to download
4. Save to: `D:\al_haiwan\android\app\google-services.json`

**Important:** This file MUST be at exactly `android/app/google-services.json`

---

### Step 4: Clean and Rebuild

Run these commands from project root:

```powershell
flutter clean
flutter pub get
cd android
.\gradlew clean
cd ..
flutter run
```

---

## Troubleshooting

### If you still get ApiException: 10
- Double-check the SHA-1 is correctly copied (with colons)
- Verify it's saved in Firebase Console
- Wait 5-10 minutes for Firebase to sync
- Make sure `google-services.json` is in `android/app/` folder
- Run `flutter clean` again

### If you get "Missing google_app_id"
- The `google-services.json` file is missing or in wrong location
- Ensure it's at: `D:\al_haiwan\android\app\google-services.json`
- Check file name is exactly `google-services.json` (not `google-services.json.json`)

### To verify google-services.json is correct
- Open it in a text editor
- Look for `"package_name": "com.example.al_haiwan"`
- Look for your client ID and API key
- It should have Firebase app details

---

## Files Modified

- ✅ `android/build.gradle.kts` - Added Google Services plugin
- ✅ `android/app/build.gradle.kts` - Applied Google Services plugin
- ✅ `android/app/src/main/AndroidManifest.xml` - Added INTERNET permission

---

## Next Steps

After you complete the steps above:

1. Run `flutter run` on your device/emulator
2. Click "Login with Google"
3. You should see the Google account picker
4. Select a Google account to sign in
5. If successful, you'll be logged in!

---

## Questions?

If it still doesn't work:
1. Check the Flutter console for `[GoogleSignIn]` debug logs
2. Run `flutter doctor -v` to verify setup
3. Verify google-services.json contents match your Firebase project

