# Setup

```bash
git clone git@github.com:ram1123/CMS_FulllSimulation.git -b HH_bbgg
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

1. [ChainDownloadLinkFromMccM_dict.py](utils/ChainDownloadLinkFromMccM_dict.py) - Contains the chain name and the download link from McM.
    - When you run the main script, i.e. [GetFullSimScriptsFromMCCM.py](GetFullSimScriptsFromMCCM.py), it will use the information from this file and
       obtains the text file named [CMSSWConfigFile.txt](utils/CMSSWConfigFile.txt). This contains the basic infomration that will be used to
       to setup the full simulation script for the condor job. If you already have the configuration files,
       then just set this file properly and run without triggring to download and setup the config files. **Note:** you can also change the name of this file using command line
1. [gridpack_lists.py](utils/gridpack_lists.py) - Contains the list of gridpacks you want to generate.
1. [condor_script_template.py](utils/condor_script_template.py) - Contains the template for the condor submission script.
   Unless you are changing any condor submission parameters or workflow, you don't need to change this file.
   For proper naming convention based on gridpack file name, you may need to update the `ReplacementDict` dictionary in this file.

