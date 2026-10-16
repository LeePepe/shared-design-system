import SwiftUI

/// Fixed visual sizes; an interactive wrapper owns its separate hit region.
public enum NativeAvatarSize: Equatable, Sendable {
    case small
    case medium
    case large

    fileprivate var diameter: CGFloat {
        switch self {
        case .small: 32
        case .medium: 44
        case .large: 64
        }
    }

    fileprivate var font: Font {
        switch self {
        case .small: .caption
        case .medium: .body
        case .large: .title2
        }
    }
}

/// Caller-supplied visual content with one meaningful accessible label.
/// Configure image resizing and fit/fill in the content builder.
public struct NativeAvatar<Content: View>: View {
    private let theme: NativeDesignTheme
    private let size: NativeAvatarSize
    private let accessibilityLabel: Text
    private let content: Content

    public init(
        theme: NativeDesignTheme,
        size: NativeAvatarSize,
        accessibilityLabel: Text,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.size = size
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }

    public var body: some View {
        content
            .font(size.font.weight(.semibold))
            .foregroundStyle(theme.foreground)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(width: size.diameter, height: size.diameter)
            .background(theme.surface)
            .clipShape(Circle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(.isImage)
    }
}
