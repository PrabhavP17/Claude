import Foundation

/// The 4-day cricket strength plan: Monday, Tuesday, Thursday and Friday.
/// Each day keeps a short internal id (A–D) that is stored with logged sessions.
public enum CricketPlan {
    public static let days: [WorkoutDay] = [dayA, dayB, dayD, dayC]

    public static func day(id: String) -> WorkoutDay? {
        days.first { $0.id == id }
    }

    public static func exercise(id: String) -> Exercise? {
        for day in days {
            if let exercise = day.exercises.first(where: { $0.id == id }) { return exercise }
        }
        return nil
    }

    static let dayA = WorkoutDay(
        id: "A",
        title: "Lower Body + Power",
        usualDay: "Monday",
        focus: "Driving power for batting and bowling, explosive first step, groin and hamstring injury-proofing.",
        warmup: ["5 min bike", "Leg swings ×10 each way", "Hip circles", "Glute bridges ×15", "3 practice squats with an empty bar"],
        exercises: [
            Exercise(id: "a.boxjump", name: "Box jump", cue: "Land soft, step down.", prescription: .fixed(sets: 3, reps: 5)),
            Exercise(id: "a.squat", name: "Back squat", cue: "Or goblet squat.", prescription: .phase, tracksWeight: true),
            Exercise(id: "a.rdl", name: "Romanian deadlift", prescription: .phase, tracksWeight: true),
            Exercise(id: "a.splitsquat", name: "Bulgarian split squat", prescription: .phase, perSide: true, tracksWeight: true),
            Exercise(id: "a.laterallunge", name: "Lateral lunge", cue: "Builds range for fielding.",
                     prescription: .fixed(sets: 3, reps: 8), perSide: true, tracksWeight: true),
            Exercise(id: "a.calf", name: "Calf raise", prescription: .fixed(sets: 3, reps: 15), tracksWeight: true),
            Exercise(id: "a.copenhagen", name: "Copenhagen plank", cue: "Protects the groin for lunging and diving.",
                     prescription: .timed(sets: 3, seconds: 20), perSide: true),
        ],
        cooldown: ["Hip flexor stretch 30 s", "Hamstring stretch 30 s", "Pigeon pose 30 s"]
    )

    static let dayB = WorkoutDay(
        id: "B",
        title: "Upper Body + Rotation",
        usualDay: "Tuesday",
        focus: "Bat speed, bowling and throwing power, healthy shoulders, strong wrists.",
        warmup: ["Band pull-aparts ×15", "Band shoulder pass-throughs ×10", "Open-book rotations ×8 each side", "Arm circles"],
        exercises: [
            Exercise(id: "b.medball", name: "Med ball rotational throw", cue: "Copy your batting and bowling motion.",
                     prescription: .fixed(sets: 3, reps: 6), perSide: true),
            Exercise(id: "b.bench", name: "Dumbbell bench press", prescription: .phase, tracksWeight: true),
            Exercise(id: "b.row", name: "Single-arm dumbbell row", prescription: .phase, perSide: true, tracksWeight: true),
            Exercise(id: "b.landmine", name: "Landmine press", cue: "Or half-kneeling dumbbell press.",
                     prescription: .phase, tracksWeight: true),
            Exercise(id: "b.woodchop", name: "Cable woodchop", cue: "High to low.",
                     prescription: .fixed(sets: 3, reps: 10), perSide: true, tracksWeight: true),
            Exercise(id: "b.facepull", name: "Face pull", prescription: .fixed(sets: 3, reps: 15), tracksWeight: true),
            Exercise(id: "b.extrot", name: "Band external rotation", cue: "Rotator cuff health for bowling and throwing.",
                     prescription: .fixed(sets: 3, reps: 15), perSide: true),
            Exercise(id: "b.wrist", name: "Wrist curl + reverse curl", cue: "Bat control.",
                     prescription: .fixed(sets: 2, reps: 15), tracksWeight: true),
        ],
        cooldown: ["Doorway pec stretch 30 s", "Sleeper stretch 30 s", "Lat stretch 30 s"]
    )

    static let dayD = WorkoutDay(
        id: "D",
        title: "Full Body + Posterior Chain",
        usualDay: "Thursday",
        focus: "Back, glutes and grip strength, total-body power. Speed day tomorrow, so don't go to failure on deadlifts.",
        warmup: ["5 min row machine", "Cat-cow ×10", "World's greatest stretch ×5 each side", "Glute bridges ×15"],
        exercises: [
            Exercise(id: "d.trapbar", name: "Trap bar deadlift", prescription: .phase, tracksWeight: true),
            Exercise(id: "d.pullup", name: "Pull-up", cue: "Or lat pulldown.", prescription: .phase),
            Exercise(id: "d.lunge", name: "Walking lunge", prescription: .phase, perSide: true, tracksWeight: true),
            Exercise(id: "d.incline", name: "Incline dumbbell press", cue: "Or push-ups.", prescription: .phase, tracksWeight: true),
            Exercise(id: "d.kbswing", name: "Kettlebell swing", cue: "Hip snap = bowling power.",
                     prescription: .fixed(sets: 3, reps: 15), tracksWeight: true),
            Exercise(id: "d.carry", name: "Farmer's carry", cue: "Grip strength for batting.",
                     prescription: .fixed(sets: 3, reps: 1), tracksWeight: true, unitLabel: "30 m"),
            Exercise(id: "d.slam", name: "Med ball slam", prescription: .fixed(sets: 3, reps: 8), tracksWeight: true),
        ],
        cooldown: ["90/90 hip switches", "Ankle mobility against the wall", "Thoracic rotations", "Hamstring floss"]
    )

    static let dayC = WorkoutDay(
        id: "C",
        title: "Speed, Agility + Conditioning",
        usualDay: "Friday",
        focus: "Running between the wickets, sharp fielding reactions, stamina for a long innings. If your sprint speed drops off, stop the sprint sets.",
        isConditioning: true,
        warmup: ["Light jog", "A-skips", "High knees", "Butt kicks", "Walking lunges with a twist", "2 build-up runs"],
        exercises: [
            Exercise(id: "c.accel", name: "Acceleration sprint", cue: "Walk back = rest.",
                     prescription: .fixed(sets: 6, reps: 1), unitLabel: "10 m sprint"),
            Exercise(id: "c.runthree", name: "Run-a-three", cue: "Like running between the wickets. Practise your turns.",
                     prescription: .fixed(sets: 5, reps: 1), unitLabel: "3 × 20 m with turns"),
            Exercise(id: "c.agility", name: "5-10-5 pro agility", prescription: .fixed(sets: 6, reps: 1), unitLabel: "drill"),
            Exercise(id: "c.reaction", name: "Shuffle + reaction sprint", cue: "Partner points or claps.",
                     prescription: .fixed(sets: 4, reps: 1), perSide: true, unitLabel: "drill"),
            Exercise(id: "c.intervals", name: "Bike or track intervals", cue: "30 s hard, then 90 s easy.",
                     prescription: .rounds(foundation: 6, strength: 8, deload: 3, power: 6, workSeconds: 30, restSeconds: 90)),
            Exercise(id: "c.core", name: "Core circuit", cue: "Dead bugs ×10, side plank 30 s each side, Pallof press ×10 each side.",
                     prescription: .fixed(sets: 3, reps: 1), unitLabel: "round"),
        ],
        cooldown: ["5 min easy walk", "Stretch calves, quads and hip flexors"]
    )
}
