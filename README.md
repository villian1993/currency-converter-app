# Currency Converter (Flutter + Riverpod)

Advanced multi-currency converter that:
- Lets you add multiple currency inputs and amounts
- Converts each amount into a selected base currency
- Calculates and displays a normalized total
- Supports currency search + a currencies list screen
- Caches symbols and latest rates locally for offline use

---

## Features
- Multi-currency input with dynamic add/remove
- Base currency selection (Settings)
- Currency list with search functionality
- Real-time currency conversion using API (`/symbols`, `/latest`)
- Local caching for offline support
- Clean architecture with MVVM-style separation (View, ViewModel, Repository)
- Riverpod for state management
- Robust error handling with user-friendly messages
- Internet connectivity handling with offline fallback

---

# Setup

### 1. Install dependencies
```bash
flutter pub get
# API Configuration (FFI - Native Setup)

No environment variables are used in this project.

API configuration is handled using native build-time (FFI-based) configuration.

# Run App
flutter run

# Run Tests

flutter test

# Internet Handling

App checks internet connectivity before making API calls

If no internet:

Cached data is used (if available)

User-friendly error message is shown

Common handled errors:

No internet connection

API failure

Timeout

Invalid response

#Error Handling

Empty / invalid amount input

Non-numeric values

Amount must be greater than 0

Duplicate currencies not allowed

API errors handled gracefully

Safe JSON parsing to prevent crashes

Offline fallback using cache

#Code Structure

lib/
 ├── main.dart
 ├── src/
 │   ├── app/
 │   │   ├── app.dart
 │   │   └── providers.dart
 │   ├── data/
 │   │   ├── api/
 │   │   ├── cache/
 │   │   └── repositories/
 │   └── features/
 │       └── converter/
 │           ├── models/
 │           ├── view_model/
 │           └── screens/

#Assumptions

Exchange rates are cached for 6 hours

Base currency defaults to USD

Duplicate currencies are restricted

Base currency is not converted

Cached data is used when API fails or internet is unavailable

#UI / Fonts

Uses Manrope font for UI

Clean and modern design

Responsive layout support

#Notes

Uses FFI-based configuration instead of environment variables

Internet connection required for first fetch

Offline mode supported via caching

Built using MVVM-style architecture

State management handled using Riverpod

#Tech Stack

Flutter

Riverpod

SharedPreferences

FFI (native config)

MVVM-style architecture

