# FlyBy ✈️

A production-grade flight booking app built with Flutter for the Webingo assignment. Clean architecture, real API integration, offline resilience, and a polished UI crafted entirely from scratch.

---

## Screenshots

| Home | Results | Details | Boarding Pass |
|------|---------|---------|---------------|
| Search card with live airport autocomplete, date & passenger pickers | Infinite-scroll results with sort chips, filter sheet, and skeleton loaders | Ticket-shaped flight info card with passenger list and SVG barcode | Printable boarding pass with perforated divider |

---

## How to Run

### Prerequisites
- Flutter SDK `>=3.6.2`
- Dart SDK `>=3.0.0`
- Android Studio / Xcode (for device or emulator)

### Steps

```bash
# 1. Clone the repository
git clone <repo-url>
cd fly_by

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

> The API base URL is configured in `lib/data/services/api_service.dart`. No `.env` file or extra setup is needed — the app works out of the box.

#### Re-generate launcher icon & splash (already done, only needed after icon changes)
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Project Structure

```
lib/
├── core/
│   ├── constants/         # App colors
│   ├── exceptions/        # Typed AppException hierarchy
│   ├── router/            # GoRouter — 5 named routes
│   ├── services/          # ConnectivityService, PreferencesService
│   └── theme/             # Material 3 theme (Plus Jakarta Sans)
├── data/
│   ├── models/            # FlightModel, PassengerModel, PaginationModel …
│   ├── repositories/      # FlightRepository — single source of truth for API
│   └── services/          # ApiService (Dio + retry interceptor + timeouts)
└── presentation/
    ├── providers/          # Riverpod providers (search params, results, airports…)
    ├── screens/
    │   ├── home/           # Search card, airport picker sheet, popular flights
    │   ├── flight_result/  # Results list, sort chips, filter bottom sheet
    │   ├── flight_details/ # Ticket card, passenger rows, SVG barcode
    │   └── boarding_pass/  # Full printable boarding pass
    └── widgets/
        ├── app_painters.dart     # Shared painters & clippers (ticket, dashed line, barcode)
        ├── common_widgets.dart   # ModalHandle, CircularIconButton, InfoCell, ErrorStateWidget, StopsBadge
        ├── skeleton_loader.dart  # FlightCardSkeleton, PopularFlightSkeleton shimmer widgets
        └── offline_banner.dart   # Live connectivity banner
```

---

## Dependencies

| Package | Version | Why |
|---------|---------|-----|
| `flutter_riverpod` | ^2.6.1 | Predictable, testable state — `FutureProvider.autoDispose` for screen-scoped data, `StateProvider` for mutable search params, `StreamProvider` for live connectivity |
| `go_router` | ^16.1.0 | Declarative routing; `state.extra` passes typed flight IDs between screens without URL encoding |
| `dio` | ^5.9.2 | HTTP client with interceptors — enables clean retry logic, structured error mapping, and debug-only logging |
| `google_fonts` | ^6.3.0 | Plus Jakarta Sans — consistent modern typography without bundling font assets |
| `flutter_svg` | ^2.2.0 | Renders the SVG barcode returned by the API without quality loss |
| `cached_network_image` | ^3.4.1 | Airline logo caching — avoids re-fetching the same logo on every list scroll |
| `connectivity_plus` | ^6.0.0 | Streams live online/offline state; used for the `OfflineBanner` and `OfflineException` flow |
| `shared_preferences` | ^2.3.0 | Persists the last-used origin, destination, and passenger count across app restarts |
| `flutter_launcher_icons` | ^0.14.4 | Generates adaptive Android icons (foreground + `#2563EB` blue background) and full iOS icon set |
| `flutter_native_splash` | ^2.4.0 | Native splash on `#3B82F6` with the FlyBy logo — handles the Android 12 splash API correctly |

---

## Approach & Thought Process

### 1. Architecture First

I structured the project with a clear separation of concerns from the start. The **data layer** owns all API interaction — screens never touch Dio directly. The **repository** wraps every call with typed `AppException` handling, so the UI always receives a clean, actionable error type rather than a raw `DioException`. **Providers** sit in between and expose reactive state: `FutureProvider.autoDispose` for data that lives as long as the screen, and `StateProvider` for the search parameters that need to survive navigation.

### 2. Error Handling as a First-Class Concern

I built a typed exception hierarchy before writing a single screen:

```
AppException
├── NetworkException      — no connection
├── RequestTimeoutException — Dio timeout
├── ServerException       — 5xx with status code
├── OfflineException      — device is offline
└── ParseException        — malformed JSON
```

This means every failure mode surfaces differently in the UI. An `OfflineException` shows a wifi-off icon in orange; a `ServerException` shows a red error icon with the message from the API. The `ApiService` pairs this with:
- **30 s connect / 60 s receive** timeouts
- **Retry interceptor** with exponential backoff (1 s → 2 s → 4 s, max 3 retries) for transient errors only — never for 4xx client errors, which should not be retried
- **Debug-only** `LogInterceptor` so request logs never reach production

### 3. UX Details That Matter

- **Skeleton loaders** instead of spinners — the loading state mirrors the exact card layout so there is no layout shift when data arrives. Each skeleton is a `StatefulWidget` with its own `AnimationController` producing a natural, slightly out-of-phase shimmer effect across cards.
- **Offline banner** uses `StreamProvider` with an `async*` generator that emits the *current* connectivity state immediately before streaming changes — no flash of incorrect "online" UI while the stream initialises.
- **Airport autocomplete** debounces at 400 ms so no API call fires until the user pauses typing.
- **Infinite scroll** begins loading the next page 250 px before the list end — the user never reaches a dead stop.
- **Pull-to-refresh** calls `ref.invalidate()` on the Riverpod provider, which triggers a clean page-1 re-fetch while keeping the current search parameters.
- **SharedPreferences** pre-fills the last-used route and passenger count so returning users do not re-enter the same details.

### 4. Custom UI — No Shortcut Packages

All the ticket shapes, dashed separators, and fallback barcode are built with `CustomPainter` and `CustomClipper`:

- `AppTicketClipper` — rounded rect with semicircular notches on both sides; parameterised so the same class handles three different card heights
- `AppDashedLinePainter` — configurable dash width, gap, stroke width, and start padding (used for both flight-card separators and the boarding-pass perforation)
- `AppBarcodePainter` — fallback barcode drawn from a fixed pattern when the API returns no SVG

### 5. Shared Widget Refactor

After the first implementation pass I audited all four screens for duplicated widget trees. I extracted everything that appeared in two or more places into two shared files:

- **`app_painters.dart`** — three painter/clipper classes consolidated from 10 private copies
- **`common_widgets.dart`** — `CircularIconButton`, `ModalHandle`, `InfoCell`, `ErrorStateWidget`, `StopsBadge`

A design change to the back button, the error state, or the dashed separator now only happens in one place.

### 6. Navigation Design

GoRouter with clean route declarations. The `/details` and `/boarding-pass` routes receive the flight ID via `state.extra` — no global state mutation and no URL encoding of internal IDs needed for in-app navigation.

---

## API Endpoints Integrated

| Endpoint | Purpose |
|----------|---------|
| `POST /search` | Flight search with airline/price/stops/aircraft filters, sort, and pagination |
| `POST /flight` | Full flight details by ID (terminal, gate, class, passengers, SVG barcode) |
| `POST /airports/from` | Departure airport autocomplete with debounced search |
| `POST /airports/to` | Arrival airport autocomplete with debounced search |
| `POST /airlines` | Airline list for filter dropdown |
| `POST /aircraft-types` | Aircraft type list for filter dropdown |

---

## Time Taken

| Phase | Time |
|-------|------|
| Project setup, routing, theme, API service + error handling | ~3 hrs |
| Home screen — search card, airport picker, popular flights | ~4 hrs |
| Flight results — infinite scroll, sort chips, filter sheet, skeletons | ~5 hrs |
| Flight details — ticket card, passenger rows, SVG barcode | ~3 hrs |
| Boarding pass — perforated layout, barcode, download action | ~2 hrs |
| Offline support, retry interceptor, SharedPreferences | ~4 hrs |
| Shared widget extraction, common painters refactor | ~2 hrs |
| App icon, splash screen, README | ~1 hr |
| **Total** | **~24 hours** |

---

## What I Would Add With More Time

- **Unit tests** for the repository layer — mock `ApiService`, assert correct exception mapping for each status code
- **Widget tests** for the search validation flow and the skeleton → data transition
- **Hero animations** between the flight card in results and the ticket card in the details screen
- **Fare calendar** — a horizontal week-view strip showing the cheapest available price per day
- **Deep links** so a shared flight URL opens directly to the flight details screen
