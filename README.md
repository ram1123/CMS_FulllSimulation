# Setup

```bash
git clone git@github.com:ram1123/CMS_FulllSimulation.git -b main
cd CMS_FulllSimulation
```

The main script is [GetFullSimScriptsFromMCCM.py](GetFullSimScriptsFromMCCM.py). This script automates the process of downloading, preparing, and processing CMS full detector simulation starting from gridpack.
The script performs the following tasks:
1. Download the scripts from the provided URLs.
2. Modify the downloaded scripts.
3. Parse the scripts for CMSSW version and configuration file information.
4. Generate an executable script from the configuration file.
5. Generate a JDL file  and sh for condor submission.
6. Submit the jobs using the generated JDL file.

The main script, [GetFullSimScriptsFromMCCM.py](GetFullSimScriptsFromMCCM), depends mainly on three external files. They are:

1. [ChainDownloadLinkFromMccM_dict.py](utils/ChainDownloadLinkFromMccM_dict.py) - Contains the chain name and the download link from McM. This file also serves as the bookkeeping file for the chain name and the download link.
    - When you run the main script, i.e. [GetFullSimScriptsFromMCCM.py](GetFullSimScriptsFromMCCM.py), it will use the information from this file and
       obtains the text file named [CMSSWConfigFile.txt](utils/CMSSWConfigFile.txt). This contains the basic infomration that will be used to
       to setup the full simulation script for the condor job. If you already have the configuration files,
       then just set this file properly and run without triggring to download and setup the config files. **Note:** you can also change the name of this file using command line
1. [gridpack_lists.py](utils/gridpack_lists.py) - Contains the list of gridpacks you want to generate.
1. [condor_script_template.py](utils/condor_script_template.py) - Contains the template for the condor submission script.
   Unless you are changing any condor submission parameters or workflow, you don't need to change this file.
   For proper naming convention based on gridpack file name, you may need to update the `ReplacementDict` dictionary in this file.


***NOTE:*** It would be good if you first test locally the `.sh` file obtained by this script for say 50 events. This will help you to understand the workflow and also to check if the script is working properly. Once you are satisfied with the local test, you can submit the jobs to condor. You may need to copy the CMSSW config file to the local directory.


***General Suggestations:*** Commit the cmssw configuration and the .sh script downloaded from the mccm to git. This will help you to track the changes and also to reproduce the results.

# How to run the script

- ***Step - 1:*** Prepare the [ChainDownloadLinkFromMccM_dict.py](utils/ChainDownloadLinkFromMccM_dict.py) file. Add the chain name and the download link from McM. This file also serves as the bookkeeping file for the chain name and the download link.

- ***Step - 2:*** Prepare the [gridpack_lists.py](utils/gridpack_lists.py) file. Add the list of gridpacks you want to generate.

- ***Step - 3:*** Fetch the CMSSW configuration file from the McM. Run the script [GetFullSimScriptsFromMCCM.py](GetFullSimScriptsFromMCCM.py) with the following command:

    ```bash
    python3 GetFullSimScriptsFromMCCM.py   --model HHbbgg --year 2016preVFP --run_exec --outDir /eos/user/r/rasharma/CustomNanoAOD/DY_VBF_Filter/
    ```

    Note the `model` and `year` arguments in the above command. It depends on your keys that you added in the [ChainDownloadLinkFromMccM_dict.py](utils/ChainDownloadLinkFromMccM_dict.py) and [gridpack_lists.py](utils/gridpack_lists.py) files.

- ***Step - 4:*** Edit the CMSSW configuration file.

    ```bash
    python3 GetFullSimScriptsFromMCCM.py --model HHbbgg --year 2016preVFP --NOdownload --append_to_config_file
    ```

    The `--append_to_config_file` flag automatically handles the following in the step-1 config file:

    | What | Status |
    |---|---|
    | VarParsing block (`seedval` + `gridpack` args) | **Automated** |
    | `process.MessageLogger.cerr.FwkReport.reportEvery = 500` (all steps) | **Automated** (idempotent) |
    | `input = cms.untracked.int32(options.maxEvents)` in `process.maxEvents` | **Automated** |
    | `args = cms.vstring(options.gridpack)` in `externalLHEProducer` | **Automated** |
    | `nEvents = cms.untracked.uint32(options.maxEvents)` in `externalLHEProducer` | **Automated** |
    | Seed wiring to `options.seedval` (UL: `generator.initialSeed`; Run3: `externalLHEProducer.initialSeed`) | **Automated** |
    | Commenting out any conflicting hardcoded seed line (Run3 only) | **Automated** |
    | `input = cms.untracked.int32(-1)` in all downstream step cfgs (step2 onward) | **Automated** |

    The only edit **still required manually** is for UL chains with an `annotation` string:

    1. **UL chains only** — update the `annotation` string if present:

        ```python
        # Replace:
        annotation = cms.untracked.string('...fragment.py nevts:10000'),
        # With:
        annotation = cms.untracked.string('...fragment.py nevts:'+str(options.maxEvents)),
        ```

- ***Step - 5:*** Run the script to generate the executable `.sh` and `.jdl` files.

    ```bash
    python3 GetFullSimScriptsFromMCCM.py --model HHbbgg --year 2016preVFP --NOdownload \
      --nevents 2000 --nJobs 100 \
      --outDir /eos/user/r/rasharma/post_doc_ihep/double-higgs/nanoAODnTuples/HHTobbgg_Apr2024v3 \
      --jobName 2016preVFP --UseCustomNanoAOD
    ```

    ***Run3 note:*** The generated `.jdl` sets `MY.WantOS = "el7"` by default. For Run3 chains (CMSSW 12.x / `el8` or CMSSW 13.x / `el8`/`el9`), change this to `"el8"` in the `.jdl` before submitting.

- ***Step - 6:*** Submit the jobs to condor.

    ```bash
    condor_submit <jobName>.jdl
    ```

# Few improvements or things to note

1. Directory name `ConfigFiles` is hardcoded in the script
2. The NanoAOD output step is found dynamically — the last step key containing `nano` (case-insensitive) is used. For UL 7-step chains this is `step7_NANOAOD`; for Run3 4-step chains this is `step4_NanoAOD`.
3. The `--append_to_config_file` command is idempotent — safe to run multiple times without creating duplicate lines.
