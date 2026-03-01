import SwiftUI

/// Dynamic gradient background that shifts based on the language's mood profile.
struct GradientBackground: View {
    var colors: [Color]
    var animated: Bool

    @State private var animationOffset: CGFloat = 0

    init(colors: [Color]? = nil, animated: Bool = true) {
        self.colors = colors ?? [
            Color(red: 0.08, green: 0.05, blue: 0.15),
            Color(red: 0.12, green: 0.07, blue: 0.25),
            Color(red: 0.05, green: 0.03, blue: 0.12)
        ]
        self.animated = animated
    }

    /// Create a background from a mood profile's characteristics.
    init(mood: MoodProfile) {
        let warmthColor = mood.warmth > 0
            ? Color(red: 0.2 + mood.warmth * 0.3, green: 0.08, blue: 0.05)
            : Color(red: 0.05, green: 0.08, blue: 0.15 + abs(mood.warmth) * 0.2)

        let energyColor = mood.energy > 0
            ? Color(red: 0.15, green: 0.05, blue: 0.2 + mood.energy * 0.15)
            : Color(red: 0.05, green: 0.1 + abs(mood.energy) * 0.1, blue: 0.1)

        let baseColor = mood.darkness > 0
            ? Color(red: 0.03, green: 0.02, blue: 0.06)
            : Color(red: 0.1, green: 0.08, blue: 0.15)

        self.colors = [warmthColor, energyColor, baseColor]
        self.animated = true
    }

    /// Create a background from hex color strings (e.g. from a flag spec).
    init(hexColors: [String]) {
        self.colors = hexColors.map { Color(hex: $0) }
        self.animated = true
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animated
                ? UnitPoint(x: 0 + animationOffset * 0.1, y: 0)
                : .topLeading,
            endPoint: animated
                ? UnitPoint(x: 1 - animationOffset * 0.1, y: 1)
                : .bottomTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            guard animated else { return }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animationOffset = 1
            }
        }
    }
}

// MARK: - Hex Color Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: Double
        switch hex.count {
        case 6:
            (r, g, b, a) = (
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8) & 0xFF) / 255,
                Double(int & 0xFF) / 255,
                1
            )
        case 8:
            (r, g, b, a) = (
                Double((int >> 24) & 0xFF) / 255,
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8) & 0xFF) / 255,
                Double(int & 0xFF) / 255
            )
        default:
            (r, g, b, a) = (0.5, 0.5, 0.5, 1)
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
