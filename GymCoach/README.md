# Gym Coach

An Apple Watch and iPhone app that runs a 4-day strength and conditioning plan for cricket.

Open it at the gym and your watch shows today's workout, the current training phase, and the next exercise with its sets and reps. Tap **Done** after each set. A rest timer starts, your wrist taps at 10 seconds left, and again when it's time for the next set. The watch remembers what you lifted, suggests next session's weight, and saves the workout to Apple Health. Each finished workout syncs to the iPhone, which shows your history and a progress chart per lift.

## Features

**Apple Watch**
- Opens on today's session: Monday (lower body), Tuesday (upper body), Thursday (full body), Friday (speed and conditioning)
- Knows the phase from the date: Foundation, Strength, Deload or Power. Sets and reps change to match.
- Rest timer with haptics, sized to the phase (90–120 s for main lifts)
- Set the weight with the Digital Crown or the − / + buttons
- Progressive overload: if you hit the top of the rep range on every set last time, it suggests the next weight up
- Live heart rate, plus an Apple Health workout with calories, through HealthKit

**iPhone**
- The full plan, with warm-ups, cues and cool-downs
- History of every workout, set by set
- Progress chart of your top set for each lift
- kg / lb setting, which syncs to the watch

## How it's built

| Part | What it does |
|---|---|
| `Packages/GymCoachKit` | Swift package with the plan, phase schedule, set and rep prescriptions, and progression logic. No UI, fully unit tested. |
| `WatchApp/` | SwiftUI watchOS app. `WorkoutModel` steps through sets and runs the rest timer. `HealthWorkoutManager` runs the `HKWorkoutSession`. |
| `iOSApp/` | SwiftUI iPhone app: plan, history, Swift Charts progress, settings |
| `Shared/` | SwiftData storage (`SessionRecord`) and WatchConnectivity sync, used by both apps |

Stack: Swift, SwiftUI, SwiftData, HealthKit, WatchConnectivity, Swift Charts, XCTest. iOS 17+ and watchOS 10+ (Apple Watch Series 4 and later).

## Run it

You need a Mac with **Xcode 16** or later.

1. Install XcodeGen and generate the project:
   ```sh
   brew install xcodegen
   cd GymCoach
   xcodegen generate
   open GymCoach.xcodeproj
   ```
2. In Xcode, select each target (**GymCoach** and **GymCoachWatch**), open **Signing & Capabilities**, and pick your team. A free Apple ID works. If the bundle ID is taken, change `com.prabhav` in `project.yml` and run `xcodegen generate` again.
3. Turn on **Developer Mode** on your iPhone (Settings → Privacy & Security) and on your watch (Settings → Privacy & Security, after the first install attempt).
4. Choose the **GymCoachWatch** scheme and your Apple Watch as the run destination, then press **Run**. Then run the **GymCoach** scheme on your iPhone.
5. Allow Health access on the watch the first time you start a workout.

With a free Apple ID, apps you install yourself stop opening after 7 days. Press Run again to reinstall. A paid Apple Developer account removes that limit and lets you use TestFlight.

## Tests

```sh
cd Packages/GymCoachKit
swift test
```

The tests cover the phase calendar (including the 9-week cycle), deload set counts, conditioning rounds, and the weight progression rules.

## Customize the plan

Everything about the plan lives in `Packages/GymCoachKit/Sources/GymCoachKit/`:
- `CricketPlan.swift`: the exercises for each day
- `TrainingPhase.swift`: sets, reps and rest for each phase
- `PlanSchedule.swift`: the start date and which weekday runs which workout
