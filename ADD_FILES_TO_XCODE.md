# How to Add Files to Xcode Project 📱

## ✅ Project Created Successfully!

Your Xcode project is now ready. Just need to add the source files.

## 🚀 Quick Steps (2 minutes)

### 1. Open the Project
```bash
open DontBeLate.xcodeproj
```

### 2. Add All Source Files

1. In Xcode, **right-click** on the `DontBeLateApp` folder (in Project Navigator)
2. Select **"Add Files to 'DontBeLateApp'..."**
3. Navigate to your project folder
4. Select the entire **`DontBeLateApp`** folder
5. **Important settings:**
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups"  
   - ✅ Select "DontBeLate" target
6. Click **Add**

### 3. Verify Files Added

You should see in Xcode:
- DontBeLateApp.swift
- ContentView.swift
- Models/ (4 files)
- Services/ (4 files)
- ViewModels/ (3 files)
- Views/ (10 files)
- Info.plist

**Total: 24 files**

### 4. Add Entitlements

1. Drag `DontBeLateApp.entitlements` into the project
2. Or: File → Add Files → Select entitlements file

### 5. Select Your Team

1. Click project name (top of Navigator)
2. Select **DontBeLate** target
3. Go to **"Signing & Capabilities"**
4. Select your **Team**

### 6. Build & Run!

- Clean: **Shift + Cmd + K**
- Build: **Cmd + B**
- Run: **Cmd + R**

## ✨ What You Get

All features are ready:
- ✅ Calendar sync (real-time)
- ✅ Traffic-based timing (per event)
- ✅ Push notifications when apps blocked
- ✅ Beautiful loading animation
- ✅ Per-event configuration
- ✅ Active blocks view
- ✅ Notification testing

## 🔔 Test Notifications

After building:
1. Open app
2. Go to Settings → Test Notifications
3. Tap "Send Test Notification"
4. See the rich notification with blocked apps!

## ⚠️ Troubleshooting

**Files appear red?**
- Right-click → Show in Finder
- Verify file exists
- Re-add if needed

**Build errors?**
- Make sure all 24 files are added
- Check that DontBeLate target is selected
- Clean build folder

**Can't select team?**
- Xcode → Settings → Accounts
- Add your Apple ID

---

**Ready to build! 🎉**

