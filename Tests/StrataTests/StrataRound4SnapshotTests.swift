import DesignTokens
import ImageIO
import UniformTypeIdentifiers
import SwiftUI
import XCTest
@testable import Strata

@available(macOS 13, iOS 16, *)
final class StrataRound4SnapshotTests: XCTestCase {
    @MainActor
    func testTabularContractResolvesTokenMetricsAndErrors() throws {
        let metrics = try StrataTabularRowMetrics()
        XCTAssertEqual(metrics.checkboxHitTarget, 44)
        XCTAssertEqual(metrics.minimumRowHeight, 44)
        XCTAssertEqual(metrics.compactCellRadius, 6)

        let expected = StyleTokenError.unknownToken("metrics.failure")
        XCTAssertThrowsError(
            try StrataTabularRowMetrics(dimension: { _ in throw expected })
        ) { error in
            XCTAssertEqual(error as? StyleTokenError, expected)
        }
    }

    @MainActor
    func testHeaderAndInactiveSlotGeometryStayWithinDenseContracts() throws {
        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        for isLargeMode in [false, true] {
            let sectionHeader = StrataSectionHeader(
                theme: theme,
                title: "弹力带俯身髋部伸展",
                subtitle: nil,
                badgeText: "3组"
            ) {
                Button("More", systemImage: "ellipsis") {}
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
            }
            let stickyHeader = try StrataStickySectionHeader(
                theme: theme,
                index: 1,
                completedCount: 1,
                totalCount: 3,
                title: "弹力带俯身髋部伸展",
                isLargeMode: isLargeMode
            ) {
                Button("Add", systemImage: "plus") {}
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
            }

            XCTAssertLessThanOrEqual(try renderedImage(sectionHeader.frame(width: 390)).height, 88)
            XCTAssertLessThanOrEqual(try renderedImage(stickyHeader.frame(width: 390)).height, 88)
        }

        // A nonempty sibling lets ImageRenderer measure the omitted slot, which
        // has no image of its own. No hosting or platform view is needed.
        for active in [false, true] {
            let image = try renderedImage(
                VStack(spacing: 0) {
                    theme.surface.frame(width: 390, height: 10)
                    StrataBottomSlot(isActive: active) {
                        Text("Active snackbar content").frame(width: 390, height: 44)
                    }
                }
            )
            XCTAssertEqual(image.width / 2, 390)
            XCTAssertEqual(image.height / 2, active ? 54 : 10)
        }
    }

    @MainActor
    func testSubRowMotionAndTransitionsCoverReduceMotionModes() {
        let normalAnimation = StrataMotion.subRowAnimation(reduceMotion: false)
        let reduceAnimation = StrataMotion.subRowAnimation(reduceMotion: true)
        XCTAssertNotNil(normalAnimation as Animation?)
        XCTAssertNotNil(reduceAnimation as Animation?)

        let normalTransition = StrataMotion.subRowTransition(reduceMotion: false)
        let reduceTransition = StrataMotion.subRowTransition(reduceMotion: true)
        XCTAssertNotNil(normalTransition)
        XCTAssertNotNil(reduceTransition)
    }

    @MainActor
    func testHighDensityTabularSnapshotsExportPNGForBothAppearancesAndRTL() throws {
        for mode in Theme.allCases {
            let theme = try StrataTheme(theme: mode, brand: "strata-blue")
            for (name, direction) in [("normal", LayoutDirection.leftToRight), ("rtl", .rightToLeft)] {
                var images: [CGImage] = []
                for (suffix, large, active) in [("", false, false), ("-large", true, false), ("-active", true, true)] {
                    let image = try renderSnapshot(
                        HighDensityComposite(theme: theme, isLargeMode: large, isSnackbarActive: active)
                            .environment(\.layoutDirection, direction)
                            .frame(width: 390),
                        named: "round-4-\(mode.rawValue)-\(name)\(suffix)"
                    )
                    XCTAssertEqual(image.width, 780)
                    try assertInputColumns(image, theme: theme, large: large, direction: direction)
                    images.append(image)
                }
                XCTAssertEqual(images[2].height - images[1].height, 88, "Only the 44pt snackbar adds height at 2x")
            }
        }
    }

    @MainActor
    private func renderedImage<V: View>(_ view: V) throws -> CGImage {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        return try XCTUnwrap(renderer.cgImage, "ImageRenderer must produce pixels")
    }

    @MainActor
    private func renderSnapshot<V: View>(_ view: V, named: String) throws -> CGImage {
        let image = try renderedImage(view)
        let data = NSMutableData()
        let destination = try XCTUnwrap(
            CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)
        )
        CGImageDestinationAddImage(destination, image, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        XCTAssertEqual(Array((data as Data).prefix(8)), [137, 80, 78, 71, 13, 10, 26, 10])
        let directory = snapshotDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try (data as Data).write(to: directory.appendingPathComponent("\(named).png"))
        return image
    }

    @MainActor
    private func assertInputColumns(
        _ image: CGImage, theme: StrataTheme, large: Bool, direction: LayoutDirection
    ) throws {
        let pixels = try SnapshotPixels(image)
        let reference = try SnapshotPixels(renderedImage(theme.surface(.inset).frame(width: 1, height: 1)))
        let fill = reference.rgb(x: 0, y: 0)
        let rowHeight = large ? 52 : 48
        var parentColumns: [Range<Int>] = []
        for row in 0..<3 {
            let centerY = (88 + row * rowHeight + rowHeight / 2) * 2
            // Above the text and below rounded corners: the full cell width is visible.
            let columns = pixels.runs(matching: fill, y: centerY - 24)
                .filter { (120...140).contains($0.count) }
            XCTAssertEqual(columns.count, 2, "Two rendered input surfaces in row \(row)")
            XCTAssertEqual(columns.map(\.count), direction == .leftToRight ? [132, 128] : [128, 132])
            if row == 0 { parentColumns = columns }
            else { XCTAssertEqual(columns, parentColumns, "Parent/child input widths and x positions must match") }
            for column in columns {
                var ink = 0
                var yellow = 0
                for y in (centerY - 16)..<(centerY + 16) {
                    for x in (column.lowerBound + 8)..<(column.upperBound - 8) {
                        let rgb = pixels.rgb(x: x, y: y)
                        if rgb != fill { ink += 1 }
                        if rgb[0] > 180 && rgb[1] > 150 && rgb[2] < 120 { yellow += 1 }
                    }
                }
                XCTAssertGreaterThan(ink, 20, "Every value/inline hint must leave readable text pixels")
                XCTAssertEqual(yellow, 0, "Input cells must not render unsupported-control yellow markers")
            }
        }
        // The dock surface reaches both bottom corners with no detached strip.
        let surface = try SnapshotPixels(renderedImage(theme.surface.frame(width: 1, height: 1)))
        XCTAssertEqual(pixels.rgb(x: 0, y: image.height - 1), surface.rgb(x: 0, y: 0))
        XCTAssertEqual(pixels.rgb(x: image.width - 1, y: image.height - 1), surface.rgb(x: 0, y: 0))
    }

    private func snapshotDirectory() -> URL {
        if let path = ProcessInfo.processInfo.environment["STRATA_SNAPSHOT_DIR"], !path.isEmpty {
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        return FileManager.default.temporaryDirectory.appendingPathComponent("strata-snapshots/round-4")
    }

}

/// Canonical sRGB RGBA bytes, independent of ImageRenderer's native pixel format.
private struct SnapshotPixels {
    let width: Int
    let bytes: [UInt8]

    init(_ image: CGImage) throws {
        width = image.width
        var storage = [UInt8](repeating: 0, count: image.width * image.height * 4)
        try storage.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(
                data: buffer.baseAddress, width: image.width, height: image.height,
                bitsPerComponent: 8, bytesPerRow: image.width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        }
        bytes = storage
    }

    func rgb(x: Int, y: Int) -> [UInt8] {
        let offset = (y * width + x) * 4
        return Array(bytes[offset..<(offset + 3)])
    }

    func runs(matching color: [UInt8], y: Int) -> [Range<Int>] {
        var ranges: [Range<Int>] = []
        var start: Int?
        for x in 0...width {
            let matches = x < width && rgb(x: x, y: y) == color
            if matches, start == nil { start = x }
            if !matches, let lower = start {
                ranges.append(lower..<x)
                start = nil
            }
        }
        return ranges
    }
}

@available(macOS 13, iOS 16, *)
private struct HighDensityComposite: View {
    let theme: StrataTheme
    let isLargeMode: Bool
    let isSnackbarActive: Bool
    @State private var showsSubRows = true

    var body: some View {
        VStack(spacing: 0) {
            sectionHeader
            stickyHeader
            HStack(alignment: .top, spacing: 0) {
                sidebar
                VStack(spacing: 0) {
                    tabularRow(index: "1", weight: "", reps: "", isChild: false)
                        .transition(StrataMotion.subRowTransition(reduceMotion: false))
                    if showsSubRows {
                        tabularRow(index: "↳1", weight: "85", reps: "8", isChild: true)
                            .transition(StrataMotion.subRowTransition(reduceMotion: false))
                        tabularRow(index: "↳2", weight: "72", reps: "10", isChild: true)
                            .transition(StrataMotion.subRowTransition(reduceMotion: false))
                    }
                    Text("+ 递减组")
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                        .padding(.horizontal, 12)
                        .foregroundStyle(theme.accent)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(StrataMotion.subRowAnimation(reduceMotion: false)) {
                                showsSubRows.toggle()
                            }
                        }
                }
                .frame(maxWidth: .infinity)
                .animation(
                    StrataMotion.subRowAnimation(reduceMotion: false),
                    value: showsSubRows
                )
            }
            StrataDockedBar(theme: theme, style: .solid) {
                Text("+ 添加动作")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.accent)
                    .frame(maxWidth: .infinity, minHeight: isLargeMode ? 48 : 44)
                    .background(theme.surface(.card), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            StrataBottomSlot(isActive: isSnackbarActive) {
                Text("组间休息 01:30")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                    .background(theme.surface(.card))
                    .transition(StrataMotion.subRowTransition(reduceMotion: false))
            }
            keyboardDock
        }
        .background(theme.surface)
        .foregroundStyle(theme.foreground)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
        .environment(\.dynamicTypeSize, isLargeMode ? .xxxLarge : .medium)
    }

    private var sectionHeader: some View {
        StrataSectionHeader(
            theme: theme,
            title: "弹力带俯身髋部伸展",
            subtitle: nil,
            badgeText: "3组"
        ) {
            Button("More", systemImage: "ellipsis") {}
                .labelStyle(.iconOnly)
                .frame(width: 44, height: 44)
        }
    }

    private var stickyHeader: some View {
        try! StrataStickySectionHeader(
            theme: theme,
            index: 1,
            completedCount: 1,
            totalCount: 3,
            title: "弹力带俯身髋部伸展",
            isLargeMode: isLargeMode
        ) {
            Button("Add", systemImage: "plus") {}
                .labelStyle(.iconOnly)
                .frame(width: 44, height: 44)
        }
    }

    private var sidebar: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.accent)
                .frame(height: 44)
                .overlay(Text("1").foregroundStyle(theme.onAccent).font(.caption.weight(.bold)))
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.surface(.card))
                .frame(height: 44)
                .overlay(Text("2").foregroundStyle(theme.foreground).font(.caption.weight(.bold)))
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.surface(.card))
                .frame(height: 44)
                .overlay(Text("+").foregroundStyle(theme.foreground).font(.title3.weight(.semibold)))
        }
        .frame(width: 64)
        .padding(.vertical, 6)
        .background(theme.surface(.card))
    }

    // A single explicit grid is shared by all three rows. Including the 64pt
    // rail, spacing and padding, it fits the 390pt compact viewport exactly.
    private func tabularRow(index: String, weight: String, reps: String, isChild: Bool) -> some View {
        HStack(alignment: .center, spacing: 2) {
            Text(index).font(.system(size: 11, weight: .semibold)).frame(width: 24)
            Group {
                if isChild { Text("85%").font(.system(size: 10, weight: .semibold)) }
                else { Image(systemName: "checkmark.circle.fill").foregroundStyle(theme.accent) }
            }
            .frame(width: 44, height: 44)
            inputCell(title: "重量", value: weight.isEmpty ? "" : "\(weight)lb", hint: "建议 0lb")
                .frame(width: 66)
            Text("×").font(.caption).frame(width: 10)
            inputCell(title: "次数", value: reps, hint: "建议 12")
                .frame(width: 64)
            HStack(alignment: .center, spacing: 4) {
                if isChild {
                    Text("递减组").font(.system(size: 11))
                    Image(systemName: "ellipsis").frame(width: 28, height: 44)
                } else {
                    badge("🔥 热身")
                    badge("RPE 8")
                }
            }
            .frame(width: 100, height: 44)
        }
        .frame(height: isLargeMode ? 52 : 48)
        .padding(.horizontal, 4)
    }

    private func badge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: isLargeMode ? 11 : 10, weight: .semibold))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 3)
            .frame(height: 22)
            .foregroundStyle(theme.accent)
            .background(theme.accentSubtle, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    // ImageRenderer snapshots use a pure SwiftUI input presentation. Platform
    // text editing belongs to consumer integration tests, outside this raster fixture.
    private func inputCell(title: String, value: String, hint: String) -> some View {
        Text(value.isEmpty ? hint : value)
            .font(.system(size: isLargeMode ? 13 : 12, weight: .medium).monospacedDigit())
            .foregroundStyle(value.isEmpty ? theme.accent : theme.foreground)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(theme.surface(.inset), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .accessibilityLabel(title)
            .accessibilityValue(value.isEmpty ? hint : value)
            .accessibilityHint(hint)
    }

    private var keyboardDock: some View {
        VStack(spacing: 4) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9"], id: \.self) { key in
                    Text(key)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background(theme.surface(.card), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(theme.surface.ignoresSafeArea(.container, edges: .bottom))
        .ignoresSafeArea(.container, edges: .bottom)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.secondaryForeground.opacity(0.24))
                .frame(height: 1 / 2)
        }
    }
}
