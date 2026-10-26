# watchOS package boundary fixture

`python3 verify.py` compiles an external watchOS 8 consumer of the stable
`DesignTokens` product, then proves that selecting `Strata` fails with
the stable diagnostic:

`Strata is unavailable on watchOS; depend on the DesignTokens product only.`

This is a compile boundary only. It adds no watchOS component implementation or
runtime behavior.
