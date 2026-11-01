# StrataActionCardRow

`StrataActionCardRow` composes a card row with a prioritized text column, an
optional badge, and one trailing action slot. Use it when a row needs one
separate 44 pt action target; do not stack multiple trailing buttons or add
product-specific chrome.

The caller supplies the explicit theme and content. The component owns layout
alignment only; labels, actions, state, and localization remain caller-owned.
