"""
This script will ask several times the password of voms-proxy
"""
import os
import subprocess
from collections import OrderedDict

ChainDownloadLinkFromMccM_dict = OrderedDict({
    'step1_wmLHEGEN': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17wmLHEGEN-03707',
    'step2_SIM': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17SIM-03331',
    'step3_DIGI': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17DIGIPremix-03331',
    'step4_HLT': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17HLT-03331',
    'step5_RECO': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17RECO-03331',
    'step6_MINIAOD': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17MiniAODv2-03331',
    'step7_NANOAOD': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17NanoAODv9-03735'

})

def download_and_prepare_scripts(chain_dict):
    config_file_path = 'CMSSWConfigFile.txt'
    if os.path.exists(config_file_path):
        os.remove(config_file_path)

    for key, value in chain_dict.items():
        print(f'======> Start {key} <======')
        script_name = f"{key}.sh"

        # Download the script
        download_result = subprocess.run(["wget", value, "-O", script_name])
        if download_result.returncode != 0:
            print(f"Error downloading {script_name}")
            break

        # Comment out lines containing 'cd /afs' in the script
        subprocess.run(["sed", "-i", "/cd \\/afs/s/^/#/", script_name])

        # Replace 'mv' with 'cp -r' in the script
        # If the CMSSW directory already exists, so the directory named "configuration" will be there
        # In this case mv command won't work, so we need to change it to cp -r
        subprocess.run(["sed", "-i", "s/mv ../cp -r ../g", script_name])

        # Make the script executable
        subprocess.run(["chmod", "+x", script_name])

        # Run the script
        # subprocess.run([f"./{script_name}"])

        # Extracting CMSSW version and config file information
        CMSSWVersion= ''
        CMSSW_ConfigFile = ''

        # Process the script file
        with open(script_name, 'r') as file:
            script_lines = file.readlines()

        for line in script_lines:
            if 'CMSSW' in line and '-r' in line:
                # the cmssw version is after '-r' in the list like 'CMSSW_10_6_30_patch1/src'
                # so we need to get the position of '-r' in the list and get the next element
                # in the list. Split the element by '/' and get the first element
                CMSSWVersion = line.split('-r')[1].split('/')[0].strip()
            if '--python_filename' in line:
                CMSSW_ConfigFile = line.split('--python_filename')[1].split()[0].strip()

        print(f"CMSSWVersion: {CMSSWVersion}, CMSSW_ConfigFile: {CMSSW_ConfigFile}")

        # Write to configuration file
        with open(config_file_path, 'a') as f:
            f.write(f"{key},{CMSSWVersion},{CMSSW_ConfigFile}\n")

        print(f'======> Finished {key} <======')


def generate_executable_script(config_file):
    print(f"Generating executable script from {config_file}")
    cmssw_versions = {}
    cmssw_config_files = {}
    with open(config_file, 'r') as f:
        for line in f:
            step, version, cmssw_config_file = line.strip().split(',')
            print(f"step: {step}, version: {version}, cmssw_config_file: {cmssw_config_file}")
            cmssw_versions[f"step{step.split('_')[0][-1]}"] = version
            cmssw_config_files[f"step{step.split('_')[0][-1]}"] = cmssw_config_file

    print('cmssw_versions:',cmssw_versions)
    print('cmssw_config_files:',cmssw_config_files)
    with open('run_simulation.sh', 'w') as f:
        f.write("#!/bin/bash\n\n")
        f.write("echo \"Job started...\"\n")
        f.write("echo \"Starting job on \" `date`\n")
        f.write("echo \"Running on: `uname -a`\"\n")
        f.write("echo \"System software: `cat /etc/redhat-release`\"\n")
        f.write("source /cvmfs/cms.cern.ch/cmsset_default.sh\n")
        f.write("echo \"###################################################\"\n")
        f.write("echo \"#    List of Input Arguments: \"\n")
        f.write("echo \"###################################################\"\n")
        f.write("echo \"Input Arguments (Cluster ID): $1\"\n")
        f.write("echo \"Input Arguments (Proc ID): $2\"\n")
        f.write("echo \"Input Arguments (Output Dir): $3\"\n")
        f.write("echo \"Input Arguments (Gridpack with path): $4\"\n\n")

        print("Writing step1")
        for i in range(1, 8):
            step = f"step{i}"
            if step in cmssw_versions:
                print(f'Writing {step} to the script')
                # print(f"{step}={cmssw_versions[step]}")
                # print(f"{step}={cmssw_config_files[step]}")
                f.write(f"{step}={cmssw_versions[step]}\n")
                f.write(f"{step}_cfg={cmssw_config_files[step]}\n\n")

        f.write("\n")
        # Write GetConstatntPatch
        f.write(GetConstatntPatch.format(len_cfg=len(cmssw_versions)))


        f.write("\necho \"Ending job on \" `date`\n")


GetConstatntPatch = '''
seed=$((${{1}} + ${{2}}))
basePath=${{PWD}}

outDir=${{3}}
[ ! -d "${{outDir}}" ] && mkdir -p "${{outDir}}"

arch=slc7_amd64_gcc700


sed -i "s|args = cms.vstring.*|args = cms.vstring('$4'),|g" ${{step1_cfg}}  # Replace gridpack path in step1_cfg
echo "+=============================="
echo "DEBUG: Print lines having gridpack path"
grep -n "args = cms.vstring" ${{step1_cfg}}
echo "+=============================="



for i in {{1..{len_cfg}}}
do
    # Add identifer so that its easy to separate the output of different steps
    echo "================================================="
    echo "Running step - ${{i}} "
    echo "================================================="
    cmssw=step$i
    export SCRAM_ARCH=slc7_amd64_gcc700
    echo "==> PWD:  ${{PWD}}"
    echo $i,${{arch}},${{!cmssw}}
    source /cvmfs/cms.cern.ch/cmsset_default.sh
    if [ -r ${{!cmssw}}/src ] ; then
        echo release ${{!cmssw}} already exists
    else
        scram p CMSSW ${{!cmssw}}
    fi
    cd ${{!cmssw}}/src
    echo "step - ${{i}} "
    echo `pwd`
    echo ${{!cmssw}}
    echo "================================================="
    export HOME=${{PWD}}
    eval `scram runtime -sh`
    scram b
    cd -
    step_cfg_var=step${{i}}_cfg
    echo "runnning ${{!step_cfg_var}}"
    if [ $i -eq 1 ]
    then
        echo "Seed: ${{seed}}"
        cmsRun ${{!step_cfg_var}} seedval=${{seed}}
        echo "================================================="
        echo "List the root files"
        ls *.root
        echo "================================================="
    else
        echo "runnning ${{!step_cfg_var}}.py"
        cmsrelnm1=step$((i-1))
        cmsRun ${{!step_cfg_var}}.py
        echo "================================================="
        echo "List the root files"
        ls *.root
        ls -ltrh *.root
        echo "================================================="
    fi
    cd ${{basePath}}/
done


echo "cp EXO-RunIISummer20UL18NanoAODv9-01225.root ${{outDir}}/EXO-RunIISummer20UL18NanoAODv9_${{seed}}.root"
cp EXO-RunIISummer20UL18NanoAODv9-01225.root ${{outDir}}/EXO-RunIISummer20UL18NanoAODv9_${{seed}}.root
'''

download_and_prepare_scripts(ChainDownloadLinkFromMccM_dict)
generate_executable_script('CMSSWConfigFile.txt')
