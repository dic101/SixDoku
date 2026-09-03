# docs — Vault Mirror

This folder is a **mirrored copy** of the Obsidian Vault specs for `SixDoku`, so future agents can work even if the vault isn't mounted.

- **Canonical source:** `/Users/davechow/Documents/Local/Master Vault/02-Projects/SixDoku/SixDoku - Project Home/Specs/` (edit here)
- **This mirror:** `docs/Specs/` (auto-generated)
- **Bootstrap:** `docs/OpenCodeBootstrapPrompt.md` ← `06-Templates/OpenCodeBootstrapPrompt.md.md`
- **Vault README:** `docs/README.vault.md`

## Sync
```bash
./scripts/sync-specs.sh   # vault → docs/Specs/
```

Run after any spec change in Obsidian. The script preserves domain folders (`Product/`, `Architecture/`, `Engine/`, `Cloud/`, `API/`).

## Agent Entry
Agents should start at `../AGENTS.md`, which lists all vault + repo paths and the `PDD > Architecture > API` precedence.
