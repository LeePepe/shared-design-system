import DesignTokens
import SwiftUI

/// Token-backed motion presets shared by stateful Strata components.
public struct StrataMotion {
    public let snappy: Animation
    public let standard: Animation
    public let gentle: Animation

    public init(
        spring: (String) throws -> SpringToken = StyleTokens.spring
    ) throws {
        let snappy = try spring("spring.snappy")
        let standard = try spring("spring.standard")
        let gentle = try spring("spring.gentle")
        self.snappy = .spring(
            response: snappy.response,
            dampingFraction: snappy.dampingFraction,
            blendDuration: snappy.blendDuration
        )
        self.standard = .spring(
            response: standard.response,
            dampingFraction: standard.dampingFraction,
            blendDuration: standard.blendDuration
        )
        self.gentle = .spring(
            response: gentle.response,
            dampingFraction: gentle.dampingFraction,
            blendDuration: gentle.blendDuration
        )
    }

    public static func snappy(
        spring: (String) throws -> SpringToken = StyleTokens.spring
    ) throws -> Animation {
        try animation(for: spring("spring.snappy"))
    }

    public static func standard(
        spring: (String) throws -> SpringToken = StyleTokens.spring
    ) throws -> Animation {
        try animation(for: spring("spring.standard"))
    }

    public static func gentle(
        spring: (String) throws -> SpringToken = StyleTokens.spring
    ) throws -> Animation {
        try animation(for: spring("spring.gentle"))
    }

    /// Standard insertion/removal transition for shared-grid sub-rows.
    public static func subRowTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .opacity.combined(with: .move(edge: .top))
    }

    private static func animation(for token: SpringToken) -> Animation {
        return .spring(
            response: token.response,
            dampingFraction: token.dampingFraction,
            blendDuration: token.blendDuration
        )
    }

    /// Returns no animation when the caller has requested reduced motion.
    public static func animation(
        _ animation: Animation,
        reduceMotion: Bool
    ) -> Animation? {
        reduceMotion ? nil : animation
    }
}
