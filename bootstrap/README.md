# Bootstrap Zone

This directory contains the **bootstrap layer** of The Factory:

- bootstrap contracts
- bootstrap implementation scripts
- portable agent-pack source files emitted into initialized target repositories

Use this zone when the question is **how a target repository gets initialized**.

For the current script-driven workflow:

1. copy the entire `bootstrap/` folder into the target repo
2. run the platform bootstrap script:
   - **Windows:** `bootstrap/scripts/init-factory.ps1`
   - **Linux/macOS:** `bash bootstrap/scripts/init-factory.sh` (or `./bootstrap/scripts/init-factory.sh` after `chmod +x`)
3. verify `AGENTS.md`, `/.factory/`, and any emitted `/docs/factory/` outputs
4. optionally delete the copied `bootstrap/` folder

Both scripts implement the same bootstrap contract (`bootstrap/contracts/bootstrap-init-contract.md`): non-destructive by default, optional `--force` / `-Force` overwrite, and optional portable agent-pack emission when present.

When template content in `init-factory.ps1` changes, regenerate the bash peer with:

```powershell
powershell -File bootstrap/scripts/_generate-init-factory-sh.ps1
```
