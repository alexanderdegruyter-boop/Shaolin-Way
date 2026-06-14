# Local demo videos

Drop your own `.mp4` files in this folder to use them as **offline** exercise demos.

## How to add a local video

1. Copy your file here, e.g. `assets/videos/horse_stance.mp4`.
2. It is already covered by the `assets/videos/` line in `pubspec.yaml`, so no
   edit is needed there. (If you add a *new* subfolder, list it in pubspec.)
3. In `assets/data/workouts.json`, set the exercise's:
   - `"videoType": "local"`
   - `"videoSource": "assets/videos/horse_stance.mp4"`
4. Run `flutter pub get` and rebuild.

The seeded workouts reference two local files that are **not bundled** by
default (`cat_stance.mp4`, `wide_leg_stretch.mp4`) to demonstrate the local
backend. Until you add them, the player shows a friendly "video not found"
card instead of crashing — add the files (or switch those exercises to
`youtube`) and they will play.

> Tip: keep clips short and compress them (e.g. 720p, H.264) so the APK stays small.
