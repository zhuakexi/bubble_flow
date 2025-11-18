## Purpose
Short, focused guidance for AI coding agents working on bubble_flow (a Snakemake-based HiRES/Dip-C pipeline).

## Big picture (what to know first)
- This repo is a Snakemake workflow. Entry: `workflow/Snakefile` which includes `rules/*.smk` and `rules/HiC/*` to compose the pipeline.
- High-level flow: preprocessing -> mapping -> `sam2seg` (sample_check checkpoint) -> `seg2pairs` -> `clean_pairs` -> `impute` -> `build` (3D structures). See includes in `workflow/Snakefile`.
- Configuration is centralized in `config/config.yaml` and per-sample overrides in `config/sample_table.csv`. Key config keys: `ana_home`, `global_mode` (format: ploidy_sex_snp_imputation_build), `global_ref`, and `software` (paths for hickit, bwa, star, etc.).

## Developer workflows (concrete commands)
- Dry-run to see the DAG and rules: from repo root run `snakemake -np All` (see README for example).
- Local run with conda: `snakemake --cores <N> --use-conda All`.
- Cluster example (slurm) is provided in README — copy the long example when submitting large jobs (it illustrates `--cluster` and `--conda-prefix`).
- Run single-rule targets using the `do_$RULE` convention used by the Snakefile (e.g. `snakemake --use-conda do_sam2seg`).

## Project-specific conventions and patterns
- Modes: `global_mode` is a 4-part token controlling ploidy, sex, SNP, impute and build behavior. Many rules (notably `sam2seg` and `build`) depend on this.
- Checkpoints: `rules/HiC/sample_check.smk` is used to deduce ploidy/sex; do not remove or bypass it unless you understand the downstream implications.
- Output directories: canonical names under `ana_home` are used widely: `pairs_0`, `pairs_c1`, `pairs_c12`, `pairs_c123`, `dip`, `3dg_c`, `count_matrix_{ref}`. Refer to README "Output Introduction" when mapping file targets.
- Rule scripts and Python helpers often rely on `snakemake` variables (`snakemake.config`, `snakemake.input`, `snakemake.output`, `snakemake.params`, `snakemake.wildcards`, `snakemake.log`). Example: `workflow/scripts/build.py` defines `buildW(...)` and calls `snakemake.config` and `snakemake.input`.
- External tools are expected on disk and referenced in `config/config.yaml` (`software.hickit`, `bwa`, `star`, etc.). Tests and dry-runs assume these are configured.

## Integration points & external dependencies
- External executables: `hickit` (3D building), `bwa`/`bwa_mem2`, `star`, and others — paths set in `config/config.yaml`.
- Conda environment specs live in `workflow/envs/*.yaml` and wrapper code in `wrappers/` — inspect these for runtime dependency lists.
- `hires-utils` (a separate repo) is referenced under `software.hires` in config and used by some rules.

## Files to consult when coding or modifying rules
- `workflow/Snakefile` — pipeline composition and top-level targets.
- `config/config.yaml` and `config/sample_table.csv` — configuration and sample-driven behavior.
- `rules/h.smk`, `rules/utils.smk` — shared utilities and globals used by other rules.
- `rules/HiC/*.smk` — mapping, sample_check, sam2seg, seg2pairs, clean_pairs, impute, build.
- `workflow/scripts/` — small python helpers (example: `build.py` demonstrates `snakemake.*` usage).
- `workflow/envs/` and `wrappers/` — environment and wrapper patterns for tools.

## Quick guidance for PR changes
- When adding or modifying rules, update `rules/*` and ensure the new outputs are referenced by `All` or appropriate top-level rule if needed for integration tests.
- Honor existing config keys; prefer adding new optional fields to `config/config.yaml` and documenting them in `README.md` and `config/sample_table.csv`.
- Use `snakemake -np <target>` locally to validate DAG changes before running full test jobs.

## Small contract for AI edits
- Inputs: modify rule files (`rules/*.smk`), helper scripts (`workflow/scripts/*.py`), or `config/*`.
- Outputs: pipeline must still run `snakemake -np All` without syntax errors; added rules should be referenced by a top-level target for end-to-end testing.
- Error modes: missing `software` paths or malformed `global_mode` are common causes of runtime failures — refer to `config/config.yaml` for defaults.

If any of these areas are unclear or you'd like examples added (e.g., an annotated rule edit example), tell me which part to expand.
