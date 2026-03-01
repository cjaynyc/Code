import SwiftUI

/// Renders a language sigil from a SigilSpec using Canvas.
struct SigilView: View {
    let sigil: SigilSpec
    var animated: Bool = false

    @State private var revealProgress: CGFloat = 0

    var body: some View {
        Group {
            // If custom image data exists, use it instead of procedural generation
            if let imageData = sigil.customImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(animated ? Double(revealProgress) : 1)
            } else {
                // Fall back to procedural generation
                Canvas { context, size in
                    let rect = CGRect(origin: .zero, size: size)
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = min(size.width, size.height) / 2 - 4
                    let color = Color(hex: sigil.primaryColor)

                    // Base shape
                    let basePath = shapePath(sigil.baseShape, center: center, radius: radius)
                    let strokeWidth = strokeWidthFor(sigil.strokeStyle)
                    context.stroke(
                        basePath,
                        with: .color(color.opacity(animated ? Double(revealProgress) : 1)),
                        style: strokeStyleFor(sigil.strokeStyle, width: strokeWidth)
                    )

                    // Internal detail layers
                    drawInternalDetails(
                        context: context, center: center, radius: radius,
                        complexity: sigil.internalComplexity, symmetry: sigil.symmetry,
                        color: color, rect: rect
                    )

                    // Render stored bezier paths if any
                    if !sigil.paths.isEmpty {
                        drawSigilPaths(context: context, size: size, color: color)
                    }
                }
            }
        }
        .onAppear {
            guard animated else {
                revealProgress = 1
                return
            }
            withAnimation(.easeOut(duration: 2.0)) {
                revealProgress = 1
            }
        }
    }

    // MARK: - Base Shape

    private func shapePath(_ shape: SigilBaseShape, center: CGPoint, radius: CGFloat) -> Path {
        switch shape {
        case .circle:
            return Path(ellipseIn: CGRect(
                x: center.x - radius, y: center.y - radius,
                width: radius * 2, height: radius * 2
            ))

        case .square:
            let side = radius * 1.6
            return Path(CGRect(
                x: center.x - side / 2, y: center.y - side / 2,
                width: side, height: side
            ))

        case .triangle:
            return polygon(sides: 3, center: center, radius: radius)

        case .hexagon:
            return polygon(sides: 6, center: center, radius: radius)

        case .diamond:
            var path = Path()
            path.move(to: CGPoint(x: center.x, y: center.y - radius))
            path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
            path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
            path.addLine(to: CGPoint(x: center.x - radius, y: center.y))
            path.closeSubpath()
            return path

        case .octagon:
            return polygon(sides: 8, center: center, radius: radius)
        }
    }

    private func polygon(sides: Int, center: CGPoint, radius: CGFloat) -> Path {
        Path { path in
            for i in 0..<sides {
                let angle = (2 * Double.pi / Double(sides)) * Double(i) - Double.pi / 2
                let pt = CGPoint(
                    x: center.x + CGFloat(cos(angle)) * radius,
                    y: center.y + CGFloat(sin(angle)) * radius
                )
                if i == 0 { path.move(to: pt) }
                else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        }
    }

    // MARK: - Internal Detail

    private func drawInternalDetails(
        context: GraphicsContext, center: CGPoint, radius: CGFloat,
        complexity: Int, symmetry: SymmetryType, color: Color, rect: CGRect
    ) {
        let progress = animated ? revealProgress : 1
        guard complexity > 0 else { return }

        // Layer 1: Inner shape (scaled down)
        if complexity >= 1 {
            let innerPath = shapePath(sigil.baseShape, center: center, radius: radius * 0.55)
            context.stroke(innerPath, with: .color(color.opacity(0.4 * Double(progress))), lineWidth: 1)
        }

        // Layer 2: Radial spokes
        if complexity >= 2 {
            let spokeCount: Int
            switch symmetry {
            case .bilateral: spokeCount = 2
            case .radial: spokeCount = 6
            case .asymmetric: spokeCount = 3
            }
            for i in 0..<spokeCount {
                let angle = (2 * Double.pi / Double(spokeCount)) * Double(i) - Double.pi / 2
                var spoke = Path()
                spoke.move(to: CGPoint(
                    x: center.x + CGFloat(cos(angle)) * radius * 0.2,
                    y: center.y + CGFloat(sin(angle)) * radius * 0.2
                ))
                spoke.addLine(to: CGPoint(
                    x: center.x + CGFloat(cos(angle)) * radius * 0.85,
                    y: center.y + CGFloat(sin(angle)) * radius * 0.85
                ))
                context.stroke(spoke, with: .color(color.opacity(0.35 * Double(progress))), lineWidth: 1.5)
            }
        }

        // Layer 3: Center dot/ring
        if complexity >= 3 {
            let dotRadius: CGFloat = radius * 0.08
            let dotRect = CGRect(
                x: center.x - dotRadius, y: center.y - dotRadius,
                width: dotRadius * 2, height: dotRadius * 2
            )
            context.fill(Path(ellipseIn: dotRect), with: .color(color.opacity(0.6 * Double(progress))))
        }

        // Layer 4: Decorative arcs
        if complexity >= 4 {
            let arcRadius = radius * 0.7
            for i in 0..<4 {
                let startAngle = Angle(degrees: Double(i) * 90 + 10)
                let endAngle = Angle(degrees: Double(i) * 90 + 70)
                var arc = Path()
                arc.addArc(center: center, radius: arcRadius,
                           startAngle: startAngle, endAngle: endAngle, clockwise: false)
                context.stroke(arc, with: .color(color.opacity(0.25 * Double(progress))), lineWidth: 1)
            }
        }

        // Layer 5: Outer dots
        if complexity >= 5 {
            let dotCount = 12
            for i in 0..<dotCount {
                let angle = (2 * Double.pi / Double(dotCount)) * Double(i)
                let dotCenter = CGPoint(
                    x: center.x + CGFloat(cos(angle)) * radius * 0.9,
                    y: center.y + CGFloat(sin(angle)) * radius * 0.9
                )
                let r: CGFloat = 2
                context.fill(
                    Path(ellipseIn: CGRect(x: dotCenter.x - r, y: dotCenter.y - r, width: r * 2, height: r * 2)),
                    with: .color(color.opacity(0.3 * Double(progress)))
                )
            }
        }
    }

    // MARK: - Stored Paths

    private func drawSigilPaths(context: GraphicsContext, size: CGSize, color: Color) {
        for sigilPath in sigil.paths {
            guard sigilPath.points.count >= 2 else { continue }

            var path = Path()
            let scale = min(size.width, size.height)

            let first = sigilPath.points[0]
            path.move(to: CGPoint(x: first.x * scale, y: first.y * scale))

            if let controls = sigilPath.controlPoints, controls.count >= (sigilPath.points.count - 1) {
                for i in 1..<sigilPath.points.count {
                    let pt = sigilPath.points[i]
                    let cp = controls[i - 1]
                    path.addQuadCurve(
                        to: CGPoint(x: pt.x * scale, y: pt.y * scale),
                        control: CGPoint(x: cp.x * scale, y: cp.y * scale)
                    )
                }
            } else {
                for i in 1..<sigilPath.points.count {
                    let pt = sigilPath.points[i]
                    path.addLine(to: CGPoint(x: pt.x * scale, y: pt.y * scale))
                }
            }

            if sigilPath.closed { path.closeSubpath() }

            let progress = animated ? revealProgress : 1
            context.stroke(
                path,
                with: .color(color.opacity(Double(progress))),
                lineWidth: sigilPath.strokeWidth
            )
        }
    }

    // MARK: - Stroke Style

    private func strokeWidthFor(_ style: SigilStrokeStyle) -> CGFloat {
        switch style {
        case .rough: return 2.5
        case .clean: return 2.0
        case .calligraphic: return 2.5
        case .angular: return 2.0
        case .organic: return 1.8
        }
    }

    private func strokeStyleFor(_ style: SigilStrokeStyle, width: CGFloat) -> StrokeStyle {
        switch style {
        case .rough:
            return StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
        case .clean:
            return StrokeStyle(lineWidth: width, lineCap: .butt, lineJoin: .miter)
        case .calligraphic:
            return StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
        case .angular:
            return StrokeStyle(lineWidth: width, lineCap: .square, lineJoin: .bevel)
        case .organic:
            return StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
        }
    }
}

/// Convenience view showing both flag and sigil side by side.
struct LanguageIdentityView: View {
    let identity: LanguageIdentity

    var body: some View {
        VStack(spacing: 24) {
            Text("Language Identity")
                .font(.title3.weight(.light))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    FlagView(flag: identity.flag, sigil: identity.sigil)
                        .aspectRatio(3 / 2, contentMode: .fit)
                        .frame(maxWidth: 240)
                    Text("Flag")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    if let desc = identity.flag.description {
                        Text(desc)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                    if identity.flag.customImageData != nil {
                        Label("Custom", systemImage: "photo.fill")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }

                VStack(spacing: 8) {
                    SigilView(sigil: identity.sigil, animated: true)
                        .frame(width: 120, height: 120)
                    Text("Sigil")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    if let desc = identity.sigil.description {
                        Text(desc)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                    if identity.sigil.customImageData != nil {
                        Label("Custom", systemImage: "photo.fill")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
        }
    }
}
