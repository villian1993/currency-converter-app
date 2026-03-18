# Currency Converter (Flutter + Riverpod)

Advanced multi-currency converter that:
- Lets you add multiple currency inputs and amounts
- Converts each amount into a selected base currency
- Calculates and displays a normalized total
- Supports currency search + a currencies list screen
- Caches symbols and latest rates locally for offline use (recently fetched)

## Requirements Covered (Assessment)
- Multi-currency input + “Add Currency”
- Base currency selection (Settings)
- Currency list screen with search
- Real-time rates from API (`/symbols`, `/latest`)
- Caching to minimize API calls + basic offline fallback
- MVVM-ish structure (Views + ViewModel + Repository)
- Riverpod state management (`flutter_riverpod`)
- Unit tests focused on ViewModels/Repositories/Logic

## Setup

### 1) Install dependencies
```bash
flutter pub get
```

### 2) Provide API Key (APILayer Exchange Rates Data)
Option A (recommended): pass via `--dart-define`:
```bash
flutter run --dart-define=APILAYER_API_KEY=YOUR_KEY
```

Option A2: (Android/iOS) provide API key + base URL via native FFI (build-time)
- **Android:** set values in `android/gradle.properties` (do not commit real keys):
  - `APICONFIG_BASE_URL=https://api.apilayer.com/exchangerates_data`
  - `APICONFIG_API_KEY=YOUR_KEY`
- **iOS:** define `APICONFIG_BASE_URL` and `APICONFIG_API_KEY` in Xcode build settings
  (`GCC_PREPROCESSOR_DEFINITIONS`) for the Runner target, or via an `.xcconfig` you keep out of git.

Option B: open `Settings` in the app and paste the API key (it is saved locally on the device).

## Run
```bash
flutter run --dart-define=APILAYER_API_KEY=YOUR_KEY
```

## Tests
```bash
flutter test
```

## Code Structure (High level)
- `lib/main.dart` – entry point
- `lib/src/app/app.dart` – routes
- `lib/src/app/providers.dart` – DI (Riverpod providers)
- `lib/src/data/` – API client, cache, repository
- `lib/src/features/converter/` – models, calculator, view model, screens

## Assumptions
- Latest rates are cached for `6 hours` (see `ExchangeRatesRepository.cacheTtl`).
- If the network fails, cached symbols/rates are used when available.

## Notes
- Assessment mentions Riverpod; this implementation uses Riverpod.
