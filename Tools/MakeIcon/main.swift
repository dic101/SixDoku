import AppKit // for NSBezierPath geometry only (no screen drawing)
import CoreGraphics
import CoreText
import ImageIO

// Generates the SixDoku 1024 app icon: opaque indigo square, white 6x6 grid
// (2x3 boxes), coral accent cell with "5". Exact 1024x1024, no alpha.
// Usage: makeicon <output.png>
guard CommandLine.arguments.count == 2 else { fatalError("usage: makeicon <output.png>") }
let outPath = CommandLine.arguments[1]
let W = 1024
let S = CGFloat(W)

guard let ctx = CGContext(
    data: nil, width: W, height: W, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else { fatalError("no ctx") }

// Background: full-bleed opaque (marketing icon must have no transparency)
ctx.setFillColor(CGColor(srgbRed: 0.20, green: 0.32, blue: 0.96, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: S, height: S))

// Grid geometry (6x6, 2x3 boxes)
let margin: CGFloat = 148
let gridSize = S - margin * 2
let cell = gridSize / 6

// Grid lines (white, round caps)
ctx.setStrokeColor(CGColor(gray: 1.0, alpha: 0.92))
ctx.setLineCap(.round)
for i in 0...6 {
    // Horizontal: thick every 2 rows (box boundary)
    ctx.setLineWidth(i % 2 == 0 ? 22 : 6)
    let y = margin + CGFloat(i) * cell
    ctx.move(to: CGPoint(x: margin, y: y))
    ctx.addLine(to: CGPoint(x: margin + gridSize, y: y))
    ctx.strokePath()
    // Vertical: thick every 3 cols (box boundary)
    ctx.setLineWidth(i % 3 == 0 ? 22 : 6)
    let x = margin + CGFloat(i) * cell
    ctx.move(to: CGPoint(x: x, y: margin))
    ctx.addLine(to: CGPoint(x: x, y: margin + gridSize))
    ctx.strokePath()
}

// Accent cell OVER grid lines (col 3, row 3 zero-based from bottom)
let accentRect = CGRect(x: margin + 3 * cell + 8, y: margin + 3 * cell + 8, width: cell - 16, height: cell - 16)
let accentPath = NSBezierPath(roundedRect: NSRectFromCGRect(accentRect), xRadius: 28, yRadius: 28).cgPath
ctx.setFillColor(CGColor(srgbRed: 1.0, green: 0.42, blue: 0.42, alpha: 1))
ctx.addPath(accentPath)
ctx.fillPath()

// "5" centered in accent cell
let font = CTFontCreateWithName("Helvetica-Bold" as CFString, cell * 0.55, nil)
let attr = NSAttributedString(string: "5", attributes: [
    kCTFontAttributeName as NSAttributedString.Key: font,
    kCTForegroundColorAttributeName as NSAttributedString.Key: CGColor.white
])
let line = CTLineCreateWithAttributedString(attr)
let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
ctx.textPosition = CGPoint(
    x: accentRect.minX + (accentRect.width - bounds.width) / 2 - bounds.minX,
    y: accentRect.minY + (accentRect.height - bounds.height) / 2 - bounds.minY
)
CTLineDraw(line, ctx)

guard let image = ctx.makeImage() else { fatalError("no image") }
guard let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outPath) as CFURL, "public.png" as CFString, 1, nil) else {
    fatalError("no dest")
}
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("write failed") }
print("Wrote \(outPath)")
