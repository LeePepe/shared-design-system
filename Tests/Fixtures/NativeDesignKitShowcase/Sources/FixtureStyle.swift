import Foundation
import NativeDesignKit
import SwiftUI

/// Sample-only adapter for the provider's generated artifact. No embedded values/fallbacks.
/// The library itself continues to resolve released color tokens at exact 0.1.1.
struct FixtureStyle {
    private let tokens: [String: Any]

    init(bundle: Bundle) throws {
        guard let url = bundle.url(forResource: "styles.resolved", withExtension: "json"),
              let document = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any],
              let tokens = document["tokens"] as? [String: Any] else {
            throw FixtureError.missingProviderArtifact
        }
        self.tokens = tokens
    }

    func number(_ id: String) throws -> Double {
        guard let value = tokens[id] as? Double, value.isFinite else { throw FixtureError.invalidStyle(id) }
        return value
    }

    func object(_ id: String) throws -> [String: Any] {
        guard let value = tokens[id] as? [String: Any] else { throw FixtureError.invalidStyle(id) }
        return value
    }

    func typography(_ id: String) throws -> NativeTypography {
        let item = try object(id)
        guard let size = item["size"] as? Double, let lineHeight = item["lineHeight"] as? Double,
              let tracking = item["tracking"] as? Double, let weight = item["weight"] as? Double,
              let relative = item["relativeTo"] as? String, let digits = item["monospacedDigits"] as? Bool else {
            throw FixtureError.invalidStyle(id)
        }
        let styles: [String: Font.TextStyle] = ["largeTitle": .largeTitle, "title": .title, "title2": .title2,
            "title3": .title3, "headline": .headline, "body": .body, "callout": .callout,
            "subheadline": .subheadline, "footnote": .footnote, "caption": .caption, "caption2": .caption2]
        let weights: [Double: Font.Weight] = [100: .ultraLight, 200: .thin, 300: .light, 400: .regular,
            500: .medium, 600: .semibold, 700: .bold, 800: .heavy, 900: .black]
        guard let textStyle = styles[relative], let fontWeight = weights[weight] else {
            throw FixtureError.invalidStyle(id)
        }
        return NativeTypography(size: size, relativeTo: textStyle, weight: fontWeight,
                                lineSpacing: max(0, lineHeight - size), tracking: tracking, monospacedDigits: digits)
    }

    func controlMetrics() throws -> NativeControlMetrics {
        try NativeControlMetrics(padding: number("spacing.sm"), spacing: number("spacing.sm"),
            cornerRadius: number("radius.medium"), minimumHitSize: number("dimension.hit.minimum"),
            iconSize: number("dimension.icon.medium"), borderWidth: number("border.regular"),
            disabledOpacity: number("opacity.disabled"))
    }

    func surfaceMetrics() throws -> NativeSurfaceMetrics {
        let shadow = try object("shadow.small")
        func field(_ name: String) throws -> Double {
            guard let value = shadow[name] as? Double else { throw FixtureError.invalidStyle("shadow.small.\(name)") }
            return value
        }
        return try NativeSurfaceMetrics(cornerRadius: number("radius.large"), borderWidth: number("border.hairline"),
            borderOpacity: number("opacity.subtle"), shadowRadius: field("radius"), shadowX: field("x"),
            shadowY: field("y"), shadowOpacity: field("opacity"))
    }

    func motion() throws -> NativeMotionSpec {
        let curve = try object("curve.standard")
        func field(_ name: String) throws -> Double {
            guard let value = curve[name] as? Double else { throw FixtureError.invalidStyle("curve.standard.\(name)") }
            return value
        }
        return try .cubicBezier(duration: number("duration.standard"), x1: field("x1"), y1: field("y1"),
                                x2: field("x2"), y2: field("y2"))
    }
}

enum FixtureError: Error { case missingProviderArtifact, invalidStyle(String) }
