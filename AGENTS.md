# AGENTS.md

Agent guidance for `/home/alistair/configuration`.

This repository is a NixOS flake for the `tiefenbacher` host.
Most changes are made in `configuration.nix`, `services/*.nix`, `modules/*.nix`, `overlays/*.nix`, and `pkgs/**/*.nix`.

## Scope

- Primary stack: Nix, NixOS modules, overlays, package expressions.
- Flake entrypoint: `flake.nix`.
- Main host configuration: `configuration.nix`.
- Service definitions live in `services/`.
- Reusable module options live in `modules/`.
- Custom package and overlay code lives in `pkgs/` and `overlays/`.

## Rule Files

- No `.cursorrules` file is present.
- No files were found in `.cursor/rules/`.
- No `.github/copilot-instructions.md` file is present.
- If any of those files are added later, treat them as higher-priority repository instructions and merge them into this document.

## Repo Layout

- `flake.nix`: defines `nixosConfigurations.tiefenbacher`.
- `configuration.nix`: top-level imports, packages, global settings, and shared services.
- `hardware-configuration.nix`: generated hardware config; edit only when hardware settings genuinely change.
- `services/*.nix`: one service per file where practical.
- `modules/*.nix`: custom option schemas and reusable module logic.
- `overlays/*.nix`: package overrides and custom derivations.
- `pkgs/python/*.nix`: Python packages.
- `pkgs/home-assistant/*.nix`: Home Assistant custom components.

## Build And Evaluation Commands

Run commands from the repo root: `/home/alistair/configuration`.

- Evaluate the flake without building: `nix flake check --no-build`
- Show available flake outputs: `nix flake show`
- Dry-run the system build: `nix build .#nixosConfigurations.tiefenbacher.config.system.build.toplevel --dry-run`
- Build the full system closure: `nix build .#nixosConfigurations.tiefenbacher.config.system.build.toplevel`
- Switch the local machine to this config: `sudo nixos-rebuild switch --flake .#tiefenbacher`
- Build without switching: `sudo nixos-rebuild build --flake .#tiefenbacher`
- Boot the next generation without switching now: `sudo nixos-rebuild boot --flake .#tiefenbacher`

## Lint And Formatting Commands

- Preferred formatter in this repo: `nixfmt-tree`
- Format the repo if `nixfmt-tree` is installed: `nixfmt-tree`
- If it is not on `PATH`, use: `nix shell nixpkgs#nixfmt-tree -c nixfmt-tree`
- Re-run `nix flake check --no-build` after formatting to catch evaluation regressions.
- There is no dedicated repo-local `statix`, `deadnix`, `treefmt`, `just`, `make`, or pre-commit config checked in today.
- If you introduce a new lint tool, document it here and keep commands reproducible from a clean machine.

## Test Commands

There is no standalone unit-test suite checked into this repository today.
The main validation loop is evaluation plus building the relevant derivation.

- Fastest broad validation: `nix flake check --no-build`
- Stronger validation for the whole host: `nix build .#nixosConfigurations.tiefenbacher.config.system.build.toplevel`
- Runtime activation validation: `sudo nixos-rebuild test --flake .#tiefenbacher`

## Running A Single Test Or Narrow Check

Because this repo is mostly NixOS configuration, a "single test" usually means evaluating or building one target instead of the full system.

- Evaluate one file for syntax with context: `nix-instantiate --parse services/adguard.nix`
- Evaluate the full host after editing one module: `nix flake check --no-build`
- Build only the top-level system derivation: `nix build .#nixosConfigurations.tiefenbacher.config.system.build.toplevel`
- Build one custom package directly when working in `pkgs/` or `overlays/`: `nix build -f . '<attr>'`
- Inspect one option on the current host: `nixos-option services.<name>.enable`
- Search option names before wiring a module: `nixos-option | rg '<term>'`

Practical examples:

- Single service edit: change `services/freshrss.nix`, then run `nix flake check --no-build`
- Overlay/package edit: change `pkgs/python/msmart-ng.nix`, then build the package attribute you touched if it is exposed
- Risky system-wide edit: run both `nix flake check --no-build` and `nix build .#nixosConfigurations.tiefenbacher.config.system.build.toplevel`

## Editing Expectations

- Preserve the existing flake structure unless there is a strong reason to refactor it.
- Prefer small, isolated module files over growing `configuration.nix` indefinitely.
- Keep service-specific nginx wiring close to the service definition when the repo already follows that pattern.
- Keep shared host-wide settings in `configuration.nix`.
- Do not edit `hardware-configuration.nix` casually.

## Imports And Module Structure

- Use a standard module header such as `{ config, pkgs, lib, ... }:` and include only needed arguments.
- Keep `imports = [ ... ];` lists one path per line.
- Prefer a `let ... in { ... }` structure when deriving local names like `fqdn`, `port`, `dir`, or generated config files.
- Use `inherit (...)` when re-exporting a small set of existing attributes.
- For reusable modules, declare options under `options` and runtime behavior under `config`.
- Gate optional module behavior with `lib.mkIf`.

## Formatting Style

- Default to 2-space indentation.
- Use trailing semicolons consistently.
- Keep attribute sets and lists multi-line once they stop being trivially short.
- Prefer one logical declaration per line.
- Align style with the surrounding file before introducing a new pattern.
- Avoid large whitespace-only rewrites unless the user asks for formatting cleanup.

## Naming Conventions

- File names are lowercase with underscores only when needed to match existing names, for example `home_assistant.nix`.
- Service file names should match the service they configure.
- Local `let` bindings should be short and descriptive, e.g. `fqdn`, `port`, `dir`, `cfg`, `configFile`.
- Option names in custom modules should be explicit and typed.
- Use existing shared names like `config.services.globalVars.domain` and `config.services.globalVars.dataDir` instead of inventing near-duplicates.

## Types And Option Definitions

- In custom modules, always use `mkOption` or `mkEnableOption` instead of raw ad hoc attributes.
- Pick the narrowest reasonable type from `lib.types` such as `types.port`, `types.path`, `types.bool`, `types.str`, or `types.package`.
- Provide sensible defaults when the module should be easy to enable.
- Use nullable types only when `null` is an intentional valid state.
- Prefer explicit `default = { };` or `default = [ ];` for optional collections.

## Packages And Overlays

- Keep custom derivations minimal and reproducible.
- Pin upstream sources with explicit `rev`/`version` and `sha256`.
- For Python packages, follow the existing pattern: `buildPythonPackage rec { ... }` with `pythonImportsCheck` when possible.
- If checks are disabled with `doCheck = false;`, do it deliberately and avoid adding it by default without a reason.
- Add `meta` when useful, especially for custom packages that may be reused.
- Overlays should stay focused on package construction, not unrelated system configuration.

## Error Handling And Safety

- Prefer typed module options, `mkIf`, and option defaults over brittle stringly-typed logic.
- Use assertions when a module has a hard prerequisite that should fail loudly.
- Do not hardcode secrets in committed Nix files.
- Prefer secret files, generated files, or external secret management for passwords, API keys, and credentials.
- Treat placeholder secrets already in the repo as technical debt, not as a pattern to copy.
- Be careful with stateful services; changing ports, data directories, or package major versions can be disruptive.

## Service Configuration Conventions

- Use `config.networking.fqdn` or `config.services.globalVars.domain` for hostnames rather than duplicating domains manually.
- Keep reverse proxy definitions near the backend service.
- When exposing a service through nginx, match the existing style: set `forceSSL = true;`, `enableACME = true;`, and `acmeRoot = null;` where appropriate.
- Prefer localhost proxy targets for internal services.
- Reuse `config.services.globalVars.containerDir`, `dataDir`, and related shared paths.

## Commenting Guidelines

- Keep comments sparse and useful.
- Comment non-obvious workarounds, version pin rationale, or upstream quirks.
- Do not add comments that restate obvious Nix syntax.
- Preserve existing comments that explain operational context.

## What To Verify Before Finishing

- If you changed any Nix file, run at least `nix flake check --no-build`.
- If you changed package definitions or overlays, also run the narrowest relevant `nix build`.
- If you changed system-level behavior, prefer validating the full toplevel build.
- Mention evaluation warnings in your handoff if they are unrelated to your change.
- Do not silently fix unrelated warnings or unrelated dirty-worktree changes unless asked.

## Current Known Notes

- `nix flake check --no-build` currently evaluates successfully but emits warnings about a legacy Nextcloud install and a renamed `system` field.
- The git worktree may already contain unrelated user edits; inspect before changing shared files.
- There is no existing `AGENTS.md` prior to this file.
