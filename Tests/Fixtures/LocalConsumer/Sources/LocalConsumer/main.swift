import DesignTokens
import Strata

let color = try DesignTokens.color("product.text.primary", theme: .light)
precondition(color.a == 1)
_ = StrataTokenColor.self
print("PASS local DesignTokens and Strata consumer")
