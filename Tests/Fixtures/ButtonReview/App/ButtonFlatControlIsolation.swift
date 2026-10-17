import SwiftUI

/// A separate positive control: no library control, scroll container, focus
/// binding/setter, text input, keyboard shortcut, or custom button style.
struct ButtonFlatControlIsolation: View {
    @State private var sentinelInside = false
    @State private var standardInside = false
    @State private var sentinelEntries = 0
    @State private var sentinelExits = 0
    @State private var standardEntries = 0
    @State private var standardExits = 0
    @State private var observedFocus = false
    @State private var focusChanges = 0
    @State private var actions = 0
    @State private var events: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("Flat standard-control isolation").font(.title2)
            Text("Pointer sentinel")
                .frame(width: 260, height: 80)
                .onHover { inside in
                    sentinelInside = inside
                    if inside { sentinelEntries += 1 } else { sentinelExits += 1 }
                    record("sentinel-hover=\(inside)")
                }
                .accessibilityIdentifier("flat-sentinel")
            Button {
                actions += 1
                record("standard-action=\(actions)")
            } label: {
                FlatStandardLabel { focused in
                    observedFocus = focused
                    focusChanges += 1
                    record("observed-label-focus=\(focused)")
                }
            }
            .buttonStyle(.bordered)
            .onHover { inside in
                standardInside = inside
                if inside { standardEntries += 1 } else { standardExits += 1 }
                record("standard-hover=\(inside)")
            }
            .accessibilityIdentifier("flat-standard")
            Text(observation)
                .font(.system(.caption, design: .monospaced))
                .frame(width: 700, height: 110, alignment: .topLeading)
                .accessibilityIdentifier("flat-observation")
            Text(events.joined(separator: "\n"))
                .font(.system(.caption, design: .monospaced))
                .frame(width: 700, height: 350, alignment: .topLeading)
                .accessibilityIdentifier("flat-events")
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var observation: String {
        "sentinel-inside=\(sentinelInside);sentinel-enter=\(sentinelEntries);sentinel-exit=\(sentinelExits);" +
        "standard-inside=\(standardInside);standard-enter=\(standardEntries);standard-exit=\(standardExits);" +
        "observed-label-focus=\(observedFocus);focus-samples=\(focusChanges);actions=\(actions)"
    }

    private func record(_ event: String) {
        let entry = String(format: "%.6f %@", ProcessInfo.processInfo.systemUptime, event)
        events.append(entry)
        print("BUTTON_FLAT_CALLBACK \(entry)")
    }
}

/// Read the standard Button's actual focus environment from its label. This
/// never requests focus and is distinct from FKA accessibility focus / settings.
private struct FlatStandardLabel: View {
    let observe: (Bool) -> Void
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        Text("Standard action")
            .frame(minWidth: 220, minHeight: 64)
            .onAppear { observe(isFocused) }
            .onChange(of: isFocused) { observe($0) }
    }
}
