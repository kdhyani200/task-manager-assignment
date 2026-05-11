# 📝 Task Manager

A modern, real-time Task Management application built with **Flutter**, **Riverpod**, and **Firebase**. This app allows users to create, update, and filter tasks while keeping everything synchronized across devices using Cloud Firestore.

---

## ✨ Features

- 🔄 **Real-time Synchronization**  
  Tasks are stored in Firebase Firestore and updated instantly across devices.

- 🔐 **Secure Authentication**  
  User sign-up and login powered by Firebase Auth.

- 📂 **Smart Filtering**  
  Easily switch between **All**, **Pending**, and **Completed** tasks.

- ⚡ **State Management**  
  Clean and scalable state handling using **Riverpod**.

- 🎨 **Modern UI/UX**
  - Shimmer loading effects
  - Responsive design for multiple screen sizes

- 💡 **Daily Motivation**  
  Inspirational quotes fetched using an API.

---

## 🛠 Tech Stack

- **Flutter**
- **Riverpod**
- **Firebase Firestore**
- **Firebase Authentication**
- **Google Fonts**

---

## 🚀 Getting Started

### 1️⃣ Prerequisites

Make sure you have installed:

- Flutter SDK
- Firebase CLI
- A Firebase project

---

### 2️⃣ Clone the Repository

```bash
git clone https://github.com/your-username/assign_task_manager.git
cd assign_task_manager
```

---

### 3️⃣ Configure Firebase

```bash
firebase login
flutterfire configure
```

---

### 4️⃣ Install Dependencies

```bash
flutter pub get
```

---

### 5️⃣ Generate Native Assets

#### Generate Launcher Icons

```bash
dart run flutter_launcher_icons
```

#### Generate Splash Screen

```bash
dart run flutter_native_splash:create
```

---

### 6️⃣ Run the App

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📁 Project Structure

```bash
lib/
├── models/
│   ├── quote.dart
│   └── task.dart
├── providers/
│   ├── filter_provider.dart
│   └── task_provider.dart
├── screens/
│   ├── add_task_screen.dart
│   ├── authentication_screen.dart
│   └── home_screen.dart
├── services/
│   ├── firestore_service.dart
│   └── quote_service.dart
├── widgets/
│   ├── customized_snackbar.dart
│   ├── decorated_input_field.dart
│   ├── drawer.dart
│   ├── filter_item.dart
│   ├── quote_card.dart
│   └── task_card.dart
├── firebase_options.dart
└── main.dart
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork the repository and submit a pull request.

---

## 📜 License

This project is licensed under the MIT License.
