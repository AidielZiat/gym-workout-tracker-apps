import Foundation

struct ExerciseData {
    static let exercisesByGroup: [String: [String]] = [
        "Back": [
            "Lat Pulldown",
            "Single Arm Seated Row",
            "Longpull",
            "Crossbody Cable Pull"
        ],
        "Chest": [
            "Mid Chest Cable Pull",
            "Upper Chest Cable Pull",
            "Lower Chest Cable Pull",
            "Pec Fly"
        ],
        "Shoulder": [
            "Cable Lateral Raise",
            "Dumbbell Lateral Raise",
            "Cable Front Raise",
            "Rear Delt Fly"
        ],
        "Arms": [
            "Preacher Curl",
            "Hammer Curl",
            "Both Hands Tricep Ext.",
            "Single Hand Tricep Ext."
        ],
        "Legs": [
            "Leg Press",
            "Leg Curl",
            "Leg Extension",
            "Outer Thigh",
            "Inner Thigh"
        ],
        "Abs": [
            "Cable Crunch",
            "Rotary Torso",
            "Knee Up",
            "Inclined Sit Ups"
        ]
    ]

    // Helper to get a sorted list of group names
    static var groupNames: [String] {
        return exercisesByGroup.keys.sorted()
    }
}
