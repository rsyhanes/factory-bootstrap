# One-shot generator: builds init-factory.sh from init-factory.ps1 here-string templates.
# Not part of the public bootstrap API; used to keep bash templates aligned.

$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
$ps1Path = Join-Path $scriptDir 'init-factory.ps1'
$shPath = Join-Path $scriptDir 'init-factory.sh'

$raw = [System.IO.File]::ReadAllText($ps1Path)
$pattern = '(?ms)\$([A-Za-z_][A-Za-z0-9_]*)\s*=\s*@''(.*?)''@'
$templateMatches = [regex]::Matches($raw, $pattern)
if ($templateMatches.Count -lt 10) {
    throw "Expected many templates in init-factory.ps1; found $($templateMatches.Count)"
}
Write-Host "Found $($templateMatches.Count) templates"

$preamble = @'
#!/usr/bin/env bash
# Factory bootstrap initialization (Linux/macOS bash peer of init-factory.ps1)
# Usage:
#   bash bootstrap/scripts/init-factory.sh
#   bash bootstrap/scripts/init-factory.sh --force
#   bash bootstrap/scripts/init-factory.sh -f

set -euo pipefail

FORCE=0
for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=1 ;;
    -h|--help)
      cat <<'HELP'
Factory bootstrap initialization

Usage:
  init-factory.sh [--force|-f]

Creates the minimum .factory/ runtime workspace (and optional portable agent docs).
Non-destructive by default; use --force to overwrite meaningful existing files.
HELP
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Use --help for usage." >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$BOOTSTRAP_ROOT/.." && pwd)"
FACTORY_ROOT="$REPO_ROOT/.factory"
PORTABLE_PACK_ROOT="$BOOTSTRAP_ROOT/portable-agent-pack"
PORTABLE_AGENTS_SRC="$PORTABLE_PACK_ROOT/AGENTS.md"
PORTABLE_DOCS_SRC="$PORTABLE_PACK_ROOT/docs"
PORTABLE_SKILLS_SRC="$PORTABLE_DOCS_SRC/factory/skills"
DOCS_ROOT="$REPO_ROOT/docs"
FACTORY_DOCS_ROOT="$DOCS_ROOT/factory"
FACTORY_SKILL_DOCS_ROOT="$FACTORY_DOCS_ROOT/skills"
AGENTS_FILE_PATH="$REPO_ROOT/AGENTS.md"

ensure_dir() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    mkdir -p "$path"
    echo "Created directory: $path"
  else
    echo "Directory exists: $path"
  fi
}

has_meaningful_content() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    return 1
  fi
  if grep -q '[^[:space:]]' "$path" 2>/dev/null; then
    return 0
  fi
  return 1
}

write_factory_file() {
  local path="$1"
  local content="$2"
  local exists=0
  local meaningful=0

  if [[ -f "$path" ]]; then
    exists=1
    if has_meaningful_content "$path"; then
      meaningful=1
    fi
  fi

  if [[ "$exists" -eq 1 && "$meaningful" -eq 1 && "$FORCE" -eq 0 ]]; then
    echo "Preserved existing file: $path"
    return 0
  fi

  local parent
  parent="$(dirname "$path")"
  if [[ ! -d "$parent" ]]; then
    mkdir -p "$parent"
  fi

  printf '%s' "$content" > "$path"
  if [[ -s "$path" ]]; then
    local last
    last="$(tail -c1 "$path" | od -An -t u1 | tr -d ' \n')"
    if [[ "$last" != "10" ]]; then
      printf '\n' >> "$path"
    fi
  fi

  if [[ "$exists" -eq 1 && "$FORCE" -eq 1 ]]; then
    echo "Overwrote file: $path"
  elif [[ "$exists" -eq 1 ]]; then
    echo "Filled empty file: $path"
  else
    echo "Created file: $path"
  fi
}

write_from_source() {
  local source_path="$1"
  local dest_path="$2"
  if [[ ! -f "$source_path" ]]; then
    echo "Warning: Template source missing: $source_path" >&2
    return 0
  fi
  local content
  content="$(cat "$source_path")"
  write_factory_file "$dest_path" "$content"
}

'@

$postamble = @'

ensure_dir "$FACTORY_ROOT"
ensure_dir "$FACTORY_ROOT/cartographer"
ensure_dir "$FACTORY_ROOT/refinery"
ensure_dir "$FACTORY_ROOT/foundry"
ensure_dir "$FACTORY_ROOT/foundry/adr"
ensure_dir "$FACTORY_ROOT/planner"
ensure_dir "$FACTORY_ROOT/assembler"
ensure_dir "$FACTORY_ROOT/validator"
ensure_dir "$FACTORY_ROOT/controller"

if [[ -d "$PORTABLE_DOCS_SRC" || -d "$PORTABLE_SKILLS_SRC" || -f "$PORTABLE_AGENTS_SRC" ]]; then
  ensure_dir "$DOCS_ROOT"
  ensure_dir "$FACTORY_DOCS_ROOT"
  ensure_dir "$FACTORY_SKILL_DOCS_ROOT"
fi

write_factory_file "$FACTORY_ROOT/init.md" "$initContract"
write_factory_file "$FACTORY_ROOT/prd.md" "$prdTemplate"
write_factory_file "$FACTORY_ROOT/state.md" "$stateTemplate"
write_factory_file "$FACTORY_ROOT/cartographer/system-spec.md" "$cartographerSystemSpecTemplate"
write_factory_file "$FACTORY_ROOT/cartographer/behavior-catalog.md" "$cartographerBehaviorCatalogTemplate"
write_factory_file "$FACTORY_ROOT/cartographer/integration-map.md" "$cartographerIntegrationMapTemplate"
write_factory_file "$FACTORY_ROOT/cartographer/parity-risks.md" "$cartographerParityRisksTemplate"
write_factory_file "$FACTORY_ROOT/refinery/spec.md" "$refinerySpecTemplate"
write_factory_file "$FACTORY_ROOT/foundry/design.md" "$foundryDesignTemplate"
write_factory_file "$FACTORY_ROOT/foundry/system-context.md" "$foundrySystemContextTemplate"
write_factory_file "$FACTORY_ROOT/foundry/container-view.md" "$foundryContainerViewTemplate"
write_factory_file "$FACTORY_ROOT/foundry/component-views.md" "$foundryComponentViewsTemplate"
write_factory_file "$FACTORY_ROOT/foundry/adr/index.md" "$foundryAdrIndexTemplate"
write_factory_file "$FACTORY_ROOT/planner/work-orders.md" "$workOrdersTemplate"
write_factory_file "$FACTORY_ROOT/planner/validation-plan.md" "$validationPlanTemplate"
write_factory_file "$FACTORY_ROOT/assembler/execution-log.md" "$executionLogTemplate"
write_factory_file "$FACTORY_ROOT/assembler/change-summary.md" "$changeSummaryTemplate"
write_factory_file "$FACTORY_ROOT/validator/verification-report.md" "$verificationReportTemplate"
write_factory_file "$FACTORY_ROOT/controller/report.md" "$controllerReportTemplate"

if [[ -d "$PORTABLE_DOCS_SRC" || -d "$PORTABLE_SKILLS_SRC" || -f "$PORTABLE_AGENTS_SRC" ]]; then
  write_from_source "$PORTABLE_AGENTS_SRC" "$AGENTS_FILE_PATH"
  # Pack layout: docs/operating-model.md, docs/foundry-c4-authoring-standard.md, docs/factory/skills/*.md
  write_from_source "$PORTABLE_DOCS_SRC/operating-model.md" "$FACTORY_DOCS_ROOT/operating-model.md"
  write_from_source "$PORTABLE_DOCS_SRC/foundry-c4-authoring-standard.md" "$FACTORY_DOCS_ROOT/foundry-c4-authoring-standard.md"

  for skillName in Cartographer Refinery Foundry Planner Assembler Validator Controller; do
    write_from_source "$PORTABLE_SKILLS_SRC/${skillName}.md" "$FACTORY_SKILL_DOCS_ROOT/${skillName}.md"
  done

  echo "Portable Factory agent reference docs emitted under docs/factory/."
else
  echo "Portable Factory agent pack not found; skipped docs/factory/ emission."
fi

echo ""
echo "Factory initialization completed."
if [[ "$FORCE" -eq 1 ]]; then
  echo "Mode: force overwrite enabled for existing meaningful files."
else
  echo "Mode: non-destructive; existing meaningful files were preserved."
fi
'@

$parts = New-Object System.Collections.Generic.List[string]
$parts.Add($preamble)

foreach ($m in $templateMatches) {
    $name = $m.Groups[1].Value
    $body = $m.Groups[2].Value
    $body = $body -replace "`r`n", "`n" -replace "`r", "`n"

    if ($name -eq 'initContract') {
        $oldList = @'
- Canonical framework-repository bootstrap script: `bootstrap/scripts/init-factory.ps1`

In the current script-driven workflow, users may:

1. copy the `bootstrap/` folder into the target repository
2. run `bootstrap/scripts/init-factory.ps1`
3. verify the emitted `/.factory/` runtime workspace and any local reference docs
4. delete the copied `bootstrap/` folder if it is no longer needed
'@
        $newList = @'
- Canonical framework-repository bootstrap scripts:
  - `bootstrap/scripts/init-factory.ps1` (Windows PowerShell)
  - `bootstrap/scripts/init-factory.sh` (Linux/macOS bash)

In the current script-driven workflow, users may:

1. copy the `bootstrap/` folder into the target repository
2. run `bootstrap/scripts/init-factory.ps1` (Windows) or `bootstrap/scripts/init-factory.sh` (Linux/macOS)
3. verify the emitted `/.factory/` runtime workspace and any local reference docs
4. delete the copied `bootstrap/` folder if it is no longer needed
'@
        if ($body.Contains('bootstrap/scripts/init-factory.ps1') -and -not $body.Contains('init-factory.sh')) {
            $body = $body.Replace($oldList.TrimEnd(), $newList.TrimEnd())
            # Fallback if whitespace differs: simple dual mention
            if (-not $body.Contains('init-factory.sh')) {
                $body = $body.Replace(
                    'bootstrap/scripts/init-factory.ps1',
                    'bootstrap/scripts/init-factory.ps1 (Windows) or bootstrap/scripts/init-factory.sh (Linux/macOS)'
                )
            }
        }
    }

    $eof = "EOF_$name"
    if ($body -match "(?m)^$([regex]::Escape($eof))$") {
        throw "EOF collision for $name"
    }

    $block = "$name=`$(cat <<'$eof'`n" + $body.TrimEnd("`n") + "`n$eof`n)`n"
    $parts.Add($block)
}

$parts.Add($postamble)

$out = ($parts -join "`n") -replace "`r`n", "`n" -replace "`r", "`n"
if (-not $out.EndsWith("`n")) { $out += "`n" }
[System.IO.File]::WriteAllText($shPath, $out, [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $shPath ($((Get-Item $shPath).Length) bytes)"
