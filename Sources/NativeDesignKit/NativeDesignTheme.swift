import DesignTokens
import SwiftUI

/// Pure semantic token roles resolved by NativeDesignKit.
enum SemanticTokenRole: String, CaseIterable, Sendable {
    case surfaceRaised = "product.surface.raised"
    case textPrimary = "product.text.primary"
    case textSecondary = "product.text.secondary"
    case statusInfo = "status.info"
    case statusOnInfo = "status.on-info"
    case statusWarning = "status.warning"
    case statusOnWarning = "status.on-warning"
    case statusCritical = "status.critical"
    case statusOnCritical = "status.on-critical"
    case surfaceCanvas = "product.surface.canvas"

    var tokenID: String { rawValue }
}

/// Opaque immutable snapshot of resolved semantic token colors for an explicit theme.
public struct NativeDesignTheme: Sendable {
    let theme: Theme
    let surfaceRaised: Color
    let textPrimary: Color
    let textSecondary: Color
    let statusInfo: Color
    let statusOnInfo: Color
    let statusWarning: Color
    let statusOnWarning: Color
    let statusCritical: Color
    let statusOnCritical: Color
    let surfaceCanvas: Color

    /// Resolves required semantic token colors for the explicit caller-supplied theme.
    public init(theme: Theme) throws {
        try self.init(theme: theme, resolve: NativeTokenColor.resolve)
    }

    /// Internal resolver-injection seam for testing error identity and requested-role order.
    init(theme: Theme, resolve: (String, Theme) throws -> Color) throws {
        self.theme = theme
        self.surfaceRaised = try resolve(SemanticTokenRole.surfaceRaised.tokenID, theme)
        self.textPrimary = try resolve(SemanticTokenRole.textPrimary.tokenID, theme)
        self.textSecondary = try resolve(SemanticTokenRole.textSecondary.tokenID, theme)
        self.statusInfo = try resolve(SemanticTokenRole.statusInfo.tokenID, theme)
        self.statusOnInfo = try resolve(SemanticTokenRole.statusOnInfo.tokenID, theme)
        self.statusWarning = try resolve(SemanticTokenRole.statusWarning.tokenID, theme)
        self.statusOnWarning = try resolve(SemanticTokenRole.statusOnWarning.tokenID, theme)
        self.statusCritical = try resolve(SemanticTokenRole.statusCritical.tokenID, theme)
        self.statusOnCritical = try resolve(SemanticTokenRole.statusOnCritical.tokenID, theme)
        self.surfaceCanvas = try resolve(SemanticTokenRole.surfaceCanvas.tokenID, theme)
    }
}
