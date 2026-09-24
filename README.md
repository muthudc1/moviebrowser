# 🎬 Movie Browser App

A modern, production-grade Flutter application that allows users to browse, search, and explore movies using **The Movie Database (TMDB) API (v3)**. Built with Clean Architecture, Provider state management, offline caching, and fluid animations.

---

## 📱 Features

### 🌟 Core Requirements
- **TMDB API Integration**: Securely connects to TMDB v3 API using environment configurations (`.env`) without committing sensitive secrets.
- **Movie List Screen**:
  - Browse **Popular**, **Now Playing**, and **Top Rated** movies with category chips.
  - Infinite scroll / pagination with auto-fetch as the user scrolls down.
  - Pull-to-refresh mechanism with `RefreshIndicator`.
  - Shimmer loading skeleton placeholders (`shimmer` & `cached_network_image`).
  - Graceful network error handling with retry capability.
- **Movie Detail Screen**:
  - Smooth **Hero Animation** transitions between the list and detail views.
  - High-resolution Backdrop and Poster image displays.
  - Release date formatting, User Score / Rating badge (`★`), runtime, genres, and synopsis/overview.
  - Box office financials (Budget & Revenue) and movie status.
  - Loading skeleton & error retry handling.
- **Navigation**: Clean declarative Navigator routing with parameter passing and transition animations.

### 🚀 Bonus Features
- **🔍 Debounced Live Search**: Real-time search bar with 450ms debouncing, dynamic result counts, clear button, and paginated search results.
- **💾 Offline Caching**: Uses `SharedPreferences` to cache movie lists and movie details locally, enabling instant loading and offline playback.
- **🎨 Cinematic Theme & Dark/Light Mode**: Custom dark & light theme modes with seamless toggle and persistence across app restarts.
- **⚡ Responsive Grid Layout**: Dynamic column count matching standard mobile, tablet, and desktop screens.
- **🧪 Comprehensive Test Suite**: 19 unit and widget tests covering models, providers, debouncing, and custom widgets.

---

## 🛠️ Architecture & State Management

### State Management: `Provider`
The app uses the **Provider** package (`ChangeNotifierProvider`, `MultiProvider`, `Consumer`/`context.watch`):
- **Why Provider?**
  - Officially recommended and widely adopted by the Flutter team.
  - Clear, predictable state flow with `ChangeNotifier`.
  - Easy to unit test and mock without complex boilerplate.
  - Lightweight and highly performant with fine-grained widget rebuilding.

### Layered Clean Architecture
```
lib/
├── core/
│   ├── config/              # Environment (.env) & API configuration
│   ├── constants/           # Endpoints, image paths & sizes
│   ├── error/               # Custom typed exceptions (Server, Network, Unauthorized, Cache)
│   ├── network/             # ApiClient wrapper with timeout, headers & auth
│   ├── theme/               # Dark & Light cinematic themes + typography
│   └── utils/               # DateFormatter, Currency, and Debounce utilities
├── features/
│   └── movies/
│       ├── data/
│       │   ├── datasources/ # Remote TMDB API & Local Cache (SharedPreferences)
│       │   ├── models/      # Movie, MovieDetail, Genre, MovieResponse
│       │   └── repositories/# MovieRepository implementation with cache fallback
│       └── presentation/
│           ├── providers/   # MovieListProvider, MovieSearchProvider, MovieDetailProvider, ThemeProvider
│           ├── screens/     # MovieListScreen, MovieDetailScreen
│           └── widgets/     # MovieCard, MovieSearchBar, RatingBadge, GenreChip, ErrorView, ShimmerGrid
└── main.dart                # App bootstrap & MultiProvider registration
```

---

## 🔑 TMDB API Key Setup

### 1. Obtain a Free TMDB API Key
1. Register for an account on [The Movie Database (TMDB)](https://www.themoviedb.org/signup).
2. Go to **Settings > API** ([https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)).
3. Request an API Key (Developer) or generate an **API Read Access Token (v4 auth)**.

### 2. Configure the `.env` File
Create a `.env` file in the root of the project (alongside `pubspec.yaml`):

```bash
cp .env.example .env
```

Add your credentials inside `.env`:

```env
TMDB_API_KEY=YOUR_TMDB_API_KEY_HERE
TMDB_ACCESS_TOKEN=YOUR_TMDB_READ_ACCESS_TOKEN_HERE
TMDB_BASE_URL=https://api.themoviedb.org/3
TMDB_IMAGE_BASE_URL=https://image.tmdb.org/t/p
```

> **Important**: Never commit your `.env` file to Git. `.env` is already configured in `.gitignore` to protect your secret keys.

---

## 🚀 Getting Started & Running the Project

### Prerequisites
- Flutter SDK **3.41.1** (or `>= 3.19.0`)
- Dart SDK **3.11.0** (or `>= 3.3.0`)

### Installation & Run Steps

1. **Clone the repository**:
   ```bash
   git clone <repository_url>
   cd movie_browser
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   # Run on connected device or emulator
   flutter run

   # Or run specifically on Chrome / Windows / Android / iOS
   flutter run -d chrome
   flutter run -d windows
   ```

---

## 🧪 Running Tests & Code Analysis

### Run All Unit & Widget Tests:
```bash
flutter test
```

### Run Static Analysis:
```bash
flutter analyze
```

---

## 📦 Packages Used

| Package | Version | Purpose |
|---|---|---|
| `provider` | `^6.1.2` | State management solution |
| `http` | `^1.2.2` | HTTP requests to TMDB REST API |
| `flutter_dotenv` | `^5.2.1` | Environment variables configuration (.env) |
| `cached_network_image` | `^3.4.1` | Memory & disk image caching with placeholder support |
| `shimmer` | `^3.0.0` | Sleek shimmer skeleton loading effects |
| `shared_preferences` | `^2.3.2` | Local offline caching for movies and theme preferences |
| `intl` | `^0.19.0` | Date, number, and currency formatting |
| `google_fonts` | `^6.2.1` | Typography & Inter font family |
| `mocktail` | `^1.0.4` | Null-safe mocking for unit & widget testing |

---

## 📝 Assumptions & Notes
- The app supports both TMDB API Key (query parameter `api_key=...`) and Bearer Token authentication simultaneously for maximum reliability across TMDB v3 endpoints.
- In the event of offline mode or temporary network disconnection, the app gracefully presents previously cached results loaded from local storage.
