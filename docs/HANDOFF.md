# 6Doku — Handoff — 2026-09-04

**Repo:** `https://github.com/dic101/SixDoku` (`main` `b4adb95`, pushed, clean) — single `project.yml` + `xcodegen`, Dev `iCloud.com.sixdoku.dev`
**Store:** App Store Connect record **6Doku** ("SixDoku" taken), bundles `com.sixdoku.app` / `com.sixdoku.app.watch`
**Release:** **1.0 (1)** uploaded to TestFlight (`141cbf1` + distro fix `1b6cd1f`); GitHub README live

## State Now
- `swift test` **23/23 (7 suites)** — Solver/Validator/Generator/BoxMapping/SeedCatalog/UserStatsSync/Theme
- iOS + watchOS device builds **SUCCEED**; installed + launched on iPhone 17 sim, Watch 46mm sim, physical iPhone 15 Pro + Watch Series 10
- Engine: 6×6 dual 2×3/3×2, 48-puzzle deterministic seed catalog (`SeedCatalog.json` bundled, `SeedGenerator` tool, `scripts/seed-catalog.sh`, in-app public-DB uploader in Settings)
- Sync: `PuzzleState`/`UserStats` private DB (fetch-modify-save, offline queue), `UserStats.themePreference` carries grid theme iOS↔watch
- Themes (6): Classic/Midnight/High Contrast/Volt/Ember/Cobalt — picker in iOS Settings, watch grid + picker + iOS grid all themed
- Watch input: board-reset bug fixed (puzzle generated once per tap), full-page 3×2 picker + Erase, black-tile givens, box-band gaps
- Polish: 1024 AppIcon + catalogs (`Tools/MakeIcon`), `UILaunchScreen`, VoiceOver audit (cell labels, pad hints, move/completion announcements)
- Signing: team `S332V7BC69` pinned in `project.yml`; frameworks carry `MARKETING_VERSION`; `UIRequiresFullScreen` set (iPad orientation distro error fixed)

## How to Resume
1. `cat AGENTS.md` → vault bootstrap + `Specs/**/*.md` (or `docs/Specs/` fallback), `PDD > Architecture > API`
2. `xcodegen generate` after any file add or `project.yml` change (it also rewrites `Info.plist` from `info.properties` — never hand-edit plists)
3. `swift test` (23) + device builds with `-allowProvisioningUpdates`; **never run two builds/tests in parallel** (shared `build.db` lock)
4. Watch physical installs **only stick via Xcode Run** (scheme `SixDokuWatch` → real watch); direct `devicectl` installs get reconciled away. Watch needs Developer Mode ON + awake screen for tunnel
5. `./scripts/sync-specs.sh` after vault spec edits

## Next
- TestFlight: schema already deployed to Production by user; internal tester installs in progress — verify phone↔watch sync + theme propagation on prod builds
- Per-upload: bump `CFBundleVersion` in `project.yml`, regenerate, archive fresh (never re-distribute a stale archive)
- Post-MVP per `iOSRoadmap.md.md:1`: daily puzzle, achievements; README wants screenshots + license decision

## Known Issues / Notes
- `.build/build.db: disk I/O error` transient from SPM, harmless; `simctl launch` hanging → reboot that sim device
- Instantiating `CloudKitService()` in `swift test` host traps runner → `UserStatsSyncing` protocol + actor stub (`ThemeTests.swift`)
- `.foregroundStyle(cond ? .primary : .blue)` mixes style types → cascade errors misblamed on `ForEach`; always qualify (`Color.primary`)
- Display/scheme/target internals still say "SixDoku" in places (struct/file/scheme names) — user-visible strings are 6Doku

## Logs
- Vault: `01-Daily/2026-09-04.md` (session), `01-Daily/2026-09-02.md:1`, Project Home README status section
- Repo: `docs/DIARY_2026-09-02_Session.md:1`, `docs/PLAN.md` (COMPLETED), plan `~/.claude/plans/effervescent-painting-arya-agent-a1fad010224fa4aa8.md`

---
*Stop: 2026-09-04 — tree clean @ `b4adb95`, next session start here + vault daily note*
