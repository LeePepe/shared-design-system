import DesignTokens

let color = try DesignTokens.color("product.text.primary", theme: .light)
precondition(color.a == 1)
