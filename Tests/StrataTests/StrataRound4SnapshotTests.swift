import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

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

            XCTAssertLessThanOrEqual(renderedHeight(sectionHeader), 44)
            XCTAssertLessThanOrEqual(renderedHeight(stickyHeader), 44)
        }

        let inactive = StrataBottomSlot(isActive: false) {
            Text("Active snackbar content")
        }
        XCTAssertEqual(renderedHeight(inactive), 0)
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
                try renderSnapshot(
                    HighDensityComposite(theme: theme, isLargeMode: false, isSnackbarActive: false)
                        .environment(\.layoutDirection, direction)
                        .frame(width: 390),
                    named: "round-4-\(mode.rawValue)-\(name)"
                )
                try renderSnapshot(
                    HighDensityComposite(theme: theme, isLargeMode: true, isSnackbarActive: false)
                        .environment(\.layoutDirection, direction)
                        .frame(width: 390),
                    named: "round-4-\(mode.rawValue)-\(name)-large"
                )
                try renderSnapshot(
                    HighDensityComposite(theme: theme, isLargeMode: true, isSnackbarActive: true)
                        .environment(\.layoutDirection, direction)
                        .frame(width: 390),
                    named: "round-4-\(mode.rawValue)-\(name)-active"
                )
            }
        }
    }

    @MainActor
    private func renderSnapshot<V: View>(_ view: V, named: String) throws {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        let data: Data?
        #if os(macOS)
        if let image = renderer.nsImage,
           let tiff = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff) {
            data = bitmap.representation(using: .png, properties: [:])
        } else {
            data = nil
        }
        #elseif canImport(UIKit)
        data = renderer.uiImage?.pngData()
        #else
        data = nil
        #endif

        guard let data else {
            XCTFail("ImageRenderer did not produce PNG data for \(named)")
            return
        }
        XCTAssertEqual(Array(data.prefix(8)), [137, 80, 78, 71, 13, 10, 26, 10])
        let directory = snapshotDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: directory.appendingPathComponent("\(named).png"))
    }

    private func snapshotDirectory() -> URL {
        if let path = ProcessInfo.processInfo.environment["STRATA_SNAPSHOT_DIR"], !path.isEmpty {
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        return FileManager.default.temporaryDirectory.appendingPathComponent("strata-snapshots/round-4")
    }

    @MainActor
    private func renderedHeight<V: View>(_ view: V) -> CGFloat {
        #if os(macOS)
        return NSHostingView(rootView: view).fittingSize.height
        #elseif canImport(UIKit)
        let host = UIHostingController(rootView: view)
        return host.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        #else
        return 0
        #endif
    }
}

@available(macOS 13, iOS 16, *)
private struct HighDensityComposite: View {
    let theme: StrataTheme
    let isLargeMode: Bool
    let isSnackbarActive: Bool
    @State private var weightOne = ""
    @State private var repsOne = ""
    @State private var weightTwo = "85"
    @State private var repsTwo = "8"
    @State private var weightThree = "72"
    @State private var repsThree = "10"
    @State private var showsSubRows = true

    var body: some View {
        VStack(spacing: 0) {
            sectionHeader
            stickyHeader
            HStack(alignment: .top, spacing: 0) {
                sidebar
                VStack(spacing: 0) {
                    setRow(index: "1", checkboxOn: true, weight: $weightOne, reps: $repsOne, warmUp: true)
                        .transition(StrataMotion.subRowTransition(reduceMotion: false))
                    if showsSubRows {
                        subRow(index: "↳1", weight: $weightTwo, reps: $repsTwo)
                            .transition(StrataMotion.subRowTransition(reduceMotion: false))
                        subRow(index: "↳2", weight: $weightThree, reps: $repsThree)
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
            StrataBottomSlot(isActive: isSnackbarActive) {
                Text("组间休息 01:30")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .padding(.horizontal, 16)
                    .background(theme.surface(.card))
                    .transition(StrataMotion.subRowTransition(reduceMotion: false))
            }
            keyboardDock
        }
        .background(theme.surface)
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

    private func setRow(
        index: String,
        checkboxOn: Bool,
        weight: Binding<String>,
        reps: Binding<String>,
        warmUp: Bool
    ) -> some View {
        HStack(alignment: .center, spacing: 4) {
            Text(index).frame(width: 24)
            Image(systemName: checkboxOn ? "checkmark.circle.fill" : "circle")
                .frame(width: 44, height: 44)
            editableCell(title: "重量", text: weight, hint: "建议 0lb")
            editableCell(title: "次数", text: reps, hint: "建议 12")
            VStack(alignment: .leading, spacing: 4) {
                if warmUp {
                    Text("热身")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 5)
                        .frame(height: 22)
                        .background(theme.accentSubtle, in: Capsule())
                }
                Text("RPE 8")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 5)
                    .frame(height: 22)
                    .background(theme.accentSubtle, in: Capsule())
            }
        }
        .frame(minHeight: 44)
        .padding(.horizontal, 4)
    }

    private func subRow(index: String, weight: Binding<String>, reps: Binding<String>) -> some View {
        HStack(alignment: .center, spacing: 4) {
            Text(index).font(.caption2).frame(width: 24)
            Color.clear.frame(width: 44, height: 44)
            editableCell(title: "重量", text: weight, hint: "递减")
            editableCell(title: "次数", text: reps, hint: "递减")
            Text("递减组")
                .font(.caption2)
                .frame(width: 48)
        }
        .frame(minHeight: 44)
        .padding(.horizontal, 4)
        .background(theme.surface(.card).opacity(0.35))
    }

    private func editableCell(title: String, text: Binding<String>, hint: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title).font(.caption2).foregroundStyle(theme.secondaryForeground)
            TextField(hint, text: text)
                .textFieldStyle(.plain)
                .frame(width: 58, height: 30)
                .padding(.horizontal, 4)
                .background(theme.surface(.card), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            StrataInlineHint(theme: theme, label: title, hint: hint)
        }
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
        .padding(.bottom, 34)
        .frame(maxWidth: .infinity)
        .background(theme.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.secondaryForeground.opacity(0.24))
                .frame(height: 1 / 2)
        }
    }
}
