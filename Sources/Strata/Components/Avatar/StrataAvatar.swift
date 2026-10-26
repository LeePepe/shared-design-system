import SwiftUI

/// Fixed visual sizes; an interactive wrapper owns its separate hit region.
public enum StrataAvatarSize: Equatable, Sendable {
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
public struct StrataAvatar<Content: View>: View {
    private let theme: StrataTheme
    private let size: StrataAvatarSize
    private let accessibilityLabel: Text
    private let content: Content

    public init(
        theme: StrataTheme,
        size: StrataAvatarSize,
        accessibilityLabel: Text,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.size = size
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }

    public var body: some View {
        Circle()
            .fill(theme.surface)
            .frame(width: size.diameter, height: size.diameter)
            .overlay {
                content
                    .font(size.font.weight(.semibold))
                    .foregroundStyle(theme.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: size.diameter, height: size.diameter)
                    .accessibilityHidden(true)
            }
            .clipShape(Circle())
            .contentShape(Circle())
            // Arbitrary caller content is decorative; only the caller label is exposed.
            .accessibilityRepresentation {
                Circle()
                    .fill(theme.surface)
                    .frame(width: size.diameter, height: size.diameter)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(accessibilityLabel)
                    .accessibilityAddTraits(.isImage)
            }
    }
}
