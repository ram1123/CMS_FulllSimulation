# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository automates CMS full detector simulation for resonant HH analyses (HH→bbγγ with Radion/Bulk Graviton resonances) and aTGC/SMEFT samples. It runs a 7-step simulation chain (wmLHEGEN → SIM → DIGI → HLT → RECO → MINIAOD → NANOAOD) starting from gridpacks, producing NanoAOD output via HTCondor on lxplus.

## Key Script: GetFullSimScriptsFromMCCM.py

The main entry point. Run it in three phases for each model+year:

**Phase 1 – Download CMSSW configs from McM and run them locally to get config files:**
```bash
python3 GetFullSimScriptsFromMCCM.py --model HHbbgg_Graviton --year 2016preVFP \
  --outDir /eos/user/r/rasharma/... --nJobs 50 --jobName Graviton_HHbbgg_UL2016preVFP \
  --UseCustomNanoAOD --run_exec
```

**Phase 2 – Apply automated edits to config files (seed, gridpack arg, message logger):**
```bash
python3 GetFullSimScriptsFromMCCM.py --model HHbbgg_Graviton --year 2016preVFP \
  --outDir /eos/user/r/rasharma/... --nJobs 50 --jobName Graviton_HHbbgg_UL2016preVFP \
  --UseCustomNanoAOD --NOdownload --append_to_config_file
```
After this phase, some edits still require **manual intervention** in the step1 wmLHE config file (see README.md for details: `options.maxEvents`, gridpack `args`, `nEvents`).

**Phase 3 – Generate condor `.sh` and `.jdl` files, then submit:**
```bash
python3 GetFullSimScriptsFromMCCM.py --model HHbbgg_Graviton --year 2016preVFP \
  --outDir /eos/user/r/rasharma/... --nJobs 50 --jobName Graviton_HHbbgg_UL2016preVFP \
  --UseCustomNanoAOD --NOdownload

condor_submit Graviton_HHbbgg_UL2016preVFP.jdl
```

## Configuration Files to Edit When Adding New Samples

1. **[utils/ChainDownloadLinkFromMccM_dict.py](utils/ChainDownloadLinkFromMccM_dict.py)** – Add the McM download URLs for each simulation step, keyed by `model` → `year` → `step_name`. The `step_name` keys must use the pattern `stepN_<TIER>` (e.g. `step1_wmLHEGEN`, `step7_NANOAOD`).

2. **[utils/gridpack_lists.py](utils/gridpack_lists.py)** – Add the list of gridpack paths (on `/cvmfs` or `/eos`) under the corresponding model key. These must match the `--model` argument.

3. **[utils/condor_script_template.py](utils/condor_script_template.py)** – Only touch this when changing condor submission parameters. Update `ReplacementDict` if new gridpack naming conventions need to be stripped for output directory naming.

## Important Constraints

- The `ConfigFiles/` directory name is hardcoded in the main script; do not rename it.
- `step7_NANOAOD` must be present as a key in the chain dict — the JDL generator reads the `fileout` from it to determine the output ROOT file name.
- `--UseCustomNanoAOD` upgrades step7 from `CMSSW_10_6_26` to `CMSSW_10_6_30` and merges `ram1123:CMSSW_10_6_30_HHWWgg_nanoV9`.
- The seed is computed as `ClusterID + ProcID` inside the condor job; the step1 config must accept `seedval` as a VarParsing argument.
- Condor jobs request 12 GB RAM and 8 CPUs; jobs run on `el7` via Singularity image on AlmaLinux9 nodes.

## Grid Proxy Setup (required before submission)

```bash
voms-proxy-init --voms cms --valid 168:00
cp /tmp/x509up_u<UID> ~/
export X509_USER_PROXY=~/x509up_u<UID>
```

## aTGC/SMEFT Setup

The `aTGC_AnkitaSetup/` directory contains independent per-year condor submission setups (`.sub` + `.sh` files) for aTGC/SMEFT samples. These are not driven by `GetFullSimScriptsFromMCCM.py`; they are manually maintained condor scripts. The step7 config for aTGC merges `ram1123:aTGC_VV_reweight_CMSSW100626`.

## Output Merging

`Scripts/mergeOutput.py` and `Scripts/haddnano.py` are used to merge per-job NanoAOD ROOT files after condor jobs complete.
