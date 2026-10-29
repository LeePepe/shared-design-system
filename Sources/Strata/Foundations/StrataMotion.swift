import DesignTokens
import SwiftUI

/// Token-backed motion presets shared by stateful Strata components.
public enum StrataMotion {
    public static var snappy: Animation { .spring(response: 0.28, dampingFraction: 0.82, blendDuration: 0) }

    public static var standard: Animation { .spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0) }

    public static var gentle: Animation { .spring(response: 0.6, dampingFraction: 0.9, blendDuration: 0) }

    public static func spring(named id: String) throws -> Animation {
        let token = try StyleTokens.spring(id)
        return .spring(
            response: token.response,
            dampingFraction: token.dampingFraction,
            blendDuration: token.blendDuration
        )
    }

    /// Returns no animation when the caller has requested reduced motion.
    public static func animation(
        _ animation: Animation = .strataStandard,
        reduceMotion: Bool
    ) -> Animation? {
        reduceMotion ? nil : animation
    }

}

public extension Animation {
    static var strataSnappy: Animation { StrataMotion.snappy }
    static var strataStandard: Animation { StrataMotion.standard }
    static var strataGentle: Animation { StrataMotion.gentle }
}
