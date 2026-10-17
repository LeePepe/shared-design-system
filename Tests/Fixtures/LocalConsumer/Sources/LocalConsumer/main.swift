import DesignTokens
import NativeDesignKit

let color = try DesignTokens.color("product.text.primary", theme: .light)
precondition(color.a == 1)
_ = NativeTokenColor.self
print("PASS local DesignTokens and NativeDesignKit consumer")
