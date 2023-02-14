# Quick Instructions

## Getting Configuration Files from mccm

* To get the configuration files from mccm, you can use the following script: [GetCfgFile_GENToNano.sh](GetCfgFile_GENToNano.sh)
* The generated configuration files can be found here: [UL2018_ConfigFiles](UL2018_ConfigFiles)

## Submitting Condor Jobs

* The following scripts are required for submitting condor jobs:
    1.  [RunAllSteps.sh](RunAllSteps.sh)
    1. [RunAllSteps.jdl](RunAllSteps.jdl)

* If you need to submit multiple condor jobs for different gridpacks, you can use the following Python script to create jdl and sh files: [condor_setup_new.py](condor_setup_new.py)
    * This script uses a list of gridpacks defined in the following file: [gridpack_lists.py](gridpack_lists.py)
    * To run the script, simply type `python condor_setup_new.py` in your terminal.

## Merging Nano Root Files

* The following Python script can be used to hadd nano root files: [mergeOutput.py](Scripts/mergeOutput.py)
* To run the script, type `python Scripts/mergeOutput.py` in your terminal.


# General Information

1. Select one campaign. For example I choose: [https://cms-pdmv.cern.ch/mcm/requests?prepid=B2G-RunIIAutumn18NanoAODv6-01916&page=0&shown=127](https://cms-pdmv.cern.ch/mcm/requests?prepid=B2G-RunIIAutumn18NanoAODv6-01916&page=0&shown=127)

2. Go to the chains and select each chain one by one and do the following for each of them.

   1. On "Actions" click on "view chains": you will see a chain of McM processes connected by arrows and ending with your chosen NanoAOD sample.
   1. For *each* of these processes (click on them one by one), on "Actions" click on "get setup command" to get a piece of bash script - in this case 4 pieces.
   1. Save each pieced in different `<filename>_1.sh, <filename>_2.sh, <filename>_3.sh, <filename>_4.sh` files.
   1. Brief introduction of each file is given here[^intro_files].

[^intro_files]: First step is known as the GEN-SIM step. Second one is DR1 and DR2 third one will generate MINIAOD and finally the fourth one will create the NanoAOD files.

3. Now run each script one by one. First script will give you one *.py file 2nd one should give you two *.py files and third and fourth one should give you one *.py files each.

3. CMSDriver command does not add the random seed in the configuration file. So, need to append the random number generator at the end of first *.py file. So, that each time when you generate the GEN-SIM file from the gridpack it will generate independent set of events else it will just generate the same copies each time.

   patch to add random number generator:

   ```bash
   cat << EOF >> testLHE-GEN.py
   from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper
   randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)
   randSvc.populate()
   EOF
   ```

   where, `testLHE-GEN.py` is the name of first configuration file.

4. Test each python configuration one after another in appropriate sequence to check if its fine. *There might be an issue of name of input root files. The script might not taking the input of previous step automatically because of naming difference. So you need to fix it.*

5. Finally submit the condor job.

# Condor info for Lxplus

```bash
voms-proxy-init --voms cms --valid 168:00
cp /tmp/x509up_u48539 ~/. # where `x509up_u48539` is the proxy file name created by previous command
export X509_USER_PROXY=/afs/cern.ch/user/r/rasharma/x509up_u48539
```

# Condor Job Submission [obselete]

```bash
git clone git@github.com:ram1123/CMS_FulllSimulation.git
cd CMS_FulllSimulation
git submodule init
git submodule update
```

1. place all the python configuration file inside the directory `CMS_FulllSimulation`.
2. Update the `RunGENSIM_condor.jdl` and `RunGENSIM_condor.sh` files.
    1. In file `RunGENSIM_condor.sh` you need to replace the python configuration file name at appropriate places.
    1. Add the appropriate number of events and jobs. For example:
        1. If you want 50k events then you can change `Queue 50` in the jdl file and put 1000 in each python configuration files.
1. submit the condor jobs.

```bash
voms-proxy-init --voms cms --valid 168:00
condor_submit RunGENSIM_condor.jdl
```
