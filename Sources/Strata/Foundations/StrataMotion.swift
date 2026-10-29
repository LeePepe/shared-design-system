import DesignTokens
import SwiftUI

/// Token-backed motion presets shared by stateful Strata components.
public enum StrataMotion {
    public static var snappy: Animation {
        spring(named: "spring.snappy")
    }

    public static var standard: Animation {
        spring(named: "spring.standard")
    }

    public static var gentle: Animation {
        spring(named: "spring.gentle")
    }

    /// Returns no animation when the caller has requested reduced motion.
    public static func animation(
        _ animation: Animation = .strataStandard,
        reduceMotion: Bool
    ) -> Animation? {
        reduceMotion ? nil : animation
    }

    private static func spring(named id: String) -> Animation {
        let token = try! StyleTokens.spring(id)
        return .spring(
            response: token.response,
            dampingFraction: token.dampingFraction,
            blendDuration: token.blendDuration
        )
    }
}

public extension Animation {
    static var strataSnappy: Animation { StrataMotion.snappy }
    static var strataStandard: Animation { StrataMotion.standard }
    static var strataGentle: Animation { StrataMotion.gentle }
}
