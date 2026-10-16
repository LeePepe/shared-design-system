# NativeTextField — unreleased

`NativeTextField` is a SwiftUI text input with a visible caller-provided label,
an opaque Strata input surface and a continuous accent focus outline. It uses
system semantic fonts, a 16 pt corner radius and a minimum 44 pt input height;
content can grow with Dynamic Type. It requires an explicitly resolved
`NativeDesignTheme` and owns no product data or validation rules.

```swift
import DesignTokens
import NativeDesignKit
import SwiftUI

struct NameInput: View {
    let theme: NativeDesignTheme
    @State private var name = ""

    var body: some View {
        NativeTextField(theme: theme, text: $name, prompt: Text("Your name")) {
            Text("Display name")
        }
        .onSubmit {
            // The consumer decides how to handle submission.
        }
    }
}
```

The public generic shape is `NativeTextField<Label: View>`. Its initializer is
`init(theme:text:prompt:label:)`, where `text` is `Binding<String>`, `prompt` is
an optional `Text` defaulting to `nil`, and `label` is a required `@ViewBuilder`.
Supply localized label and prompt content. SwiftUI pairs the visible label
with the native text input for accessibility, avoiding a duplicate standalone
label announcement and retaining generic caller-provided label content.

The input remains a SwiftUI `TextField`: `.disabled`, `.onSubmit`, `.submitLabel`,
native editing, selection and keyboard behavior remain available. The full
padded input surface activates the editor when enabled; a simultaneous tap
leaves the native caret and selection gestures with the editor. Add platform
input configuration using ordinary SwiftUI modifiers. The component does not
trim or rewrite input, invent a clear action, select a keyboard, manage focus
for a form, or validate a value. Input remains single-line with native horizontal
scrolling for long values; visible labels wrap and input height grows with
semantic typography. Compose descriptive validation text and symbols
outside the component and associate them with the input using the consumer's
accessibility policy. Labels should remain meaningful when announced alone.

Inputs intentionally use the same solid semantic surface in both themes;
they do not add an independent glass layer. Reconstruct the explicit theme
when the consumer changes theme or brand. See [the component contract](../COMPONENTS.md)
for token authority, the supported `ocean` / `graphite` brands and release status.

This is additive unreleased API; the published `NativeTokenColor` API, token
dependency and platform floors are unchanged. Rollback removes uses of this
component before returning to a release that contains only the color bridge.

The synthetic [runtime review fixture](../../Tests/Fixtures/TextFieldReview/README.md)
records how prior hosting assertions move to actual SwiftUI/XCTest UI tests.
Its simulator evidence does not claim VoiceOver, macOS keyboard interaction,
physical-device or minimum-OS acceptance.
