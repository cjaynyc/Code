import SwiftUI

/// Visualizes the blended mood profile as a radar chart and gradient orb.
struct MoodProfileView: View {
    let moodProfile: MoodProfile
    @Binding var path: [ContentView.Screen]

    var body: some View {
        ZStack {
            GradientBackground(mood: moodProfile)

            ScrollView {
                VStack(spacing: 32) {
                    Text("Your Language's DNA")
                        .font(.title2.weight(.light))
                        .foregroundStyle(.white)

                    MoodRadarChart(mood: moodProfile)
                        .frame(width: 280, height: 280)
                        .padding()

                    dimensionCards

                    Button {
                        path.append(.tuningStudio)
                    } label: {
                        Text("Tune Your Language")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle("Mood Profile")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var dimensionCards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
            dimensionCard("Warmth", value: moodProfile.warmth, low: "Cold", high: "Warm")
            dimensionCard("Harshness", value: moodProfile.harshness, low: "Soft", high: "Harsh")
            dimensionCard("Energy", value: moodProfile.energy, low: "Serene", high: "Chaotic")
            dimensionCard("Age", value: moodProfile.age, low: "Ancient", high: "Futuristic")
            dimensionCard("Organic", value: moodProfile.organic, low: "Mechanical", high: "Organic")
            dimensionCard("Complexity", value: moodProfile.complexity, low: "Minimal", high: "Ornate")
            dimensionCard("Intimacy", value: moodProfile.intimacy, low: "Formal", high: "Intimate")
            dimensionCard("Darkness", value: moodProfile.darkness, low: "Light", high: "Dark")
        }
    }

    private func dimensionCard(_ label: String, value: Double, low: String, high: String) -> some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.1))
                        Capsule()
                            .fill(.white.opacity(0.4))
                            .frame(width: max(4, geo.size.width * CGFloat((value + 1) / 2)))
                    }
                }
                .frame(height: 6)

                HStack {
                    Text(low).font(.system(size: 9))
                    Spacer()
                    Text(high).font(.system(size: 9))
                }
                .foregroundStyle(.white.opacity(0.4))
            }
        }
    }
}

/// Radar/spider chart showing 8 mood dimensions.
struct MoodRadarChart: View {
    let mood: MoodProfile

    private var values: [Double] {
        [mood.warmth, mood.harshness, mood.energy, mood.age,
         mood.organic, mood.complexity, mood.intimacy, mood.darkness]
    }

    private let labels = ["Warmth", "Harshness", "Energy", "Age",
                          "Organic", "Complexity", "Intimacy", "Darkness"]

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2 - 30

            ZStack {
                // Grid rings
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                    polygonPath(sides: 8, center: center, radius: radius * scale)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                }

                // Axis lines
                ForEach(0..<8, id: \.self) { i in
                    let angle = angleFor(index: i)
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: pointAt(angle: angle, radius: radius, center: center))
                    }
                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
                }

                // Data polygon
                dataPath(center: center, radius: radius)
                    .fill(.white.opacity(0.15))
                dataPath(center: center, radius: radius)
                    .stroke(.white.opacity(0.6), lineWidth: 1.5)

                // Data points
                ForEach(0..<8, id: \.self) { i in
                    let normalized = (values[i] + 1) / 2
                    let angle = angleFor(index: i)
                    let point = pointAt(angle: angle, radius: radius * normalized, center: center)
                    Circle()
                        .fill(.white)
                        .frame(width: 6, height: 6)
                        .position(point)
                }

                // Labels
                ForEach(0..<8, id: \.self) { i in
                    let angle = angleFor(index: i)
                    let labelPoint = pointAt(angle: angle, radius: radius + 20, center: center)
                    Text(labels[i])
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .position(labelPoint)
                }
            }
        }
    }

    private func angleFor(index: Int) -> Double {
        let slice = (2 * Double.pi) / 8
        return slice * Double(index) - Double.pi / 2
    }

    private func pointAt(angle: Double, radius: Double, center: CGPoint) -> CGPoint {
        CGPoint(
            x: center.x + CGFloat(cos(angle) * radius),
            y: center.y + CGFloat(sin(angle) * radius)
        )
    }

    private func dataPath(center: CGPoint, radius: Double) -> Path {
        Path { path in
            for i in 0..<8 {
                let normalized = (values[i] + 1) / 2
                let angle = angleFor(index: i)
                let point = pointAt(angle: angle, radius: radius * normalized, center: center)
                if i == 0 { path.move(to: point) }
                else { path.addLine(to: point) }
            }
            path.closeSubpath()
        }
    }

    private func polygonPath(sides: Int, center: CGPoint, radius: Double) -> Path {
        Path { path in
            for i in 0..<sides {
                let angle = angleFor(index: i)
                let point = pointAt(angle: angle, radius: radius, center: center)
                if i == 0 { path.move(to: point) }
                else { path.addLine(to: point) }
            }
            path.closeSubpath()
        }
    }
}
