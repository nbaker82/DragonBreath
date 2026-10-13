import SwiftData
import Foundation

struct WorkoutSeeder {

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Workout>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        // MARK: - Weightlifting Movements

        // Olympic Lifts - Snatch family
        let snatch              = Movement(name: "Snatch",                      category: .weightlifting, scoreTypes: [.weight, .reps])
        let powerSnatch         = Movement(name: "Power Snatch",                category: .weightlifting, scoreTypes: [.weight, .reps])
        let hangPowerSnatch     = Movement(name: "Hang Power Snatch",           category: .weightlifting, scoreTypes: [.weight, .reps])
        let hangSquatSnatch     = Movement(name: "Hang Squat Snatch",           category: .weightlifting, scoreTypes: [.weight, .reps])
        let highHangSnatch      = Movement(name: "High Hang Snatch",            category: .weightlifting, scoreTypes: [.weight, .reps])
        let snatchPull          = Movement(name: "Snatch Pull",                 category: .weightlifting, scoreTypes: [.weight, .reps])
        let snatchBalance       = Movement(name: "Snatch Balance",              category: .weightlifting, scoreTypes: [.weight, .reps])
        let muscleSnatch        = Movement(name: "Muscle Snatch",               category: .weightlifting, scoreTypes: [.weight, .reps])
        let dropSnatch          = Movement(name: "Drop Snatch",                 category: .weightlifting, scoreTypes: [.weight, .reps])
        let pauseSnatch         = Movement(name: "Pause Snatch",                category: .weightlifting, scoreTypes: [.weight, .reps])
        let tempoSnatch         = Movement(name: "Tempo Snatch",                category: .weightlifting, scoreTypes: [.weight, .reps])
        let blockSnatch         = Movement(name: "Block Snatch",                category: .weightlifting, scoreTypes: [.weight, .reps])
        let ohs                 = Movement(name: "Overhead Squat",              category: .weightlifting, scoreTypes: [.weight, .reps])
        let pauseOHS            = Movement(name: "Pause Overhead Squat",        category: .weightlifting, scoreTypes: [.weight, .reps])

        // Olympic Lifts - Clean family
        let clean               = Movement(name: "Clean",                       category: .weightlifting, scoreTypes: [.weight, .reps])
        let powerClean          = Movement(name: "Power Clean",                 category: .weightlifting, scoreTypes: [.weight, .reps])
        let hangPowerClean      = Movement(name: "Hang Power Clean",            category: .weightlifting, scoreTypes: [.weight, .reps])
        let hangSquatClean      = Movement(name: "Hang Squat Clean",            category: .weightlifting, scoreTypes: [.weight, .reps])
        let highHangClean       = Movement(name: "High Hang Clean",             category: .weightlifting, scoreTypes: [.weight, .reps])
        let cleanPull           = Movement(name: "Clean Pull",                  category: .weightlifting, scoreTypes: [.weight, .reps])
        let pauseClean          = Movement(name: "Pause Clean",                 category: .weightlifting, scoreTypes: [.weight, .reps])
        let tempoClean          = Movement(name: "Tempo Clean",                 category: .weightlifting, scoreTypes: [.weight, .reps])
        let blockClean          = Movement(name: "Block Clean",                 category: .weightlifting, scoreTypes: [.weight, .reps])
        let tallClean           = Movement(name: "Tall Clean",                  category: .weightlifting, scoreTypes: [.weight, .reps])
        let cleanAndJerk        = Movement(name: "Clean & Jerk",                category: .weightlifting, scoreTypes: [.weight, .reps])

        // Olympic Lifts - Jerk family
        let splitJerk           = Movement(name: "Split Jerk",                  category: .weightlifting, scoreTypes: [.weight, .reps])
        let pushJerk            = Movement(name: "Push Jerk",                   category: .weightlifting, scoreTypes: [.weight, .reps])
        let pushPress           = Movement(name: "Push Press",                  category: .weightlifting, scoreTypes: [.weight, .reps])
        let pauseJerk           = Movement(name: "Pause Jerk",                  category: .weightlifting, scoreTypes: [.weight, .reps])
        let behindNeckJerk      = Movement(name: "Behind-Neck Jerk",            category: .weightlifting, scoreTypes: [.weight, .reps])

        // Squats
        let backSquat           = Movement(name: "Back Squat",                  category: .weightlifting, scoreTypes: [.weight, .reps])
        let frontSquat          = Movement(name: "Front Squat",                 category: .weightlifting, scoreTypes: [.weight, .reps])
        let pauseBackSquat      = Movement(name: "Pause Back Squat",            category: .weightlifting, scoreTypes: [.weight, .reps])
        let pauseFrontSquat     = Movement(name: "Pause Front Squat",           category: .weightlifting, scoreTypes: [.weight, .reps])
        let boxSquat            = Movement(name: "Box Squat",                   category: .weightlifting, scoreTypes: [.weight, .reps])
        let airSquat            = Movement(name: "Air Squat",                   category: .gymnastics,    scoreTypes: [.reps])

        // Deadlifts
        let deadlift            = Movement(name: "Deadlift",                    category: .weightlifting, scoreTypes: [.weight, .reps])
        let sumoDeadlift        = Movement(name: "Sumo Deadlift",               category: .weightlifting, scoreTypes: [.weight, .reps])
        let deficitDeadlift     = Movement(name: "Deficit Deadlift",            category: .weightlifting, scoreTypes: [.weight, .reps])
        let romanianDeadlift    = Movement(name: "Romanian Deadlift",           category: .weightlifting, scoreTypes: [.weight, .reps])
        let haltingDeadlift     = Movement(name: "Halting Deadlift",            category: .weightlifting, scoreTypes: [.weight, .reps])
        let eccentricDeadlift   = Movement(name: "Eccentric Deadlift",          category: .weightlifting, scoreTypes: [.weight, .reps])
        let sdlhp               = Movement(name: "Sumo Deadlift High Pull",     category: .weightlifting, scoreTypes: [.weight, .reps])

        // Pressing
        let strictPress         = Movement(name: "Strict Press",                category: .weightlifting, scoreTypes: [.weight, .reps])
        let thruster            = Movement(name: "Thruster",                    category: .weightlifting, scoreTypes: [.weight, .reps])
        let benchPress          = Movement(name: "Bench Press",                 category: .weightlifting, scoreTypes: [.weight, .reps])
        let inclineBenchPress   = Movement(name: "Incline Bench Press",         category: .weightlifting, scoreTypes: [.weight, .reps])
        let cluster             = Movement(name: "Cluster",                     category: .weightlifting, scoreTypes: [.weight, .reps])

        // Complexes
        let bearComplex         = Movement(name: "Bear Complex",                category: .weightlifting, scoreTypes: [.weight, .reps])
        let machoMan            = Movement(name: "Macho Man Complex",           category: .weightlifting, scoreTypes: [.weight, .reps])

        // Accessory
        let wallBall            = Movement(name: "Wall Ball",                   category: .weightlifting, scoreTypes: [.weight, .reps])
        let goodMorning         = Movement(name: "Good Morning",                category: .weightlifting, scoreTypes: [.weight, .reps])

        // MARK: - Gymnastics Movements

        // Pull-up family
        let pullUp              = Movement(name: "Pull-up",                     category: .gymnastics,    scoreTypes: [.reps])
        let strictPullUp        = Movement(name: "Strict Pull-up",              category: .gymnastics,    scoreTypes: [.reps])
        let weightedPullUp      = Movement(name: "Weighted Pull-up",            category: .gymnastics,    scoreTypes: [.weight, .reps])
        let chestToBar          = Movement(name: "Chest-to-Bar Pull-up",        category: .gymnastics,    scoreTypes: [.reps])
        let strictC2B           = Movement(name: "Strict Chest-to-Bar",         category: .gymnastics,    scoreTypes: [.reps])
        let commandoPullUp      = Movement(name: "Commando Pull-up",            category: .gymnastics,    scoreTypes: [.reps])
        let lSitPullUp          = Movement(name: "L-Sit Pull-up",              category: .gymnastics,    scoreTypes: [.reps])
        let ringRow              = Movement(name: "Ring Row",                    category: .gymnastics,    scoreTypes: [.reps])

        // Muscle-up family
        let ringMuscleUp        = Movement(name: "Ring Muscle-up",              category: .gymnastics,    scoreTypes: [.reps])
        let barMuscleUp         = Movement(name: "Bar Muscle-up",               category: .gymnastics,    scoreTypes: [.reps])
        let strictMuscleUp      = Movement(name: "Strict Muscle-up",            category: .gymnastics,    scoreTypes: [.reps])

        // Push / Dip family
        let pushUp              = Movement(name: "Push-up",                     category: .gymnastics,    scoreTypes: [.reps])
        let ringDip             = Movement(name: "Ring Dip",                    category: .gymnastics,    scoreTypes: [.reps])
        let strictRingDip       = Movement(name: "Strict Ring Dip",             category: .gymnastics,    scoreTypes: [.reps])
        let weightedRingDip     = Movement(name: "Weighted Ring Dip",           category: .gymnastics,    scoreTypes: [.weight, .reps])
        let dip                 = Movement(name: "Dip",                         category: .gymnastics,    scoreTypes: [.reps])

        // Handstand family
        let hspu                = Movement(name: "Handstand Push-up",           category: .gymnastics,    scoreTypes: [.reps])
        let strictHSPU          = Movement(name: "Strict Handstand Push-up",    category: .gymnastics,    scoreTypes: [.reps])
        let deficitHSPU         = Movement(name: "Deficit Handstand Push-up",   category: .gymnastics,    scoreTypes: [.reps])
        let handstandWalk       = Movement(name: "Handstand Walk",              category: .gymnastics,    scoreTypes: [.distance, .reps])
        let wallWalk            = Movement(name: "Wall Walk",                   category: .gymnastics,    scoreTypes: [.reps])

        // Core / Hanging
        let toeToBar            = Movement(name: "Toes-to-Bar",                 category: .gymnastics,    scoreTypes: [.reps])
        let kneesToElbows       = Movement(name: "Knees-to-Elbows",             category: .gymnastics,    scoreTypes: [.reps])
        let sitUp               = Movement(name: "Sit-up",                      category: .gymnastics,    scoreTypes: [.reps])
        let ghdSitUp            = Movement(name: "GHD Sit-up",                  category: .gymnastics,    scoreTypes: [.reps])
        let hipExtension        = Movement(name: "Hip Extension",               category: .gymnastics,    scoreTypes: [.reps])
        let lSit                = Movement(name: "L-Sit",                       category: .gymnastics,    scoreTypes: [.time, .reps])
        let hollowHold          = Movement(name: "Hollow Hold",                 category: .gymnastics,    scoreTypes: [.time])

        // Climbing
        let ropeClimb           = Movement(name: "Rope Climb",                  category: .gymnastics,    scoreTypes: [.reps])
        let leglessRopeClimb    = Movement(name: "Legless Rope Climb",          category: .gymnastics,    scoreTypes: [.reps])
        let pegboard            = Movement(name: "Pegboard",                    category: .gymnastics,    scoreTypes: [.reps])

        // Jumps / Plyometrics
        let boxJump             = Movement(name: "Box Jump",                    category: .gymnastics,    scoreTypes: [.height, .reps])
        let boxJumpOver         = Movement(name: "Box Jump Over",               category: .gymnastics,    scoreTypes: [.height, .reps])
        let broadJump           = Movement(name: "Broad Jump",                  category: .gymnastics,    scoreTypes: [.distance, .reps])
        let pistol              = Movement(name: "Pistol Squat",                category: .gymnastics,    scoreTypes: [.reps])

        // Burpee family
        let burpee              = Movement(name: "Burpee",                      category: .gymnastics,    scoreTypes: [.reps])
        let barFacingBurpee     = Movement(name: "Bar-Facing Burpee",           category: .gymnastics,    scoreTypes: [.reps])
        let lateralBurpee       = Movement(name: "Lateral Burpee",              category: .gymnastics,    scoreTypes: [.reps])
        let burpeeBoxJump       = Movement(name: "Burpee Box Jump",             category: .gymnastics,    scoreTypes: [.reps])
        let burpeePullUp        = Movement(name: "Burpee Pull-up",              category: .gymnastics,    scoreTypes: [.reps])
        let handReleasePushUp   = Movement(name: "Hand-Release Push-up",        category: .gymnastics,    scoreTypes: [.reps])

        // MARK: - Monostructural Movements

        let run                 = Movement(name: "Run",                         category: .monostructural, scoreTypes: [.distance, .time])
        let row                 = Movement(name: "Row",                         category: .monostructural, scoreTypes: [.distance, .time])
        let doubleUnder         = Movement(name: "Double-Under",                category: .monostructural, scoreTypes: [.reps])
        let singleUnder         = Movement(name: "Single-Under",                category: .monostructural, scoreTypes: [.reps])
        let assaultBike         = Movement(name: "Assault Bike",                category: .monostructural, scoreTypes: [.distance, .time, .reps])
        let echoBike            = Movement(name: "Echo Bike",                   category: .monostructural, scoreTypes: [.distance, .time, .reps])
        let skiErg              = Movement(name: "Ski Erg",                     category: .monostructural, scoreTypes: [.distance, .time])
        let bikeErg             = Movement(name: "Bike Erg",                    category: .monostructural, scoreTypes: [.distance, .time])
        let swim                = Movement(name: "Swim",                        category: .monostructural, scoreTypes: [.distance, .time])

        // MARK: - Strongman / Odd Object Movements

        // Kettlebell
        let kbSwingAmerican     = Movement(name: "Kettlebell Swing (American)", category: .strongman,     scoreTypes: [.weight, .reps])
        let kbSwingRussian      = Movement(name: "Kettlebell Swing (Russian)",  category: .strongman,     scoreTypes: [.weight, .reps])
        let kbSnatch            = Movement(name: "Kettlebell Snatch",           category: .strongman,     scoreTypes: [.weight, .reps])
        let kbClean             = Movement(name: "Kettlebell Clean",            category: .strongman,     scoreTypes: [.weight, .reps])
        let kbThruster          = Movement(name: "Kettlebell Thruster",         category: .strongman,     scoreTypes: [.weight, .reps])
        let kbGobletSquat       = Movement(name: "Kettlebell Goblet Squat",     category: .strongman,     scoreTypes: [.weight, .reps])
        let kbTurkishGetUp      = Movement(name: "Turkish Get-up",              category: .strongman,     scoreTypes: [.weight, .reps])
        let kbFarmerCarry       = Movement(name: "Kettlebell Farmer Carry",     category: .strongman,     scoreTypes: [.weight, .distance])
        let kbOHS               = Movement(name: "Kettlebell Overhead Squat",   category: .strongman,     scoreTypes: [.weight, .reps])
        let kbPushJerk          = Movement(name: "Kettlebell Push Jerk",        category: .strongman,     scoreTypes: [.weight, .reps])

        // Dumbbell
        let dbSnatch            = Movement(name: "Dumbbell Snatch",             category: .strongman,     scoreTypes: [.weight, .reps])
        let dbClean             = Movement(name: "Dumbbell Clean",              category: .strongman,     scoreTypes: [.weight, .reps])
        let dbThruster          = Movement(name: "Dumbbell Thruster",           category: .strongman,     scoreTypes: [.weight, .reps])
        let dbBenchPress        = Movement(name: "Dumbbell Bench Press",        category: .strongman,     scoreTypes: [.weight, .reps])
        let dbRow               = Movement(name: "Dumbbell Row",                category: .strongman,     scoreTypes: [.weight, .reps])
        let dbLunge             = Movement(name: "Dumbbell Lunge",              category: .strongman,     scoreTypes: [.weight, .reps])
        let devilPress          = Movement(name: "Devil Press",                 category: .strongman,     scoreTypes: [.weight, .reps])
        let manMaker            = Movement(name: "Man Maker",                   category: .strongman,     scoreTypes: [.weight, .reps])
        let dbFarmerCarry       = Movement(name: "Dumbbell Farmer Carry",       category: .strongman,     scoreTypes: [.weight, .distance])
        let dbOHLunge           = Movement(name: "DB Overhead Walking Lunge",   category: .strongman,     scoreTypes: [.weight, .reps])

        // Sandbag
        let sandbagClean        = Movement(name: "Sandbag Clean",               category: .strongman,     scoreTypes: [.weight, .reps])
        let sandbagCarry        = Movement(name: "Sandbag Carry",               category: .strongman,     scoreTypes: [.weight, .distance])
        let sandbagOverShoulder = Movement(name: "Sandbag Over Shoulder",       category: .strongman,     scoreTypes: [.weight, .reps])
        let sandbagSquat        = Movement(name: "Sandbag Squat",               category: .strongman,     scoreTypes: [.weight, .reps])
        let sandbagRun          = Movement(name: "Sandbag Run",                 category: .strongman,     scoreTypes: [.weight, .distance])

        // Other odd objects
        let yoke                = Movement(name: "Yoke Carry",                  category: .strongman,     scoreTypes: [.weight, .distance])
        let sledPush            = Movement(name: "Sled Push",                   category: .strongman,     scoreTypes: [.weight, .distance])
        let atlasStone          = Movement(name: "Atlas Stone",                 category: .strongman,     scoreTypes: [.weight, .reps])
        let medicineBall        = Movement(name: "Medicine Ball",               category: .strongman,     scoreTypes: [.weight, .reps])
        let battleRopes         = Movement(name: "Battle Ropes",                category: .strongman,     scoreTypes: [.time, .reps])
        let wreckbag            = Movement(name: "Wreckbag",                    category: .strongman,     scoreTypes: [.weight, .reps])
        let logCleanPress       = Movement(name: "Log Clean & Press",           category: .strongman,     scoreTypes: [.weight, .reps])

        let allMovements: [Movement] = [
            // Snatch family
            snatch, powerSnatch, hangPowerSnatch, hangSquatSnatch, highHangSnatch,
            snatchPull, snatchBalance, muscleSnatch, dropSnatch,
            pauseSnatch, tempoSnatch, blockSnatch, ohs, pauseOHS,
            // Clean family
            clean, powerClean, hangPowerClean, hangSquatClean, highHangClean,
            cleanPull, pauseClean, tempoClean, blockClean, tallClean, cleanAndJerk,
            // Jerk / Press family
            splitJerk, pushJerk, pushPress, pauseJerk, behindNeckJerk, strictPress,
            thruster, benchPress, inclineBenchPress, cluster,
            // Complexes
            bearComplex, machoMan,
            // Squats
            backSquat, frontSquat, pauseBackSquat, pauseFrontSquat, boxSquat, airSquat,
            // Deadlifts
            deadlift, sumoDeadlift, deficitDeadlift, romanianDeadlift,
            haltingDeadlift, eccentricDeadlift, sdlhp,
            // Accessory
            wallBall, goodMorning,
            // Gymnastics - pull
            pullUp, strictPullUp, weightedPullUp, chestToBar, strictC2B,
            commandoPullUp, lSitPullUp, ringRow,
            // Gymnastics - muscle-up
            ringMuscleUp, barMuscleUp, strictMuscleUp,
            // Gymnastics - push/dip
            pushUp, ringDip, strictRingDip, weightedRingDip, dip,
            // Gymnastics - handstand
            hspu, strictHSPU, deficitHSPU, handstandWalk, wallWalk,
            // Gymnastics - core
            toeToBar, kneesToElbows, sitUp, ghdSitUp, hipExtension, lSit, hollowHold,
            // Gymnastics - climbing
            ropeClimb, leglessRopeClimb, pegboard,
            // Gymnastics - jumps
            boxJump, boxJumpOver, broadJump, pistol,
            // Gymnastics - burpee
            burpee, barFacingBurpee, lateralBurpee, burpeeBoxJump,
            burpeePullUp, handReleasePushUp,
            // Monostructural
            run, row, doubleUnder, singleUnder, assaultBike, echoBike, skiErg, bikeErg, swim,
            // Strongman - KB
            kbSwingAmerican, kbSwingRussian, kbSnatch, kbClean, kbThruster,
            kbGobletSquat, kbTurkishGetUp, kbFarmerCarry, kbOHS, kbPushJerk,
            // Strongman - DB
            dbSnatch, dbClean, dbThruster, dbBenchPress, dbRow,
            dbLunge, devilPress, manMaker, dbFarmerCarry, dbOHLunge,
            // Strongman - Sandbag
            sandbagClean, sandbagCarry, sandbagOverShoulder, sandbagSquat, sandbagRun,
            // Strongman - other
            yoke, sledPush, atlasStone, medicineBall, battleRopes, wreckbag, logCleanPress
        ]
        allMovements.forEach { context.insert($0) }

        // MARK: - Benchmark Girls

        let girls: [Workout] = [
            Workout(
                name: "Fran",
                workoutType: .forTime,
                workoutDescription: "21-15-9 reps for time:\nThrusters (95/65 lbs)\nPull-ups",
                isBenchmark: true,
                movements: [thruster, pullUp]
            ),
            Workout(
                name: "Helen",
                workoutType: .rft,
                workoutDescription: "3 rounds for time:\n400m Run\n21 Kettlebell Swings (53/35 lbs)\n12 Pull-ups",
                isBenchmark: true,
                movements: [run, kbSwingAmerican, pullUp]
            ),
            Workout(
                name: "Annie",
                workoutType: .forTime,
                workoutDescription: "50-40-30-20-10 reps for time:\nDouble-Unders\nSit-ups",
                isBenchmark: true,
                movements: [doubleUnder, sitUp]
            ),
            Workout(
                name: "Diane",
                workoutType: .forTime,
                workoutDescription: "21-15-9 reps for time:\nDeadlift (225/155 lbs)\nHandstand Push-ups",
                isBenchmark: true,
                movements: [deadlift, hspu]
            ),
            Workout(
                name: "Grace",
                workoutType: .forTime,
                workoutDescription: "30 Clean & Jerks (135/95 lbs) for time",
                isBenchmark: true,
                movements: [cleanAndJerk]
            ),
            Workout(
                name: "Isabel",
                workoutType: .forTime,
                workoutDescription: "30 Snatches (135/95 lbs) for time",
                isBenchmark: true,
                movements: [snatch]
            ),
            Workout(
                name: "Nancy",
                workoutType: .rft,
                workoutDescription: "5 rounds for time:\n400m Run\n15 Overhead Squats (95/65 lbs)",
                isBenchmark: true,
                movements: [run, ohs]
            ),
            Workout(
                name: "Amanda",
                workoutType: .forTime,
                workoutDescription: "9-7-5 reps for time:\nMuscle-ups\nSnatches (135/95 lbs)",
                isBenchmark: true,
                movements: [ringMuscleUp, snatch]
            ),
            Workout(
                name: "Elizabeth",
                workoutType: .forTime,
                workoutDescription: "21-15-9 reps for time:\nCleans (135/95 lbs)\nRing Dips",
                isBenchmark: true,
                movements: [clean, ringDip]
            ),
            Workout(
                name: "Jackie",
                workoutType: .forTime,
                workoutDescription: "For time:\n1000m Row\n50 Thrusters (45/35 lbs)\n30 Pull-ups",
                isBenchmark: true,
                movements: [row, thruster, pullUp]
            ),
            Workout(
                name: "Kelly",
                workoutType: .rft,
                workoutDescription: "5 rounds for time:\n400m Run\n30 Box Jumps (24/20 in)\n30 Wall Balls (20/14 lbs)",
                isBenchmark: true,
                movements: [run, boxJump, wallBall]
            ),
            Workout(
                name: "Barbara",
                workoutType: .rft,
                workoutDescription: "5 rounds for time:\n20 Pull-ups\n30 Push-ups\n40 Sit-ups\n50 Air Squats\n(3 min rest between rounds)",
                isBenchmark: true,
                movements: [pullUp, pushUp, sitUp, airSquat]
            ),
            Workout(
                name: "Chelsea",
                workoutType: .emom,
                workoutDescription: "30 minute EMOM:\n5 Pull-ups\n10 Push-ups\n15 Air Squats",
                timeCap: 1800,
                isBenchmark: true,
                movements: [pullUp, pushUp, airSquat]
            ),
            Workout(
                name: "Cindy",
                workoutType: .amrap,
                workoutDescription: "20 minute AMRAP:\n5 Pull-ups\n10 Push-ups\n15 Air Squats",
                timeCap: 1200,
                isBenchmark: true,
                movements: [pullUp, pushUp, airSquat]
            ),
            Workout(
                name: "DT",
                workoutType: .rft,
                workoutDescription: "5 rounds for time:\n12 Deadlifts (155/105 lbs)\n9 Hang Power Cleans (155/105 lbs)\n6 Push Jerks (155/105 lbs)",
                isBenchmark: true,
                movements: [deadlift, hangPowerClean, pushJerk]
            ),
            Workout(
                name: "Linda",
                workoutType: .forTime,
                workoutDescription: "10-9-8-7-6-5-4-3-2-1 reps for time:\nDeadlift (1.5x BW)\nBench Press (BW)\nClean (0.75x BW)",
                isBenchmark: true,
                movements: [deadlift, benchPress, clean]
            ),
            Workout(
                name: "Nasty Girls",
                workoutType: .rft,
                workoutDescription: "3 rounds for time:\n50 Air Squats\n7 Muscle-ups\n10 Hang Power Cleans (135/95 lbs)",
                isBenchmark: true,
                movements: [airSquat, ringMuscleUp, hangPowerClean]
            ),
            Workout(
                name: "Angie",
                workoutType: .forTime,
                workoutDescription: "For time:\n100 Pull-ups\n100 Push-ups\n100 Sit-ups\n100 Air Squats",
                isBenchmark: true,
                movements: [pullUp, pushUp, sitUp, airSquat]
            ),
            Workout(
                name: "Nate",
                workoutType: .amrap,
                workoutDescription: "20 minute AMRAP:\n2 Muscle-ups\n4 Handstand Push-ups\n8 Kettlebell Swings (70/53 lbs)",
                timeCap: 1200,
                isBenchmark: true,
                movements: [ringMuscleUp, hspu, kbSwingAmerican]
            ),
            Workout(
                name: "J.T.",
                workoutType: .forTime,
                workoutDescription: "21-15-9 reps for time:\nHandstand Push-ups\nRing Dips\nPush-ups",
                isBenchmark: true,
                movements: [hspu, ringDip, pushUp]
            ),
            Workout(
                name: "Fight Gone Bad",
                workoutType: .amrap,
                workoutDescription: "3 rounds, 1 minute at each station:\nWall Balls (20/14 lbs, 10 ft)\nSumo Deadlift High Pull (75/55 lbs)\nBox Jumps (20 in)\nPush Press (75/55 lbs)\nRow (calories)\n(1 min rest between rounds)",
                timeCap: 1020,
                isBenchmark: true,
                movements: [wallBall, sdlhp, boxJump, pushPress, row]
            ),
            Workout(
                name: "Heartbreak Kid",
                workoutType: .forTime,
                workoutDescription: "4 rounds for time:\n1000m Row\n50 Burpees\n50 Box Jumps (24/20 in)",
                isBenchmark: true,
                movements: [row, burpee, boxJump]
            ),
            Workout(
                name: "Bell",
                workoutType: .forTime,
                workoutDescription: "For time:\n21-15-9 reps of:\nKettlebell Swings (70/53 lbs)\nPull-ups",
                isBenchmark: true,
                movements: [kbSwingAmerican, pullUp]
            ),
            Workout(
                name: "Gwen",
                workoutType: .strength,
                workoutDescription: "15-12-9 reps (touch and go) Clean & Jerk\nUnbroken sets only. Rest as needed between sets.\nScore is highest load.",
                isBenchmark: true,
                movements: [cleanAndJerk]
            ),
        ]
        girls.forEach { context.insert($0) }

        // MARK: - Hero WODs

        let heroes: [Workout] = [
            Workout(
                name: "Murph",
                workoutType: .forTime,
                workoutDescription: "For time:\n1 mile Run\n100 Pull-ups\n200 Push-ups\n300 Air Squats\n1 mile Run\n(Partition pull-ups, push-ups, and squats as needed.\nStart and finish with the run.)\nWith 20 lb vest / body armor.",
                isBenchmark: false,
                isHero: true,
                movements: [run, pullUp, pushUp, airSquat]
            ),
            Workout(
                name: "Chad",
                workoutType: .forTime,
                workoutDescription: "For time:\n1000 Box Step-ups (20 in)\nWith 45 lb ruck",
                isHero: true,
                movements: [boxJumpOver]
            ),
            Workout(
                name: "Severin",
                workoutType: .forTime,
                workoutDescription: "For time:\n1 mile Run\n50 Burpees\n50 Knees-to-Elbows\n50 Box Jumps (24/20 in)\n50 Kettlebell Swings (53/35 lbs)\n50 Pull-ups\n1 mile Run",
                isHero: true,
                movements: [run, burpee, kneesToElbows, boxJump, kbSwingAmerican, pullUp]
            ),
            Workout(
                name: "Maxton",
                workoutType: .forTime,
                workoutDescription: "For time:\n1 mile Run\n100 Pull-ups\n200 Push-ups\n300 Air Squats\n1 mile Run\nWith 20 lb vest.",
                isHero: true,
                movements: [run, pullUp, pushUp, airSquat]
            ),
            Workout(
                name: "Glen",
                workoutType: .forTime,
                workoutDescription: "For time:\n30 Clean & Jerks (135/95 lbs)\n1 mile Run\n10 Muscle-ups\n100 Squats\n20 Handstand Push-ups",
                isHero: true,
                movements: [cleanAndJerk, run, ringMuscleUp, airSquat, hspu]
            ),
            Workout(
                name: "Daniel",
                workoutType: .forTime,
                workoutDescription: "For time:\n50 Pull-ups\n400m Run\n21 Thrusters (95/65 lbs)\n800m Run\n21 Power Cleans (135/95 lbs)\n800m Run\n21 Handstand Push-ups\n400m Run\n50 Pull-ups",
                isHero: true,
                movements: [pullUp, run, thruster, powerClean, hspu]
            ),
            Workout(
                name: "Ralph",
                workoutType: .forTime,
                workoutDescription: "5 rounds for time:\n400m Run\n20 Thrusters (45/35 lbs)\n20 Pull-ups",
                isHero: true,
                movements: [run, thruster, pullUp]
            ),
            Workout(
                name: "Tillman",
                workoutType: .rft,
                workoutDescription: "7 rounds for time:\n7 Front Squats (185/130 lbs)\n7 Burpee Pull-ups\n200m Sprint\n(Rest 1 min between rounds)",
                isHero: true,
                movements: [frontSquat, burpeePullUp, run]
            ),
            Workout(
                name: "McGhee",
                workoutType: .rft,
                workoutDescription: "30 minute AMRAP:\n5 Burpees\n5 Power Cleans (135/95 lbs)",
                timeCap: 1800,
                isHero: true,
                movements: [burpee, powerClean]
            ),
            Workout(
                name: "Holbrook",
                workoutType: .forTime,
                workoutDescription: "For time:\n50 Burpees\n400m Run\n50 Burpees",
                isHero: true,
                movements: [burpee, run]
            ),
            Workout(
                name: "Bradley",
                workoutType: .rft,
                workoutDescription: "10 rounds for time:\n100m Sprint\n10 Pull-ups\n10 Burpees",
                isHero: true,
                movements: [run, pullUp, burpee]
            ),
            Workout(
                name: "Jerry",
                workoutType: .forTime,
                workoutDescription: "For time:\n1 mile Run\n2000m Row\n1 mile Run",
                isHero: true,
                movements: [run, row]
            ),
            Workout(
                name: "Roy",
                workoutType: .rft,
                workoutDescription: "5 rounds for time:\n15 Deadlifts (225/155 lbs)\n20 Box Jumps (24/20 in)\n25 Pull-ups",
                isHero: true,
                movements: [deadlift, boxJump, pullUp]
            ),
            Workout(
                name: "Wittman",
                workoutType: .rft,
                workoutDescription: "7 rounds for time:\n15 Pull-ups\n20 Kettlebell Swings (53/35 lbs)\n30 Double-Unders",
                isHero: true,
                movements: [pullUp, kbSwingAmerican, doubleUnder]
            ),
            Workout(
                name: "Donny",
                workoutType: .rft,
                workoutDescription: "4 rounds for time:\n400m Run\n20 Pull-ups\n20 Handstand Push-ups\n20 Toes-to-Bar",
                isHero: true,
                movements: [run, pullUp, hspu, toeToBar]
            ),
            Workout(
                name: "Del",
                workoutType: .rft,
                workoutDescription: "7 rounds for time:\n7 Muscle-ups\n7 Deadlifts (250/185 lbs)",
                isHero: true,
                movements: [ringMuscleUp, deadlift]
            ),
            Workout(
                name: "Omar",
                workoutType: .rft,
                workoutDescription: "6 rounds for time:\n10 Snatches (135/95 lbs)\n12 Box Jumps (36/30 in)\n6 Bar Muscle-ups",
                isHero: true,
                movements: [snatch, boxJump, barMuscleUp]
            ),
            Workout(
                name: "Rankel",
                workoutType: .amrap,
                workoutDescription: "20 minute AMRAP:\n6 Deadlifts (225/155 lbs)\n7 Burpee Pull-ups\n10 Kettlebell Swings (70/53 lbs)",
                timeCap: 1200,
                isHero: true,
                movements: [deadlift, burpeePullUp, kbSwingAmerican]
            ),
            Workout(
                name: "Jack",
                workoutType: .amrap,
                workoutDescription: "20 minute AMRAP:\n10 Push Press (115/85 lbs)\n10 Kettlebell Swings (53/35 lbs)\n10 Box Jumps (24/20 in)",
                timeCap: 1200,
                isHero: true,
                movements: [pushPress, kbSwingAmerican, boxJump]
            ),
            Workout(
                name: "G.I. Jane",
                workoutType: .forTime,
                workoutDescription: "100 Burpee Pull-ups for time",
                isHero: true,
                movements: [burpeePullUp]
            ),
            Workout(
                name: "Always Remembered",
                workoutType: .rft,
                workoutDescription: "8 rounds for time:\n11 Thrusters (95/65 lbs)\n11 Box Jumps (30/24 in)\n11 Power Cleans (95/65 lbs)",
                isHero: true,
                movements: [thruster, boxJump, powerClean]
            ),
        ]
        heroes.forEach { context.insert($0) }

        // MARK: - Other Named / Community Workouts

        let named: [Workout] = [
            Workout(
                name: "Bergeron Beep Test",
                workoutType: .emom,
                workoutDescription: "Every minute on the minute:\n7 Thrusters (75/55 lbs)\n7 Pull-ups\n7 Burpees\nContinue until failure.",
                isBenchmark: true,
                movements: [thruster, pullUp, burpee]
            ),
            Workout(
                name: "The Ghost",
                workoutType: .intervals,
                workoutDescription: "6 rounds:\n1 minute Assault Bike\n1 minute Rest\n1 minute Row\n1 minute Rest\n1 minute Run\n1 minute Rest\nScore = total calories/meters",
                isBenchmark: true,
                movements: [assaultBike, row, run]
            ),
            Workout(
                name: "Loredo",
                workoutType: .rft,
                workoutDescription: "6 rounds for time:\n24 Air Squats\n24 Push-ups\n24 Walking Lunges\n400m Run",
                isBenchmark: true,
                movements: [airSquat, pushUp, run]
            ),
            Workout(
                name: "Rahoi",
                workoutType: .amrap,
                workoutDescription: "12 minute AMRAP:\n12 Box Jumps (24/20 in)\n6 Thrusters (95/65 lbs)\n6 Bar-Facing Burpees",
                timeCap: 720,
                isBenchmark: true,
                movements: [boxJump, thruster, barFacingBurpee]
            ),
            Workout(
                name: "Cement Mixer",
                workoutType: .rft,
                workoutDescription: "3 rounds for time:\n21 Overhead Squats (95/65 lbs)\n21 Pull-ups\n200m Farmers Carry (53/35 lbs each)",
                isBenchmark: true,
                movements: [ohs, pullUp, kbFarmerCarry]
            ),
            Workout(
                name: "Ingrid",
                workoutType: .forTime,
                workoutDescription: "For time:\n30 Snatches (135/95 lbs)\n30 Clean & Jerks (135/95 lbs)",
                isBenchmark: true,
                movements: [snatch, cleanAndJerk]
            ),
        ]
        named.forEach { context.insert($0) }

        try? context.save()
    }
}
