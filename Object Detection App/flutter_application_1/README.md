# Flutter Firebase Object Detection App

This Flutter application provides **Firebase Authentication** (Login & Register) and an **Object Detection feature** using a backend API.  
Users can sign up, log in, upload images from the **camera/gallery**, or analyze images via a **URL**.  
Detected objects with confidence scores are displayed in the app.

---

## 🚀 Features
- Firebase **Email/Password Authentication**
- **Hardcoded Test Login** (`test@example.com` / `123456`) for quick access
- Register new users with Firebase
- Upload images from **Camera** or **Gallery**
- Analyze images via **URL**
- Backend API request (`/predict`) for object detection
- Display detected objects with confidence percentage

---

## 🛠️ Setup & Run Instructions

### 1. Clone the repository
```bash
git clone 
cd flutter-object-detection
```

### 2. Install dependencies
Ensure Flutter is installed (`flutter --version` should return a version).

```bash
flutter pub get
```

### 3. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/).  
2. Create a Firebase project.  
3. Enable **Email/Password Authentication** in the **Authentication** section.  
4. Add your app:
   - For Android: download `google-services.json` and place it in `android/app/`
   - For iOS: download `GoogleService-Info.plist` and place it in `ios/Runner/`
5. Update the `FirebaseOptions` inside `main.dart` with Firebase project keys (if different).

### 4. Backend Setup
The app communicates with a backend API that performs object detection.

- Default API endpoint in `DetectionScreen`:
  - **Android Emulator:** `http://10.0.2.2:5000/predict`
  - **iOS/Desktop:** `http://127.0.0.1:5000/predict`

Backend must support:
- Multipart form upload with key: `file`  
- OR JSON body with one of:
  ```json
  { "url": "<image_url>" }
  ```

Start backend server (Flask/FastAPI/etc.) before using detection.

### 5. Run the app
```bash
flutter run
```

---

## 📦 Dependencies

This project uses the following Flutter packages:

- `firebase_core` → Firebase initialization  
- `firebase_auth` → Authentication (login/register)  
- `google_fonts` → Custom fonts  
- `image_picker` → Pick images from camera/gallery  
- `http` → Send requests to backend  
- `permission_handler` → Handle camera/gallery permissions  

---

## 🔑 Login Credentials

For quick testing, the following hardcoded credentials are available:

```
Email: test@example.com
Password: 123456
```

Alternatively, you can **register a new account** with Firebase.

---


