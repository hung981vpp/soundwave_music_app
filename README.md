<div align="center">

# 🎵 SoundWave Music App

Ứng dụng nghe nhạc đa nền tảng xây dựng bằng **Flutter** và **Firebase**.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Nền%20tảng-Android%20%7C%20iOS%20%7C%20Web-lightgrey?style=for-the-badge)
![License](https://img.shields.io/badge/Giấy%20phép-MIT-green?style=for-the-badge)

</div>

---

## 📖 Giới thiệu

**SoundWave** là ứng dụng nghe nhạc đa nền tảng cho phép người dùng tìm kiếm, phát trực tuyến và quản lý danh sách nhạc yêu thích. Ứng dụng hỗ trợ **Android, iOS và Web**, sử dụng Firebase làm backend và `just_audio` để phát nhạc chất lượng cao.

---

## ✨ Tính năng chính

| Tính năng | Mô tả |
|---|---|
| 🔐 Đăng nhập / Đăng ký | Xác thực người dùng với Firebase Auth (Email & Password) |
| 🎵 Phát nhạc | Phát trực tuyến & ngoại tuyến với `just_audio` |
| 🔍 Tìm kiếm & Khám phá | Tìm bài hát, nghệ sĩ, album |
| ❤️ Yêu thích | Lưu và quản lý bài hát yêu thích |
| 📋 Playlist | Tạo và quản lý danh sách phát cá nhân |
| ☁️ Lưu trữ đám mây | Nhạc & ảnh bìa lưu trên Firebase Storage |
| 💾 Cache cục bộ | Hỗ trợ nghe offline với `sqflite` & `shared_preferences` |

---

## 🏗️ Kiến trúc ứng dụng

Ứng dụng theo mô hình **Provider + Service Layer**:

```
┌─────────────────────────────────────────────────┐
│                   Tầng Giao Diện                │
│           Screens / Widgets (Flutter)           │
└────────────────────┬────────────────────────────┘
                     │  lắng nghe / đọc dữ liệu
┌────────────────────▼────────────────────────────┐
│              Quản lý Trạng Thái                 │
│                  Provider                       │
└────────────────────┬────────────────────────────┘
                     │  gọi hàm
┌────────────────────▼────────────────────────────┐
│                Tầng Service                     │
│   AuthService │ MusicService │ PlaylistService  │
└────────┬──────────────┬───────────────┬─────────┘
         │              │               │
┌────────▼──────┐ ┌─────▼──────┐ ┌─────▼──────────┐
│ Firebase Auth │ │ Firestore  │ │Firebase Storage│
└───────────────┘ └────────────┘ └────────────────┘
         │
┌────────▼──────┐
│ SQLite/Prefs  │  ← Cache cục bộ / offline
└───────────────┘
```

---

## 📁 Cấu trúc thư mục

```
soundwave_music_app/
├── lib/
│   ├── main.dart                 # Điểm khởi chạy ứng dụng
│   ├── models/                   # Data models (Song, User, Playlist...)
│   ├── screens/                  # Các màn hình chính
│   │   ├── auth/                 # Đăng nhập, Đăng ký
│   │   ├── home/                 # Màn hình chính
│   │   ├── player/               # Trình phát nhạc
│   │   ├── search/               # Tìm kiếm
│   │   └── playlist/             # Playlist & Yêu thích
│   ├── widgets/                  # Các component dùng lại
│   ├── providers/                # Quản lý trạng thái
│   ├── services/                 # Giao tiếp với Firebase & API
│   └── utils/                    # Helpers, constants, themes
├── android/                      # Cấu hình Android
├── ios/                          # Cấu hình iOS
├── web/                          # Cấu hình Web
├── test/                         # Unit & widget tests
├── seed_firestore.dart           # Script tạo dữ liệu mẫu
├── firebase.json                 # Cấu hình Firebase
└── pubspec.yaml                  # Danh sách dependencies
```

---

## 🛠️ Công nghệ sử dụng

| Tầng | Công nghệ |
|---|---|
| Framework | Flutter (Dart 3.x) |
| Quản lý trạng thái | Provider ^6.1.2 |
| Xác thực | Firebase Auth ^5.3.1 |
| Cơ sở dữ liệu | Cloud Firestore ^5.4.4 |
| Lưu trữ file | Firebase Storage ^12.3.5 |
| CSDL cục bộ | SQLite — sqflite ^2.3.3 |
| Phát nhạc | just_audio ^0.9.40 + audio_session ^0.1.21 |
| Lưu trữ cục bộ | shared_preferences ^2.3.2 |
| Mạng | http ^1.2.2 |
| Giao diện | Google Fonts ^6.2.1, cached_network_image ^3.4.1 |

---

## 🚀 Hướng dẫn cài đặt

### Yêu cầu

| Công cụ | Phiên bản tối thiểu |
|---|---|
| Flutter SDK | >= 3.10.1 |
| Dart SDK | >= 3.0.0 |
| Android Studio / Xcode | Mới nhất |
| Firebase CLI | Mới nhất |

### Bước 1 — Clone dự án

```bash
git clone https://github.com/hung981vpp/soundwave_music_app.git
cd soundwave_music_app
```

### Bước 2 — Cài dependencies

```bash
flutter pub get
```

### Bước 3 — Cấu hình Firebase

Tạo project Firebase tại [console.firebase.google.com](https://console.firebase.google.com) và bật các dịch vụ:

- ✅ Authentication (Email/Password)
- ✅ Cloud Firestore
- ✅ Firebase Storage

Sau đó chạy:

```bash
firebase login
flutterfire configure
```

Lệnh này sẽ tự tạo file `lib/firebase_options.dart`.

### Bước 4 — Seed dữ liệu mẫu *(tùy chọn)*

```bash
dart run seed_firestore.dart
```

### Bước 5 — Chạy ứng dụng

```bash
# Android / iOS
flutter run

# Web
flutter run -d chrome

# Build APK release
flutter build apk --release
```

---

## 🔥 Cấu trúc Firestore

```
firestore/
├── users/
│   └── {userId}/
│       ├── displayName: string
│       ├── email: string
│       └── createdAt: timestamp
├── songs/
│   └── {songId}/
│       ├── title: string
│       ├── artist: string
│       ├── coverUrl: string
│       ├── audioUrl: string
│       └── duration: number
└── playlists/
    └── {playlistId}/
        ├── name: string
        ├── userId: string
        ├── songIds: array
        └── createdAt: timestamp
```

---

## 🧪 Kiểm thử

```bash
# Chạy toàn bộ test
flutter test

# Chạy một file test cụ thể
flutter test test/services/auth_service_test.dart
```

---

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón!

1. Fork repository
2. Tạo nhánh mới: `git checkout -b feature/ten-tinh-nang`
3. Commit thay đổi: `git commit -m 'feat: thêm tính năng X'`
4. Push lên nhánh: `git push origin feature/ten-tinh-nang`
5. Mở Pull Request

---

## 📄 Giấy phép

Dự án này được cấp phép theo **MIT License** — xem file [LICENSE](LICENSE) để biết thêm chi tiết.

---

<div align="center">

Được xây dựng với ❤️ bằng Flutter & Firebase

⭐ *Nếu bạn thấy dự án hữu ích, hãy để lại một star nhé!* ⭐

</div>