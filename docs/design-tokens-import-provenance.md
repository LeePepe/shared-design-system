# DesignTokens v0.2.0 import provenance

This manifest binds the S100 import to the public immutable provider release unit without embedding the containing target commit.

- Provider: `LeePepe/shared-design-tokens`
- Provider commit/tag target: `87bef8fbab5bf67a748815d7ed04d7ae199f760a` (`v0.2.0`)
- Provider license: `MIT`; imported `LICENSE` blob `62f889e5833f92c5757c43c1728a3cbddc4cec85`
- Target root remains `LeePepe/shared-design-system`; NativeDesignKit continues to resolve the external provider during S100.

## Imported source-path and adaptation table

| Provider source path | Target path | Provider blob | Imported target blob | Action |
| --- | --- | --- | --- | --- |
| `CHANGELOG.md` | `Packages/DesignTokens/CHANGELOG.md` | `31bd9445bf9b653fdf9efe4c5b9ee46be58b2718` | `31bd9445bf9b653fdf9efe4c5b9ee46be58b2718` | exact relocated copy |
| `LICENSE` | `Packages/DesignTokens/LICENSE` | `62f889e5833f92c5757c43c1728a3cbddc4cec85` | `62f889e5833f92c5757c43c1728a3cbddc4cec85` | exact relocated copy |
| `Package.swift` | `Packages/DesignTokens/Package.swift` | `969177d276aeb9e27ad45aafead019e4c6b7608d` | `969177d276aeb9e27ad45aafead019e4c6b7608d` | exact relocated copy |
| `README.md` | `Packages/DesignTokens/README.md` | `55acfd0ce49801fca5961bed2457cd9f017a67c1` | `9a9a08439ae3ce65ef53d2e8c023d09d098ad8b6` | adapted: remove the excluded provider root-agent link and point at the relocated support context while preserving the versioned product contract |
| `Sources/DesignTokens/DesignTokens.swift` | `Packages/DesignTokens/Sources/DesignTokens/DesignTokens.swift` | `c0d00038345250436434ba726053bb8b6c587358` | `c0d00038345250436434ba726053bb8b6c587358` | exact relocated copy |
| `Sources/DesignTokens/GeneratedColors.swift` | `Packages/DesignTokens/Sources/DesignTokens/GeneratedColors.swift` | `f2fc48715a44fa379a1cd5a28b73c4a18445c287` | `f2fc48715a44fa379a1cd5a28b73c4a18445c287` | exact relocated copy |
| `Sources/DesignTokens/GeneratedStyles.swift` | `Packages/DesignTokens/Sources/DesignTokens/GeneratedStyles.swift` | `9ff1f7205ea76704d717c077bbe3f33867ef7b77` | `9ff1f7205ea76704d717c077bbe3f33867ef7b77` | exact relocated copy |
| `Sources/DesignTokens/StyleTokens.swift` | `Packages/DesignTokens/Sources/DesignTokens/StyleTokens.swift` | `e592673b64c6386012759f457f53dbe738dbbcfb` | `e592673b64c6386012759f457f53dbe738dbbcfb` | exact relocated copy |
| `THIRD_PARTY_NOTICES.md` | `Packages/DesignTokens/THIRD_PARTY_NOTICES.md` | `af4993403e3e2115ae16b43359f80f70a5d492ce` | `af4993403e3e2115ae16b43359f80f70a5d492ce` | exact relocated copy |
| `ai/COMPATIBILITY.md` | `Packages/DesignTokens/ai/COMPATIBILITY.md` | `94070506ae861ac1eaa86e710e2b677532f54063` | `94070506ae861ac1eaa86e710e2b677532f54063` | exact relocated copy |
| `ai/EXAMPLES.md` | `Packages/DesignTokens/ai/EXAMPLES.md` | `aefb2094b70a02cac2e8aca22b60a4f7df96ac02` | `aefb2094b70a02cac2e8aca22b60a4f7df96ac02` | exact relocated copy |
| `ai/INTEGRATION.md` | `Packages/DesignTokens/ai/INTEGRATION.md` | `9e2d99e5a19d331e64674b5ac45f995476ea4696` | `9e2d99e5a19d331e64674b5ac45f995476ea4696` | exact relocated copy |
| `ai/MIGRATION.md` | `Packages/DesignTokens/ai/MIGRATION.md` | `d9dd270ce1c625a0cb442123ac144018235f4106` | `d9dd270ce1c625a0cb442123ac144018235f4106` | exact relocated copy |
| `ai/README.md` | `Packages/DesignTokens/ai/README.md` | `692c0fad75ba74b8e35bbad8cdbf2b86c9c38a38` | `692c0fad75ba74b8e35bbad8cdbf2b86c9c38a38` | exact relocated copy |
| `ai/USAGE.md` | `Packages/DesignTokens/ai/USAGE.md` | `05ce3bd2047890972d8299fe7b4e962f9645dd13` | `05ce3bd2047890972d8299fe7b4e962f9645dd13` | exact relocated copy |
| `ai/registry.json` | `Packages/DesignTokens/ai/registry.json` | `aa1587a79b37c4f2a105dd98f48be6ec14feb6c7` | `aa1587a79b37c4f2a105dd98f48be6ec14feb6c7` | exact relocated copy |
| `ai/registry.schema.json` | `Packages/DesignTokens/ai/registry.schema.json` | `f189648e5d9ae8878305c5796cac52cf4eb239b6` | `f189648e5d9ae8878305c5796cac52cf4eb239b6` | exact relocated copy |
| `dist/colors.css` | `Packages/DesignTokens/dist/colors.css` | `997aae5cd9742a220fee7870d7c36c8009cbeef3` | `997aae5cd9742a220fee7870d7c36c8009cbeef3` | exact relocated copy |
| `dist/colors.ts` | `Packages/DesignTokens/dist/colors.ts` | `6e02e23728fb5f3ccd9145435d50b131d1370bcf` | `6e02e23728fb5f3ccd9145435d50b131d1370bcf` | exact relocated copy |
| `dist/index.d.ts` | `Packages/DesignTokens/dist/index.d.ts` | `1c1faf9dec5461ec633ba6c698b16b33417c2187` | `1c1faf9dec5461ec633ba6c698b16b33417c2187` | exact relocated copy |
| `dist/index.js` | `Packages/DesignTokens/dist/index.js` | `9c16490a44c6c19aab3c738c3877a5f19f0cc696` | `9c16490a44c6c19aab3c738c3877a5f19f0cc696` | exact relocated copy |
| `dist/resolved.json` | `Packages/DesignTokens/dist/resolved.json` | `1679acb713c44ddc28a39ffa2e176cb199e8d8e6` | `1679acb713c44ddc28a39ffa2e176cb199e8d8e6` | exact relocated copy |
| `dist/styles.d.ts` | `Packages/DesignTokens/dist/styles.d.ts` | `8e1050fd69f73c95bc7ffc3e151cd59686f9dda1` | `8e1050fd69f73c95bc7ffc3e151cd59686f9dda1` | exact relocated copy |
| `dist/styles.js` | `Packages/DesignTokens/dist/styles.js` | `eb33be3d798a4883740fc574c408a285f614210f` | `eb33be3d798a4883740fc574c408a285f614210f` | exact relocated copy |
| `dist/styles.resolved.json` | `Packages/DesignTokens/dist/styles.resolved.json` | `00215b0d1f77194ac66c1b7e84eca7e4a8ff425b` | `00215b0d1f77194ac66c1b7e84eca7e4a8ff425b` | exact relocated copy |
| `docs/ai-checker.md` | `Packages/DesignTokens/docs/ai-checker.md` | `a5f1d93f4240bced52b22a5c0b641aba92dcfaf3` | `a5f1d93f4240bced52b22a5c0b641aba92dcfaf3` | exact relocated copy |
| `docs/architecture/swift/tech-context.md` | `Packages/DesignTokens/docs/architecture/swift/provider-tech-context.md` | `1c02904039605823049fe1e64199ef24431d6a0b` | `1c02904039605823049fe1e64199ef24431d6a0b` | exact support copy relocated away from the reserved active-layer filename |
| `docs/architecture/tech-context.md` | `Packages/DesignTokens/docs/architecture/provider-tech-context.md` | `818af0e72dfe7f294a9643a062639ec078d0568c` | `818af0e72dfe7f294a9643a062639ec078d0568c` | exact support copy relocated away from the reserved active-layer filename |
| `docs/architecture/tokens/tech-context.md` | `Packages/DesignTokens/docs/architecture/tokens/provider-tech-context.md` | `2692dab2bad0c37a75a419d85e333d91b2a60455` | `2692dab2bad0c37a75a419d85e333d91b2a60455` | exact support copy relocated away from the reserved active-layer filename |
| `docs/compatibility.md` | `Packages/DesignTokens/docs/compatibility.md` | `5cacb772fe684dafffbcd11ef73bde34f30009db` | `5cacb772fe684dafffbcd11ef73bde34f30009db` | exact relocated copy |
| `docs/constitution.md` | `Packages/DesignTokens/docs/constitution.md` | `38afb5e8fb34bcd1dc993093755fb678be41b2c1` | `38afb5e8fb34bcd1dc993093755fb678be41b2c1` | exact relocated copy |
| `docs/upstream.md` | `Packages/DesignTokens/docs/upstream.md` | `29b585363c11f0a34bff6907c93c29ba024e4526` | `29b585363c11f0a34bff6907c93c29ba024e4526` | exact relocated copy |
| `docs/verification.md` | `Packages/DesignTokens/docs/verification.md` | `06703a6e0a74322d3efba2c36967a154cb4e57b4` | `06703a6e0a74322d3efba2c36967a154cb4e57b4` | exact relocated copy |
| `examples/data/legacy-colors.json` | `Packages/DesignTokens/examples/data/legacy-colors.json` | `a0a981edbcb132591664c04c642224cf7fa69754` | `a0a981edbcb132591664c04c642224cf7fa69754` | exact relocated copy |
| `examples/data/migration.mjs` | `Packages/DesignTokens/examples/data/migration.mjs` | `c22d4cf1f2b517bee3f561b146aaf86ae0124c30` | `c22d4cf1f2b517bee3f561b146aaf86ae0124c30` | exact relocated copy |
| `examples/data/swift/Package.swift` | `Packages/DesignTokens/examples/data/swift/Package.swift` | `03f2408c45959ec1909d8d2e0f1e8a58dae6f790` | `03f2408c45959ec1909d8d2e0f1e8a58dae6f790` | exact relocated copy |
| `examples/data/swift/Sources/TokenExample/main.swift` | `Packages/DesignTokens/examples/data/swift/Sources/TokenExample/main.swift` | `1feabe13d80f7eaf70318e13c3220a95f61bea87` | `1feabe13d80f7eaf70318e13c3220a95f61bea87` | exact relocated copy |
| `examples/data/usage.mjs` | `Packages/DesignTokens/examples/data/usage.mjs` | `6b425d96970768032f0078250d00b6d647d07ccd` | `6b425d96970768032f0078250d00b6d647d07ccd` | exact relocated copy |
| `examples/data/usage.ts` | `Packages/DesignTokens/examples/data/usage.ts` | `6042908afef1889e04dd08e4c1721671b37e3c6d` | `6042908afef1889e04dd08e4c1721671b37e3c6d` | exact relocated copy |
| `package-lock.json` | `Packages/DesignTokens/package-lock.json` | `89a0387f92b021cd8dd48b9da512809764cf661d` | `89a0387f92b021cd8dd48b9da512809764cf661d` | exact relocated copy |
| `package.json` | `Packages/DesignTokens/package.json` | `eda0adb83ac70fbb4044124cf803571ee0192efa` | `089ab96da40b332049a88f85af315cfc97fe1717` | adapted: remove the deliberately excluded provider root-agent file from the packed allowlist and add target-only verification commands |
| `scripts/browser-css.mjs` | `Packages/DesignTokens/scripts/browser-css.mjs` | `4cf0a42b11158ca7be1725d4ab64dcccbd2b94eb` | `4cf0a42b11158ca7be1725d4ab64dcccbd2b94eb` | exact relocated copy |
| `scripts/check-ai-contract.mjs` | `Packages/DesignTokens/scripts/check-ai-contract.mjs` | `48ecbc180da978f57de05750f00534201dd66a9c` | `48ecbc180da978f57de05750f00534201dd66a9c` | exact relocated copy |
| `scripts/ci/setup.sh` | `Packages/DesignTokens/scripts/ci/setup.sh` | `4fb3f7d4da77e757c5ed9491db2f41fe1cf3da24` | `4fb3f7d4da77e757c5ed9491db2f41fe1cf3da24` | exact relocated copy |
| `scripts/generate-styles.mjs` | `Packages/DesignTokens/scripts/generate-styles.mjs` | `be346135f32d727bb4e2bdb662aff9ee85fd813e` | `be346135f32d727bb4e2bdb662aff9ee85fd813e` | exact relocated copy |
| `scripts/generate.mjs` | `Packages/DesignTokens/scripts/generate.mjs` | `5c60e725181e4e26cdb4d949e8508a1c4b1af7e0` | `5c60e725181e4e26cdb4d949e8508a1c4b1af7e0` | exact relocated copy |
| `scripts/source.mjs` | `Packages/DesignTokens/scripts/source.mjs` | `3afd43bb865cfc5d4359ae0b59acead47bdb6893` | `3afd43bb865cfc5d4359ae0b59acead47bdb6893` | exact relocated copy |
| `scripts/style-source.mjs` | `Packages/DesignTokens/scripts/style-source.mjs` | `24716e1d4e22ef46618a9ca4ed55580f4282112a` | `24716e1d4e22ef46618a9ca4ed55580f4282112a` | exact relocated copy |
| `scripts/test-consumer.mjs` | `Packages/DesignTokens/scripts/test-consumer.mjs` | `4780323436d20c679a29023164cd37f1fa38e3c7` | `4780323436d20c679a29023164cd37f1fa38e3c7` | exact relocated copy |
| `scripts/test-contract-pack.mjs` | `Packages/DesignTokens/scripts/test-contract-pack.mjs` | `261ed8c27137eb1d5d7ea7fe71b9173efed65571` | `261ed8c27137eb1d5d7ea7fe71b9173efed65571` | exact relocated copy |
| `scripts/test-pack.mjs` | `Packages/DesignTokens/scripts/test-pack.mjs` | `578a0e80f6c13be9756d1ce55c17b62d3d08c7e2` | `578a0e80f6c13be9756d1ce55c17b62d3d08c7e2` | exact relocated copy |
| `scripts/test-swift-consumer.mjs` | `Packages/DesignTokens/scripts/test-swift-consumer.mjs` | `b7c13f4edb615f83672141f55058163fd53fb1f5` | `b7c13f4edb615f83672141f55058163fd53fb1f5` | exact relocated copy |
| `scripts/verify` | `Packages/DesignTokens/scripts/verify` | `f83271cb6c667eb147c3dd5083d5ea312f00a010` | `f83271cb6c667eb147c3dd5083d5ea312f00a010` | exact relocated copy |
| `specs/001-shared-colors/plan.md` | `Packages/DesignTokens/specs/001-shared-colors/plan.md` | `682d301341b1f7d171fea8b7168dffcacb94bd15` | `682d301341b1f7d171fea8b7168dffcacb94bd15` | exact relocated copy |
| `specs/001-shared-colors/spec.md` | `Packages/DesignTokens/specs/001-shared-colors/spec.md` | `ac191713669f5c6ba7254d4dff6ab799b965fea3` | `ac191713669f5c6ba7254d4dff6ab799b965fea3` | exact relocated copy |
| `specs/001-shared-colors/tasks.md` | `Packages/DesignTokens/specs/001-shared-colors/tasks.md` | `43c33c5a66485841ae7a1680e2b0cb8bf43bcc8c` | `43c33c5a66485841ae7a1680e2b0cb8bf43bcc8c` | exact relocated copy |
| `specs/002-style-foundations/spec.md` | `Packages/DesignTokens/specs/002-style-foundations/spec.md` | `c8db14549f7b9ff469b0d2f62c881eb7a0aabfff` | `c8db14549f7b9ff469b0d2f62c881eb7a0aabfff` | exact relocated copy |
| `specs/003-strata-palettes.md` | `Packages/DesignTokens/specs/003-strata-palettes.md` | `c57ca483402d9ad6a750447fb8ee1f0159228c3e` | `c57ca483402d9ad6a750447fb8ee1f0159228c3e` | exact relocated copy |
| `tests/DesignTokensTests/DesignTokensTests.swift` | `Packages/DesignTokens/tests/DesignTokensTests/DesignTokensTests.swift` | `9e92c19f7f10a0b0613bd320586ce34d76d87d16` | `9e92c19f7f10a0b0613bd320586ce34d76d87d16` | exact relocated copy |
| `tests/DesignTokensTests/StyleTokensTests.swift` | `Packages/DesignTokens/tests/DesignTokensTests/StyleTokensTests.swift` | `17cc40a627df341272e64f814bc1752b711bed2b` | `17cc40a627df341272e64f814bc1752b711bed2b` | exact relocated copy |
| `tests/ai-checker.test.mjs` | `Packages/DesignTokens/tests/ai-checker.test.mjs` | `a0047c3e50691e2fa00ecb52fa21e22ec8602a39` | `a0047c3e50691e2fa00ecb52fa21e22ec8602a39` | exact relocated copy |
| `tests/browser-cleanup.test.mjs` | `Packages/DesignTokens/tests/browser-cleanup.test.mjs` | `d7b43649eef925f2ccad5b183569a3af5ee6316f` | `d7b43649eef925f2ccad5b183569a3af5ee6316f` | exact relocated copy |
| `tests/browser.test.mjs` | `Packages/DesignTokens/tests/browser.test.mjs` | `f074a4112d124124ed3c6d540a400d460ab16867` | `f074a4112d124124ed3c6d540a400d460ab16867` | exact relocated copy |
| `tests/consumer/consumer.ts` | `Packages/DesignTokens/tests/consumer/consumer.ts` | `1098bcf2705ce672f9678dd347d6cf39b2ee8246` | `1098bcf2705ce672f9678dd347d6cf39b2ee8246` | exact relocated copy |
| `tests/contract-pack-offline.test.mjs` | `Packages/DesignTokens/tests/contract-pack-offline.test.mjs` | `69c7d4307df51725910258271fc3cef507c8652c` | `69c7d4307df51725910258271fc3cef507c8652c` | exact relocated copy |
| `tests/generator.test.mjs` | `Packages/DesignTokens/tests/generator.test.mjs` | `b493112baabb6b5e357dad5c79e5c9c28a06d974` | `b493112baabb6b5e357dad5c79e5c9c28a06d974` | exact relocated copy |
| `tests/runtime.test.mjs` | `Packages/DesignTokens/tests/runtime.test.mjs` | `3aebbc97c381e6962d9de224b38b5672b785d809` | `3aebbc97c381e6962d9de224b38b5672b785d809` | exact relocated copy |
| `tests/source.test.mjs` | `Packages/DesignTokens/tests/source.test.mjs` | `f0ca5b463dd488a0319e2cfb784e0119b556eee1` | `f0ca5b463dd488a0319e2cfb784e0119b556eee1` | exact relocated copy |
| `tests/strata.test.mjs` | `Packages/DesignTokens/tests/strata.test.mjs` | `7c9fbec999582de9360ffe2b31b73c14d859d4ab` | `7c9fbec999582de9360ffe2b31b73c14d859d4ab` | exact relocated copy |
| `tests/styles.test.mjs` | `Packages/DesignTokens/tests/styles.test.mjs` | `ebe73e2c8c07e8a8ef24ceadae0ce49469894399` | `ebe73e2c8c07e8a8ef24ceadae0ce49469894399` | exact relocated copy |
| `tests/upstream.test.mjs` | `Packages/DesignTokens/tests/upstream.test.mjs` | `6f949403171e468d92bd4f39abb90bb395834857` | `6f949403171e468d92bd4f39abb90bb395834857` | exact relocated copy |
| `tests/validation.test.mjs` | `Packages/DesignTokens/tests/validation.test.mjs` | `a7c6940e0a039c748f7c8b6b69036b2f941d2a57` | `a7c6940e0a039c748f7c8b6b69036b2f941d2a57` | exact relocated copy |
| `tokens/colors.json` | `Packages/DesignTokens/tokens/colors.json` | `0d77629e00aafef8dd15d6a13cb268e874ca4365` | `0d77629e00aafef8dd15d6a13cb268e874ca4365` | exact relocated copy |
| `tokens/schema.json` | `Packages/DesignTokens/tokens/schema.json` | `43d74dea2578f74f15260b73726fd90d2ee59c13` | `43d74dea2578f74f15260b73726fd90d2ee59c13` | exact relocated copy |
| `tokens/styles.json` | `Packages/DesignTokens/tokens/styles.json` | `b15e00eeb1febfef53ac2297bab763540fbd0238` | `b15e00eeb1febfef53ac2297bab763540fbd0238` | exact relocated copy |
| `tokens/styles.schema.json` | `Packages/DesignTokens/tokens/styles.schema.json` | `a35dcf98b82b063f118449f0be4d444db120eb7d` | `a35dcf98b82b063f118449f0be4d444db120eb7d` | exact relocated copy |
| `tokens/upstream/basalt-2.1.8/LICENSE` | `Packages/DesignTokens/tokens/upstream/basalt-2.1.8/LICENSE` | `c5af5ed13f84b05481270c08ccfeb5281fec90bc` | `c5af5ed13f84b05481270c08ccfeb5281fec90bc` | exact relocated copy |
| `tokens/upstream/basalt-2.1.8/dist/index.d.ts` | `Packages/DesignTokens/tokens/upstream/basalt-2.1.8/dist/index.d.ts` | `30ccbf56007ae1c1d8107dc8519c052ac1b3e540` | `30ccbf56007ae1c1d8107dc8519c052ac1b3e540` | exact relocated copy |
| `tokens/upstream/basalt-2.1.8/dist/providers/theme.d.ts` | `Packages/DesignTokens/tokens/upstream/basalt-2.1.8/dist/providers/theme.d.ts` | `cf8960eb35428fb36e72906f3c09e7590fb4dfeb` | `cf8960eb35428fb36e72906f3c09e7590fb4dfeb` | exact relocated copy |
| `tokens/upstream/basalt-2.1.8/dist/providers/theme.js` | `Packages/DesignTokens/tokens/upstream/basalt-2.1.8/dist/providers/theme.js` | `0b42da9a2c4221932af5575b4cd0b6a20d84af17` | `0b42da9a2c4221932af5575b4cd0b6a20d84af17` | exact relocated copy |
| `tokens/upstream/basalt-2.1.8/dist/styles/tailwind.css` | `Packages/DesignTokens/tokens/upstream/basalt-2.1.8/dist/styles/tailwind.css` | `85518ec8f8d86d3b0ee3f5adc7285e0cb5e501ea` | `85518ec8f8d86d3b0ee3f5adc7285e0cb5e501ea` | exact relocated copy |
| `tokens/upstream/basalt-2.1.8/dist/styles/tokens.css` | `Packages/DesignTokens/tokens/upstream/basalt-2.1.8/dist/styles/tokens.css` | `538f00f0e3ae43a9cefae8abbbca847ec6929fdb` | `538f00f0e3ae43a9cefae8abbbca847ec6929fdb` | exact relocated copy |
| `tokens/upstream/basalt-2.1.8/manifest.json` | `Packages/DesignTokens/tokens/upstream/basalt-2.1.8/manifest.json` | `a42b08282e6c45af48fc6a8fe8a662ffaab934a5` | `a42b08282e6c45af48fc6a8fe8a662ffaab934a5` | exact relocated copy |
| `tokens/upstream/basalt-2.1.8/package.json` | `Packages/DesignTokens/tokens/upstream/basalt-2.1.8/package.json` | `1f8ac438f1b8c7ce125ccfb16ca26c764dbb7387` | `1f8ac438f1b8c7ce125ccfb16ca26c764dbb7387` | exact relocated copy |

## Deliberate provider exclusions

| Provider path | Provider blob | Reason |
| --- | --- | --- |
| `.gitignore` | `b6b70e6dec405951a03d55a608661827f26a24b8` | provider repository governance/support is not imported into target governance |
| `.githooks/pre-push` | `8c235213dcb1d76f02f649343fa2e52d08901e9e` | provider repository governance/support is not imported into target governance |
| `.github/CODEOWNERS` | `6ff60630d64fe14816bff68844ec93524d2f18c8` | provider repository governance/support is not imported into target governance |
| `.github/pull_request_template.md` | `33264c20ecfbc1bafc26ee476e5bea7e564d0c95` | provider repository governance/support is not imported into target governance |
| `.github/workflows/ci.yml` | `7f870c1982e73794fd2b551707973a0b61390b7a` | provider repository governance/support is not imported into target governance |
| `.github/workflows/review.yml` | `982fab4ad198f3d92960ba51ad144f339ab453a4` | provider repository governance/support is not imported into target governance |
| `AGENTS.md` | `51929c7de527efc03392b876676958b4e79338eb` | provider repository governance/support is not imported into target governance |
| `CLAUDE.md` | `f24d09cfcd65c4e9758d42fd45fa5f9f76c265bf` | provider repository governance/support is not imported into target governance |

## Target-side adaptations

| Target path | Baseline blob | Adaptation |
| --- | --- | --- |
| `.github/CODEOWNERS` | `ba57dda416563c976f271a051b346327b74db16a` | add only relocated provider protected-path parity while preserving every baseline rule and Owner |
| `.github/workflows/ci.yml` | `76e225262f175f1a9f6456b04e8ebed9c60747eb` | retain native macOS/external-consumer gate and add setup plus Ubuntu Tokens lane |
| `.gitignore` | `5e8d81facf909e81c0445ac87745aff04d1a62c0` | add only nested node_modules and tarball ignores |
| `docs/architecture/tech-context.md` | `866bb7f57e73b9c1d25304f22c22a9c94ef25594` | declare Tokens and DesignTokens while preserving the external NativeDesignKit edge |
| `docs/architecture/tokens/tech-context.md` | new | new target leaf mapping for nested Tokens-owned executable paths and gates |
| `docs/architecture/design-tokens/tech-context.md` | new | new target leaf mapping for the nested UI-free Swift target and gates |
| `scripts/ci/setup.sh` | new | new root wrapper that enters the nested root and invokes the exact imported provider setup |
| `Packages/DesignTokens/scripts/test-swift-local-consumer.mjs` | new | target-only disposable local-path consumer; preserved provider exact-revision fixture and harness remain byte-identical |
| `Packages/DesignTokens/scripts/check-authority.mjs` | new | fail-closed tracked-path checker for the sole editable semantic sources |
| `Packages/DesignTokens/tests/authority.test.mjs` | new | positive inventory plus duplicate-source negative fixtures across root, source, fixture and sibling-package locations |

## Invariants

- Exactly 79 rows are labeled `exact relocated copy`; together with three byte-identical `exact support copy` rows, 82 of 84 imported provider files preserve their source blob.
- The two adapted provider rows retain the v0.2.0 product/API/data contract and change only excluded-governance references or target-only verification commands.
- Generation remains limited to the ten outputs named by the accepted S100 plan; those artifacts are never editable authorities or hand-edited.
- Provider `.github/**`, hook and root agent files remain excluded, and no provider setting, credential, ref, tag or history is imported.
- PR-head and final-merge SHAs belong in the external post-merge receipt, not this tracked manifest.
