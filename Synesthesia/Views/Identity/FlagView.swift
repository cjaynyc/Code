import SwiftUI

/// Renders a programmatic flag from a FlagSpec using Canvas.
struct FlagView: View {
    let flag: FlagSpec
    let sigil: SigilSpec?

    init(flag: FlagSpec, sigil: SigilSpec? = nil) {
        self.flag = flag
        self.sigil = sigil
    }

    var body: some View {
        Canvas { context, size in
            drawDivision(context: context, size: size)
            if let overlay = flag.patternOverlay {
                drawPattern(overlay, context: context, size: size)
            }
            if let border = flag.borderStyle, border != .none {
                drawBorder(border, context: context, size: size)
            }
            if let sigil = sigil {
                drawCharge(sigil, context: context, size: size)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Division Drawing

    private func drawDivision(context: GraphicsContext, size: CGSize) {
        let colors = flag.colors.map { Color(hex: $0) }
        guard !colors.isEmpty else { return }

        switch flag.division {
        case .bicolorHorizontal:
            drawHorizontalBands(colors: Array(colors.prefix(2)), context: context, size: size)

        case .bicolorVertical:
            drawVerticalBands(colors: Array(colors.prefix(2)), context: context, size: size)

        case .bicolorDiagonal:
            drawDiagonalSplit(colors: Array(colors.prefix(2)), context: context, size: size)

        case .tricolorHorizontal:
            drawHorizontalBands(colors: Array(colors.prefix(3)), context: context, size: size)

        case .tricolorVertical:
            drawVerticalBands(colors: Array(colors.prefix(3)), context: context, size: size)

        case .chevron:
            drawChevron(colors: Array(colors.prefix(3)), context: context, size: size)

        case .saltire:
            drawSaltire(colors: Array(colors.prefix(2)), context: context, size: size)

        case .quartered:
            drawQuartered(colors: Array(colors.prefix(4)), context: context, size: size)

        case .radial:
            drawRadial(colors: colors, context: context, size: size)
        }
    }

    private func drawHorizontalBands(colors: [Color], context: GraphicsContext, size: CGSize) {
        let bandHeight = size.height / CGFloat(max(colors.count, 1))
        for (i, color) in colors.enumerated() {
            let rect = CGRect(x: 0, y: bandHeight * CGFloat(i), width: size.width, height: bandHeight)
            context.fill(Path(rect), with: .color(color))
        }
    }

    private func drawVerticalBands(colors: [Color], context: GraphicsContext, size: CGSize) {
        let bandWidth = size.width / CGFloat(max(colors.count, 1))
        for (i, color) in colors.enumerated() {
            let rect = CGRect(x: bandWidth * CGFloat(i), y: 0, width: bandWidth, height: size.height)
            context.fill(Path(rect), with: .color(color))
        }
    }

    private func drawDiagonalSplit(colors: [Color], context: GraphicsContext, size: CGSize) {
        let c1 = colors.first ?? .gray
        let c2 = colors.count > 1 ? colors[1] : .gray

        // Full background
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(c2))

        // Top-left triangle
        var tri = Path()
        tri.move(to: .zero)
        tri.addLine(to: CGPoint(x: size.width, y: 0))
        tri.addLine(to: CGPoint(x: 0, y: size.height))
        tri.closeSubpath()
        context.fill(tri, with: .color(c1))
    }

    private func drawChevron(colors: [Color], context: GraphicsContext, size: CGSize) {
        let bg = colors.first ?? .gray
        let fg = colors.count > 1 ? colors[1] : .white

        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(bg))

        var chevron = Path()
        chevron.move(to: CGPoint(x: 0, y: 0))
        chevron.addLine(to: CGPoint(x: size.width * 0.4, y: size.height / 2))
        chevron.addLine(to: CGPoint(x: 0, y: size.height))
        chevron.closeSubpath()
        context.fill(chevron, with: .color(fg))
    }

    private func drawSaltire(colors: [Color], context: GraphicsContext, size: CGSize) {
        let bg = colors.first ?? .gray
        let cross = colors.count > 1 ? colors[1] : .white

        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(bg))

        let w = size.width * 0.08
        var path = Path()
        // Top-left to bottom-right
        path.move(to: CGPoint(x: -w, y: -w))
        path.addLine(to: CGPoint(x: w, y: -w))
        path.addLine(to: CGPoint(x: size.width + w, y: size.height - w))
        path.addLine(to: CGPoint(x: size.width + w, y: size.height + w))
        path.addLine(to: CGPoint(x: size.width - w, y: size.height + w))
        path.addLine(to: CGPoint(x: -w, y: w))
        path.closeSubpath()
        // Top-right to bottom-left
        path.move(to: CGPoint(x: size.width + w, y: -w))
        path.addLine(to: CGPoint(x: size.width + w, y: w))
        path.addLine(to: CGPoint(x: w, y: size.height + w))
        path.addLine(to: CGPoint(x: -w, y: size.height + w))
        path.addLine(to: CGPoint(x: -w, y: size.height - w))
        path.addLine(to: CGPoint(x: size.width - w, y: -w))
        path.closeSubpath()
        context.fill(path, with: .color(cross))
    }

    private func drawQuartered(colors: [Color], context: GraphicsContext, size: CGSize) {
        let padded = colors + Array(repeating: Color.gray, count: max(0, 4 - colors.count))
        let hw = size.width / 2
        let hh = size.height / 2
        let rects = [
            CGRect(x: 0, y: 0, width: hw, height: hh),
            CGRect(x: hw, y: 0, width: hw, height: hh),
            CGRect(x: 0, y: hh, width: hw, height: hh),
            CGRect(x: hw, y: hh, width: hw, height: hh),
        ]
        for (i, rect) in rects.enumerated() {
            context.fill(Path(rect), with: .color(padded[i]))
        }
    }

    private func drawRadial(colors: [Color], context: GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let segments = max(colors.count, 4)
        let angleStep = (2 * Double.pi) / Double(segments)
        let radius = max(size.width, size.height)

        for i in 0..<segments {
            let color = colors[i % colors.count]
            let startAngle = angleStep * Double(i)
            let endAngle = startAngle + angleStep

            var path = Path()
            path.move(to: center)
            path.addLine(to: CGPoint(
                x: center.x + CGFloat(cos(startAngle)) * radius,
                y: center.y + CGFloat(sin(startAngle)) * radius
            ))
            path.addLine(to: CGPoint(
                x: center.x + CGFloat(cos(endAngle)) * radius,
                y: center.y + CGFloat(sin(endAngle)) * radius
            ))
            path.closeSubpath()
            context.fill(path, with: .color(color))
        }
    }

    // MARK: - Pattern Overlay

    private func drawPattern(_ pattern: String, context: GraphicsContext, size: CGSize) {
        let patternColor = Color.white.opacity(0.08)
        switch pattern.lowercased() {
        case "wave":
            for y in stride(from: 0.0, through: size.height, by: 20) {
                var wave = Path()
                wave.move(to: CGPoint(x: 0, y: y))
                for x in stride(from: 0.0, through: size.width, by: 40) {
                    wave.addQuadCurve(
                        to: CGPoint(x: x + 20, y: y),
                        control: CGPoint(x: x + 10, y: y - 8)
                    )
                    wave.addQuadCurve(
                        to: CGPoint(x: x + 40, y: y),
                        control: CGPoint(x: x + 30, y: y + 8)
                    )
                }
                context.stroke(wave, with: .color(patternColor), lineWidth: 1)
            }
        case "grid":
            for x in stride(from: 0.0, through: size.width, by: 20) {
                var line = Path()
                line.move(to: CGPoint(x: x, y: 0))
                line.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(line, with: .color(patternColor), lineWidth: 0.5)
            }
            for y in stride(from: 0.0, through: size.height, by: 20) {
                var line = Path()
                line.move(to: CGPoint(x: 0, y: y))
                line.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(line, with: .color(patternColor), lineWidth: 0.5)
            }
        case "dots":
            for x in stride(from: 10.0, through: size.width, by: 20) {
                for y in stride(from: 10.0, through: size.height, by: 20) {
                    let dot = Path(ellipseIn: CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3))
                    context.fill(dot, with: .color(patternColor))
                }
            }
        default:
            break
        }
    }

    // MARK: - Border

    private func drawBorder(_ style: BorderStyle, context: GraphicsContext, size: CGSize) {
        let borderColor = Color.white.opacity(0.3)
        let rect = CGRect(origin: .zero, size: size)
        switch style {
        case .thin:
            context.stroke(Path(rect), with: .color(borderColor), lineWidth: 2)
        case .thick:
            context.stroke(Path(rect), with: .color(borderColor), lineWidth: 6)
        case .double:
            context.stroke(Path(rect), with: .color(borderColor), lineWidth: 4)
            let inset = CGRect(x: 6, y: 6, width: size.width - 12, height: size.height - 12)
            context.stroke(Path(inset), with: .color(borderColor), lineWidth: 2)
        case .fimbriated:
            context.stroke(Path(rect), with: .color(.black.opacity(0.4)), lineWidth: 8)
            context.stroke(Path(rect), with: .color(borderColor), lineWidth: 3)
        case .none:
            break
        }
    }

    // MARK: - Charge (Sigil in center)

    private func drawCharge(_ sigil: SigilSpec, context: GraphicsContext, size: CGSize) {
        let chargeSize = min(size.width, size.height) * 0.35
        let origin: CGPoint
        switch flag.chargePosition {
        case .center:
            origin = CGPoint(x: (size.width - chargeSize) / 2, y: (size.height - chargeSize) / 2)
        case .canton:
            origin = CGPoint(x: size.width * 0.08, y: size.height * 0.08)
        case .offset:
            origin = CGPoint(x: size.width * 0.6, y: (size.height - chargeSize) / 2)
        }

        let chargeRect = CGRect(origin: origin, size: CGSize(width: chargeSize, height: chargeSize))
        let color = Color(hex: sigil.primaryColor)

        // Draw the base shape
        let shapePath = sigilBasePath(shape: sigil.baseShape, in: chargeRect)
        context.stroke(shapePath, with: .color(color), lineWidth: 2)

        // Draw internal complexity lines
        let center = CGPoint(x: chargeRect.midX, y: chargeRect.midY)
        let innerRadius = chargeSize * 0.3
        for i in 0..<sigil.internalComplexity {
            let angle = (2 * Double.pi / Double(max(sigil.internalComplexity, 1))) * Double(i)
            var line = Path()
            line.move(to: center)
            line.addLine(to: CGPoint(
                x: center.x + CGFloat(cos(angle)) * innerRadius,
                y: center.y + CGFloat(sin(angle)) * innerRadius
            ))
            context.stroke(line, with: .color(color.opacity(0.6)), lineWidth: 1.5)
        }
    }

    private func sigilBasePath(shape: SigilBaseShape, in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) / 2

        switch shape {
        case .circle:
            return Path(ellipseIn: rect)

        case .square:
            return Path(rect)

        case .triangle:
            var path = Path()
            path.move(to: CGPoint(x: cx, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path

        case .hexagon:
            return regularPolygon(sides: 6, center: CGPoint(x: cx, y: cy), radius: r)

        case .diamond:
            var path = Path()
            path.move(to: CGPoint(x: cx, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: cy))
            path.addLine(to: CGPoint(x: cx, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: cy))
            path.closeSubpath()
            return path

        case .octagon:
            return regularPolygon(sides: 8, center: CGPoint(x: cx, y: cy), radius: r)
        }
    }

    private func regularPolygon(sides: Int, center: CGPoint, radius: CGFloat) -> Path {
        Path { path in
            for i in 0..<sides {
                let angle = (2 * Double.pi / Double(sides)) * Double(i) - Double.pi / 2
                let point = CGPoint(
                    x: center.x + CGFloat(cos(angle)) * radius,
                    y: center.y + CGFloat(sin(angle)) * radius
                )
                if i == 0 { path.move(to: point) }
                else { path.addLine(to: point) }
            }
            path.closeSubpath()
        }
    }
}
