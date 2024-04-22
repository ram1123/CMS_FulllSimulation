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
    python3 GetFullSimScriptsFromMCCM.py --nevents 2000  --model HHbbgg --year 2016preVFP --outDir /eos/user/r/rasharma/post_doc_ihep/double-higgs/nanoAODnTuples/HHTobbgg_Apr2024v3 --nJobs 100 --jobName 2016preVFP --UseCustomNanoAOD --run_exec
    ```

    Note the `model` and `year` arguments in the above command. It depends on your keys that you added in the [ChainDownloadLinkFromMccM_dict.py](utils/ChainDownloadLinkFromMccM_dict.py) and [gridpack_lists.py](utils/gridpack_lists.py) files.

- ***Step - 4:*** Edit the CMSSW configuration file.

    ```bash
    python3 GetFullSimScriptsFromMCCM.py --nevents 2000  --model HHbbgg --year 2016preVFP --outDir /eos/user/r/rasharma/post_doc_ihep/double-higgs/nanoAODnTuples/HHTobbgg_Apr2024v3 --nJobs 100 --jobName 2016preVFP --UseCustomNanoAOD --NOdownload --append_to_config_file
    ```

    1. step-1 config file (wmLHE config file): ***Done by above command***
       - Here you need to add the input arguments for the additional input arguments for seed value, and gridpack file

            ```python
            from FWCore.ParameterSet.VarParsing import VarParsing
            options = VarParsing ('analysis')
            options.register ('seedval',
                        1238,
                        VarParsing.multiplicity.singleton,
                        VarParsing.varType.int,
                        "random seed for event generation")
            options.register ('gridpack',
                        '',
                        VarParsing.multiplicity.singleton,
                        VarParsing.varType.string,
                        "gridpack with path")
            options.parseArguments()
            ```

        - Add the message logger ***Done by above command***

            ```python
            process.MessageLogger.cerr.FwkReport.reportEvery = cms.untracked.int32(500)
            ```

        - Update the number of input events to be generated. Replace line: ***Do this manually, only in wmLHE file***

            ```python
            input = cms.untracked.int32(10000)
            ```

            with

            ```python
            input = cms.untracked.int32(options.maxEvents)
            ```

            ***Note:*** The number of events is already updated in the first step, just set the number of events to be generated to -1 in the subsequent steps.

        - Update the gridpack path. Replace line:  ***Do this manually, only in wmLHE file***

            ```python
            annotation = cms.untracked.string('Configuration/GenProduction/python/HIG-RunIISummer20UL16wmLHEGENAPV-03448-fragment.py nevts:10000'),
            ```

            with

            ```python
            annotation = cms.untracked.string('Configuration/GenProduction/python/HIG-RunIISummer20UL16wmLHEGENAPV-03448-fragment.py nevts:'+str(options.maxEvents),
            ```

        - Update the gridpack path. Replace line:  ***Do this manually, only in wmLHE file***

            ```python
            args = cms.vstring('/cvmfs/cms.cern.ch/phys_generator/gridpacks/UL/13TeV/madgraph/V5_2.6.5/GF_Spin_0/Radion_hh_narrow_M2000/v1/Radion_hh_narrow_M2000_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz'),
            ```

            with

            ```python
            args = cms.vstring(options.gridpack),
            ```

        - Update the number of events in the gripack generation passage. Replace line:  ***Do this manually, only in wmLHE file***

            ```python
            nEvents = cms.untracked.uint32(10000),
            ```

            with

            ```python
            nEvents = cms.untracked.uint32(options.maxEvents),
            ```

        - Update the random seed value. Add line: ***Done by above command***

            ```python
            process.RandomNumberGeneratorService.externalLHEProducer.initialSeed=options.seedval
            ```
            after line:

            ```python
            process = addMonitoring(process)
            ```

- ***Step - 5:*** Run the script to generate the executable script and JDL file.

    ```bash
    python3 GetFullSimScriptsFromMCCM.py --nevents 2000  --model HHbbgg --year 2016preVFP --outDir /eos/user/r/rasharma/post_doc_ihep/double-higgs/nanoAODnTuples/HHTobbgg_Apr2024v3 --nJobs 100 --jobName 2016preVFP --UseCustomNanoAOD --NOdownload
    ```

- ***Step - 6:*** Submit the jobs to condor.

    ```bash
    condor_submit UL2016postVFP.jdl
    ```

# Few improvements or things to note

1. Directory name `ConfigFiles` is hardcoded in the script
