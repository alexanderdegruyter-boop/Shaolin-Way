# Shaolin Way 🧘

A private, single-user Android app for personal practice: **breathing exercises,
bodyweight workouts, guided instruction, real video demos, and a built-in book
reader.** Built with Flutter, designed to be sideloaded onto your own phone.

> No login. No accounts. No analytics. No ads. Minimal permissions.
> Everything works offline except streaming videos (which need internet only
> while playing).

---

## Features

- **Home / Dashboard** — daily suggestion, streak counter, total minutes,
  quick-start buttons (Breathe · Train · Read), and a calming line that rotates
  daily.
- **Breathe** — Box (4-4-4-4), Deep Dan Tian, 4-7-8 Calming, and Shaolin
  Energizing breaths. Animated orb synced to the phase timer, adjustable length,
  optional chime + haptics, and a "why this helps" note per pattern.
- **Train** — workouts across Warm-up, Foundational Stances, **Qi Gong (Ba Duan
  Jin / Eight Pieces of Brocade)**, the **Five Animals**, Strength, Flexibility,
  and Cool-down. Beginner / Intermediate / Advanced filters. Hands-free guided
  session that auto-advances with rest intervals + audio cues.
- **Video playback** — a real player with **two working backends**: inline
  **YouTube** (`youtube_player_flutter`) and bundled **local mp4**
  (`video_player`), auto-selected per exercise. Controls: play/pause, replay,
  scrubber, fullscreen. Seeded with **real Shaolin / Qi Gong instructional
  videos** (stances by Shaolin Temple instructors, the full Ba Duan Jin routine,
  Dan Tian breathing, the Five Animals) so it plays out of the box.
- **Read** — an ebook-style reader with **4 seeded, full-length books** rendered
  from Markdown: *The Shaolin Way* (philosophy), *Breath & Body* (training
  principles), *A Short History of Shaolin* (real temple history — founding,
  Bodhidharma, the warrior monks, the 1928 fire, the modern revival), and *The
  Way of Qi* (Qi Gong, the Eight Brocades, the Five Animals, the Muscle-Tendon
  Classic). Adjustable font size, light/sepia/dark themes, bookmark,
  continue-reading, chapter progress, and prev/next navigation.
- **Profile** — stats (sessions, streak, minutes) and settings (theme, sound,
  haptics, default session length, daily reminder notification).

---

## Project structure

```
shaolin_way/
├── pubspec.yaml                  # dependencies + asset manifest
├── lib/
│   ├── main.dart                 # app entry, providers, theming
│   ├── theme/app_theme.dart      # calm Zen light/dark themes
│   ├── models/                   # BreathingPattern, Workout/Exercise, Book
│   ├── services/
│   │   ├── content_service.dart  # loads JSON/Markdown from assets
│   │   ├── app_state.dart        # settings + progress (Hive-backed)
│   │   └── notification_service.dart
│   ├── widgets/
│   │   ├── breathing_orb.dart
│   │   └── video_player_widget.dart   # YouTube + local backends
│   └── screens/
│       ├── root_nav.dart         # bottom nav: Home·Breathe·Train·Read·Profile
│       ├── home_screen.dart
│       ├── breathe/ · train/ · read/ · profile/
├── assets/
│   ├── data/
│   │   ├── breathing.json        # breathing patterns (edit me)
│   │   └── workouts.json         # workouts + exercises + video refs (edit me)
│   ├── books/
│   │   ├── manifest.json            # list of books + chapters (edit me)
│   │   ├── shaolin_philosophy/      # book 1 chapters (.md)
│   │   ├── breathing_and_training/  # book 2 chapters (.md)
│   │   ├── shaolin_history/         # book 3 chapters (.md)
│   │   └── qi_gong_animals/         # book 4 chapters (.md)
│   └── videos/                   # drop your own local .mp4 demos here
└── android/app/src/main/AndroidManifest.xml   # permissions pre-configured
```

All content lives in `assets/` as JSON + Markdown, so you can edit workouts,
breathing patterns, and books **without touching app logic**.

---

## Building the APK

### Prerequisites (one-time)

1. Install **Flutter** (stable channel): https://docs.flutter.dev/get-started/install
2. Install **Android Studio** (for the Android SDK + build tools), then run:
   ```bash
   flutter doctor
   ```
   Resolve anything it flags for "Android toolchain". Accept licenses:
   ```bash
   flutter doctor --android-licenses
   ```

### Generate the Android scaffolding (one-time, in the project folder)

This repo ships the Dart code, assets, and a pre-configured `AndroidManifest.xml`,
but not the generated Android build files (Gradle wrapper, launcher icons, etc.).
Generate them with:

```bash
cd shaolin_way
flutter create --org com.personal --project-name shaolin_way --platforms=android .
```

`flutter create` **fills in only the missing files** — it will not overwrite your
`lib/`, `assets/`, `pubspec.yaml`, or the provided `AndroidManifest.xml`.

> ✅ After this step, confirm `android/app/src/main/AndroidManifest.xml` still
> contains the `INTERNET` and `POST_NOTIFICATIONS` permissions. If it was
> replaced, re-add the lines shown in that file (they're required for video and
> reminders). A reference copy is kept at `docs/AndroidManifest.reference.xml`.

### Build

```bash
flutter pub get
flutter build apk --release
```

The APK is produced at:

```
build/app/outputs/flutter-apk/app-release.apk
```

> Want a smaller download per device? Build split APKs instead:
> ```bash
> flutter build apk --split-per-abi
> ```
> Then use `app-arm64-v8a-release.apk` for any modern phone.

---

## Sideloading onto your phone

1. **Enable installing unknown apps** on your phone:
   - Android 8+: **Settings → Apps → Special access → Install unknown apps**
     → pick the app you'll transfer the APK with (e.g. Files, Chrome, Drive) →
     **Allow from this source**.
2. **Transfer the APK** to the phone — USB cable, Google Drive, or email it to
   yourself.
3. **Open the APK** on the phone (via the Files app) and tap **Install**.
4. Launch **Shaolin Way**. Done.

> Alternatively, with the phone connected via USB and developer USB-debugging on:
> ```bash
> flutter install            # builds + installs to the connected device
> # or
> adb install build/app/outputs/flutter-apk/app-release.apk
> ```

---

## Adding your own videos

Each exercise in `assets/data/workouts.json` has a `videoType` and `videoSource`.

### YouTube video
```json
{
  "name": "My Exercise",
  "videoType": "youtube",
  "videoSource": "dQw4w9WgXcQ"   // the 11-char ID after v= in the URL
}
```
From a URL like `https://www.youtube.com/watch?v=dQw4w9WgXcQ`, the ID is
`dQw4w9WgXcQ`. The seeded IDs are placeholders — **swap them for your own
demos.** (If a video shows "unavailable", its owner has disabled embedding;
pick another.)

### Local (offline) video
1. Copy your `.mp4` into `assets/videos/`, e.g. `assets/videos/horse_stance.mp4`.
2. Set the exercise:
   ```json
   {
     "videoType": "local",
     "videoSource": "assets/videos/horse_stance.mp4"
   }
   ```
3. `assets/videos/` is already declared in `pubspec.yaml`, so just run
   `flutter pub get` and rebuild. (Add a new line under `assets:` only if you
   create a new subfolder.)

> Two seeded exercises point at local files that aren't bundled
> (`cat_stance.mp4`, `wide_leg_stretch.mp4`) to demonstrate the offline backend.
> Until you add those files, the player shows a friendly "video not bundled"
> card instead of crashing.

---

## Adding your own books

Books are plain Markdown. To add one:

1. Create a folder, e.g. `assets/books/my_book/`.
2. Add chapter files: `assets/books/my_book/ch1.md`, `ch2.md`, …
   (Markdown headings, **bold**, *italic*, lists, and > blockquotes all render.)
3. Add an entry to `assets/books/manifest.json`:
   ```json
   {
     "id": "my_book",
     "title": "My Book Title",
     "author": "Subtitle or author",
     "description": "One-line description.",
     "chapters": [
       { "title": "1. First Chapter", "file": "assets/books/my_book/ch1.md" },
       { "title": "2. Second Chapter", "file": "assets/books/my_book/ch2.md" }
     ]
   }
   ```
4. Declare the new folder in `pubspec.yaml` under `assets:`:
   ```yaml
   - assets/books/my_book/
   ```
5. Run `flutter pub get` and rebuild.

---

## Editing workouts & breathing patterns

- **Workouts:** edit `assets/data/workouts.json`. Each workout has a `category`,
  `level` (Beginner/Intermediate/Advanced), and a list of `exercises` with
  step-by-step `instructions`, a video, and either `durationSeconds` (timed) or
  `reps` (rep-based), plus `restSeconds`.
- **Breathing:** edit `assets/data/breathing.json`. Each pattern has `phases`
  (type `inhale` / `hold` / `exhale` / `holdEmpty`, each with `seconds`) which
  drive the animated orb automatically.

No code changes needed — edit the JSON, run `flutter pub get`, rebuild.

---

## Permissions used (and why)

| Permission | Why |
|---|---|
| `INTERNET` | Stream YouTube demo videos |
| `POST_NOTIFICATIONS` | Optional daily practice reminder |
| `RECEIVE_BOOT_COMPLETED` | Re-arm the reminder after a reboot |
| `VIBRATE` | Haptic cues on breathing/workout phase changes |

That's it — no location, contacts, camera, or storage-scraping permissions.

---

## Tech notes

- **State/storage:** `provider` + `hive` (offline key/value for settings &
  progress).
- **Reader:** `flutter_markdown`.
- **Video:** `youtube_player_flutter` + `video_player`.
- **Reminders:** `flutter_local_notifications` + `timezone` (inexact alarms, so
  no special exact-alarm permission is required).

Enjoy the practice. 🥋
