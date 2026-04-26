# Firebase + Firestore setup (StudyMate AI)

Этот проект уже поддерживает Firebase/Firestore в коде.
Нужно выполнить только внешнюю настройку.

## 1) Что такое Firebase и Firestore

- **Firebase** — облачная платформа Google (Auth, Database, Hosting, Push, Analytics).
- **Firestore (Cloud Firestore)** — облачная NoSQL БД внутри Firebase.

В этом проекте Firestore используется для хранения учебного snapshot пользователя
(`exams`, `plans`, `recentMaterials`) вместо backend-эндпоинтов синхронизации.

## 2) Создай Firebase проект

1. Открой https://console.firebase.google.com
2. Create project
3. Добавь Web app (и при необходимости Android app)

## 3) Включи Firestore

1. Firebase Console -> Build -> Firestore Database
2. Create database
3. Выбери регион (например europe-west1)
4. На старте можно Test mode (потом обязательно ужесточи правила)

## 4) Установи CLI

```bash
dart pub global activate flutterfire_cli
```

Проверь:

```bash
flutterfire --version
```

## 5) Сгенерируй `firebase_options.dart`

В корне Flutter проекта:

```bash
flutterfire configure
```

После этого файл `lib/firebase_options.dart` будет заполнен реальными ключами проекта.

## 6) Запускай приложение с Firestore-режимом

```bash
flutter run -d chrome --dart-define=USE_FIREBASE=true
```

Без флага `USE_FIREBASE=true` проект продолжает использовать backend sync (`/user/study-data`).

## 7) Минимальные правила Firestore (временно для разработки)

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /study_snapshots/{docId} {
      allow read, write: if true;
    }
  }
}
```

Важно: это небезопасно для production. Перед релизом привяжи правила к аутентификации.

## 8) Рекомендованные production-шаги

- Включить Firebase Auth (email/password)
- Хранить данные только по `uid`
- Правила:
  - read/write разрешены только если `request.auth.uid == docId`
- Добавить индексы/мониторинг в Firebase Console
