# CineWave

**Ride the story.** A cinematic streaming experience built with **Flutter** and **Material 3** — one codebase, six platforms, zero manual builds.

[![CI](https://github.com/L3von36/cinewave/actions/workflows/ci.yml/badge.svg)](https://github.com/L3von36/cinewave/actions/workflows/ci.yml)
[![Build & Release](https://github.com/L3von36/cinewave/actions/workflows/build.yml/badge.svg)](https://github.com/L3von36/cinewave/actions/workflows/build.yml)
[![Deploy Web](https://github.com/L3von36/cinewave/actions/workflows/deploy-web.yml/badge.svg)](https://github.com/L3von36/cinewave/actions/workflows/deploy-web.yml)
![Platforms](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20windows%20%7C%20macos%20%7C%20linux-7C6CFF)
![License](https://img.shields.io/badge/license-MIT-22D3EE)

CineWave is a fully offline-capable streaming app demo: a hand-tuned dark UI, a 28-title original catalog, a real video player with automatic fallback, and a Material You accent system — all wired to GitHub Actions so every platform binary is built for you on push or tag.

---

## Highlights

| | |
|---|---|
| **Material 3 dark-first design** | Seed-driven `ColorScheme`, tonal surfaces, M3 components everywhere |
| **Adaptive navigation** | Bottom bar on phones, rail on tablets, extended rail with wordmark on desktop |
| **Procedural poster art** | Every poster/backdrop is painted by a `CustomPainter` (gradient + soft-light orbs + film grain + vignette). No image assets, no network, pixel-perfect at any size |
| **Hero carousel** | Auto-advancing, parallax backdrop, glassy action buttons |
| **Top 10 rail** | Giant outlined numerals, Netflix-style |
| **Real player + fallback** | Streams public-domain MP4s on Android/iOS/macOS/Web; everywhere else a Ken Burns "simulated playback" stage keeps the demo alive offline |
| **Custom controls** | Seek bar with buffered track, double-tap ±10s, speed picker, fullscreen on handsets, autoplay next episode |
| **Material You accents** | Six seed colors in Settings — the entire app re-tones instantly |
| **Micro-interactions** | Shimmer skeletons, staggered entrances, haptics, confetti when you save to watchlist |
| **Persisted state** | Watchlist, continue-watching progress, theme and playback prefs via `shared_preferences` |

## Architecture

```mermaid
flowchart LR
    subgraph UI
        S[Splash] --> H[Home]
        H & E[Explore] & W[Watchlist] & ST[Settings] --- Shell[AdaptiveScaffold]
        D[Detail] --> P[Player]
    end
    subgraph State -- Riverpod --
        RP[routerProvider]
        MP[moviesProvider]
        WP[watchlistProvider]
        PP[progressProvider]
        TP[themeProvider]
    end
    subgraph Data
        MD[mock_data.dart 28 titles]
        Repo[MovieRepository]
        DB[(shared_preferences)]
    end
    UI --> State
    MP --> Repo --> MD
    WP & PP & TP --> DB
```

- **Routing** — `go_router` with `StatefulShellRoute.indexedStack` (tab state survives navigation; detail/player render full-screen above the shell).
- **State** — `flutter_riverpod` 2.x `Notifier`s; anything user-owned is persisted.
- **Data** — a typed `Movie`/`Season`/`Episode` model over an in-repo catalog. Swapping in TMDB or your own backend means replacing `MovieRepository.load()` — nothing else changes.

## Platform build matrix

Every push to `main` runs analyze + tests. **Build & Release** produces binaries on demand (`workflow_dispatch`) or automatically when you push a tag:

```bash
git tag v1.0.0 && git push origin v1.0.0
```

| Target | Runner | Artifacts |
|---|---|---|
| Android | `ubuntu-latest` | universal APK, per-ABI APKs, `.aab` |
| iOS | `macos-latest` | unsigned `.app` zip (`--no-codesign`) |
| Web | `ubuntu-latest` | static site (also auto-deployed to **GitHub Pages**) |
| Windows | `windows-latest` | x64 zip |
| macOS | `macos-latest` | unsigned `.app` zip |
| Linux | `ubuntu-latest` | x64 tarball |

Tagged builds are collected into a GitHub Release with auto-generated notes.

## Running locally

```bash
git clone https://github.com/L3von36/cinewave.git
cd cinewave
flutter pub get

# This repo intentionally ships without committed platform folders.
# One command regenerates them for your machine:
flutter create . --project-name cinewave --org com.cineapps

flutter run                # picks a device for you
flutter run -d chrome      # web
flutter run -d macos|windows|linux
```

> Requires Flutter **3.27+** (Dart 3.4+). Signed store artifacts (iOS `.ipa`, Play `.aab` signing) need your own certificates — see `build.yml` for the exact build steps to extend.

## Workflows

- **`ci.yml`** — `flutter analyze` + `flutter test` on pushes/PRs.
- **`deploy-web.yml`** — builds web with the correct `--base-href` and publishes to GitHub Pages on every push to `main`.
- **`build.yml`** — 6-job matrix (Android, iOS, Web, Windows, macOS, Linux) → artifacts on every run; on `v*` tags → GitHub Release.

## Design system in 30 seconds

- Font: **Outfit** (bundled, no runtime fetch)
- Dark surface stack: `#0B0D12` → `#242833` tonal ramp
- Default seed `#7C6CFF`, cyan/rose/amber/emerald/indigo accents available
- Radii: 8 / 12 / 18 / 24 (chips → tiles → cards → hero)
- Motion: 200–650 ms, `Curves.easeOutCubic`, staggered 50 ms

## Swapping in a real API

1. Add your client (e.g. TMDB) behind a new `MovieRepository` implementation.
2. Map results to the existing `Movie` model (or add nullable `imageUrl` and fall back to `PosterArt`).
3. Point `movieRepositoryProvider` at it. Shimmer, search, watchlist, progress and the player keep working.

## License

MIT — see [LICENSE](LICENSE).
