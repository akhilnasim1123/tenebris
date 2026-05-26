# 🌌 walletDot (tenebris) — Flutter Mobile Client

A premium, dark-themed personal finance management, ledger bookkeeping, and productivity application built with Flutter. `walletDot` helps users log their income and expenses, keep track of multiple cash balances, manage personal debts, schedule reminders with local push notifications, write down categorized notes, and visualize their financial health with rich interactive charts.

It works in tandem with the [walletDot Django Backend](../backend/README.md) to synchronize data across devices using token-based authentication.

---

## 🚀 Key Features

*   **Secure Authentication**: Log in, register, check username/phone availability, and update user profiles (including profile picture in base64 format).
*   **Balance & Ledger Tracking**: Track funds across three distinct accounts:
    *   🏦 **Account** (Bank/Digital balance)
    *   💵 **In Hand** (Physical cash)
    *   🐖 **Deposit** (Savings or locked investments)
*   **Transaction Logging**: Record expenses and income with dynamic metadata:
    *   Title, amount, date, and category.
    *   Payment method classification (Account, In Hand, Deposit, Credit).
    *   Option to exclude transactions from total calculation summaries.
*   **Visual Reports**: Beautiful, interactive charts (pie and bar charts powered by `fl_chart`) to analyze spending habits over custom intervals.
*   **Salary & Income Planner**: Manage monthly salary status (e.g., *Pending* or *Received*) and keep track of expected payment dates.
*   **Personal Debt Ledger**: Log debts and credits per person with status tracking (*Active*, *Settled*, *Rejected*).
*   **Categorized Notes**: Create, edit, and delete notes grouped under custom folders/categories.
*   **Reminders & Push Notifications**: Set time-sensitive reminders with native push alerts using the device's local notifications engine.

---

## 🛠️ Tech Stack & Packages

*   **Framework**: [Flutter SDK](https://flutter.dev) (Dart)
*   **State Management**: `provider` for clean and reactive state.
*   **Database Services**: `sqflite` (SQLite) & `shared_preferences` for offline persistence and local storage configuration.
*   **REST API Integration**: `http` for network communication with the Django API.
*   **Push Notifications**: `flutter_local_notifications` & `timezone` for scheduled alerts.
*   **UI/UX Enhancements**:
    *   `fl_chart` for financial visualizations.
    *   `google_fonts` (using the *Outfit* and *Inter* typography).
    *   `image_picker` for selecting user profile pictures.
    *   `cupertino_icons` for cohesive iOS-style micro-iconography.

---

## 📁 Project Structure

```text
tenebris/
├── android/                  # Android native configuration
├── ios/                      # iOS native configuration
├── assets/
│   └── images/               # App icons and visual assets
├── lib/
│   ├── main.dart             # App Entry Point & Provider initialization
│   ├── providers/
│   │   └── app_provider.dart # Core app state management (Auth, Balance, Transactions, etc.)
│   ├── services/
│   │   ├── database_service.dart     # HTTP client wrapper for Django backend APIs
│   │   └── notification_service.dart # Local notifications wrapper
│   └── widgets/
│       ├── Landing.dart      # Welcome / Onboarding Screen
│       ├── Login.dart        # User sign-in screen
│       ├── Signup.dart       # User sign-up screen with input validation
│       ├── Home.dart         # Dashboard screen displaying balances, transactions, and quick links
│       ├── AddExpense.dart   # Transaction Logger (Income/Expense form)
│       ├── FullReport.dart   # Advanced analytics with fl_chart integrations
│       ├── SalaryManagement.dart     # Expected salaries tracker
│       ├── LedgerManagement.dart     # Account / In Hand / Deposit balance reconciliations
│       ├── PersonalManagement.dart   # Debts and credits logger (Me feature)
│       ├── RemindersManagement.dart  # Time-based reminders list & scheduler
│       ├── NotesManagement.dart      # Notebook interface & folder categories
│       └── ProfileSettings.dart      # User configuration and account details update
```

---

## ⚙️ Setup & Installation

### 1. Prerequisites
Ensure you have the Flutter SDK installed on your machine.
*   **SDK Constraints**: `sdk: ^3.7.0` (Dart 3.x support)

### 2. Configure Backend Connection
The application communicates with the `walletDot` Django backend via REST APIs. 
Open `lib/services/database_service.dart` and locate the `baseUrl` configuration around line 12:

```dart
static String get baseUrl {
  final String host =
      defaultTargetPlatform == TargetPlatform.android
          ? '192.168.18.68' // Change to your backend server IP
          : '192.168.18.68';
  return 'http://$host:8000/api';
}
```
*Modify `'192.168.18.68'` to match the local/public IP address of your running backend server.*

### 3. Run Development Commands
Navigate to the `tenebris` directory and run the following:

```bash
# Fetch all dependencies
flutter pub get

# Generate app icons (if needed)
flutter pub run flutter_launcher_icons

# Run the app in debug mode
flutter run
```

---

## 🤝 Relations
*   **Backend Server Repository**: [walletDot Backend](../backend/README.md)
