"""
This script will ask several times the password of voms-proxy
"""
import os
import subprocess
from collections import OrderedDict
import logging
import argparse

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Consider loading these from a configuration file
ChainDownloadLinkFromMccM_dict = OrderedDict({
    'step1_wmLHEGEN': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17wmLHEGEN-03707',
    'step2_SIM': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17SIM-03331',
    'step3_DIGI': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17DIGIPremix-03331',
    'step4_HLT': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17HLT-03331',
    'step5_RECO': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17RECO-03331',
    'step6_MINIAOD': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17MiniAODv2-03331',
    'step7_NANOAOD': 'https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_setup/HIG-RunIISummer20UL17NanoAODv9-03735'
})

def run_subprocess(command: list, task_description: str) -> subprocess.CompletedProcess:
    """Execute a subprocess command and handle errors."""
    try:
        result = subprocess.run(command, check=True)
        logging.info(f'Successfully completed {task_description}')
        return result
    except subprocess.CalledProcessError as e:
        logging.error(f'Error during {task_description}: {e}')
        raise

def download_script(url: str, script_name: str):
    """Download a script from a given URL."""
    if not url_validator(url):
        logging.error(f'Invalid URL: {url}')
        return
    logging.info(f'Downloading {script_name}')
    run_subprocess(["wget", url, "-O", script_name], f'downloading {script_name}')

def modify_script(script_name: str):
    """Perform sed modifications on the script."""
    if not os.path.exists(script_name):
        logging.error(f'Script not found: {script_name}')
        return
    run_subprocess(["sed", "-i", "/cd \\/afs/s/^/#/", script_name], 'commenting out cd /afs')
    run_subprocess(["sed", "-i", "s/mv ../cp -r ../g", script_name], 'replacing mv with cp -r')
    run_subprocess(["chmod", "+x", script_name], 'making script executable')

def parse_script_for_config(script_name: str, config_file_path: str):
    """Extract CMSSW version and config file information from a script."""
    with open(script_name, 'r') as file:
        for line in file:
            if 'CMSSW' in line and '-r' in line:
                CMSSWVersion = line.split('-r')[1].split('/')[0].strip()
            if '--python_filename' in line:
                CMSSW_ConfigFile = line.split('--python_filename')[1].split()[0].strip()

        with open(config_file_path, 'a') as f:
            f.write(f"{script_name},{CMSSWVersion},{CMSSW_ConfigFile}\n")

def generate_executable_script(config_file: str):
    print(f"Generating executable script from {config_file}")
    cmssw_versions = {}
    cmssw_config_files = {}
    with open(config_file, 'r') as f:
        for line in f:
            step, version, cmssw_config_file = line.strip().split(',')
            cmssw_versions[f"step{step.split('_')[0][-1]}"] = version
            cmssw_config_files[f"step{step.split('_')[0][-1]}"] = cmssw_config_file

    with open('run_simulation.sh', 'w') as f:
        f.write(build_bash_script(cmssw_versions, cmssw_config_files))

def build_bash_script(versions: dict, config_files: dict) -> str:
    """
    Constructs the bash script content based on the provided CMSSW versions and configuration files.
    """
    script_content = f"""#!/bin/bash

echo "Job started..."
echo "Starting job on " $(date)
echo "Running on: $(uname -a)"
echo "System software: $(cat /etc/redhat-release)"
source /cvmfs/cms.cern.ch/cmsset_default.sh
echo "###################################################"
echo "#    List of Input Arguments: "
echo "###################################################"
echo "Input Arguments (Cluster ID): $1"
echo "Input Arguments (Proc ID): $2"
echo "Input Arguments (Output Dir): $3"
echo "Input Arguments (Gridpack with path): $4"
echo "Input Arguments (maxEvents): $5"
echo ""

# Setting up CMSSW versions and configuration files
"""

    # Adding CMSSW version and config file information
    for step, version in versions.items():
        config_file = config_files.get(step, "default_config.py")
        script_content += f"{step}={version}\n"
        script_content += f"{step}_cfg={config_file}\n"

    script_content += "\nseed=$(($1 + $2))\n\n"  # Seed value calculation

    # Dynamically build the rest of the script
    # Example: Loop over the steps and perform operations
    for i in range(1, len(versions) + 1):
        step = f"step{i}"
        script_content += 'echo "###################################################"\n'
        script_content += f"echo \"Running {step}...\"\n"
        script_content += f"if [ -r ${{{step}}}/src ] ; then\n"
        script_content += f"    echo release ${{{step}}} already exists\n"
        script_content += f"else\n"
        script_content += f"    scram p CMSSW ${{{step}}}\n"
        script_content += f"fi\n"
        script_content += f"cd ${{{step}}}/src\n"
        script_content += f"eval `scram runtime -sh`\n"
        script_content += f"scram b\n"
        script_content += f"cd -\n"
        if i == 1:
            # Special handling for step 1 with seed value
            script_content += f"cmsRun ${{{step}_cfg}} seedval=${{seed}} maxEvents=${{5}} gridpack=${{4}}\n"
        else:
            script_content += f"cmsRun ${{{step}_cfg}}\n"
        # script_content += "cd -\n"

    script_content += "\necho \"Job finished\"\n"

    return script_content

def download_and_prepare_scripts(chain_dict: OrderedDict, args: argparse.Namespace):
    """Download and prepare scripts from the provided dictionary."""
    config_file_path = 'CMSSWConfigFile.txt'
    if os.path.exists(config_file_path):
        os.remove(config_file_path)

    for key, value in chain_dict.items():
        logging.info(f'Starting {key}')
        script_name = f"{key}.sh"
        if args.NOdownload:
            logging.info(f'Skipping download of {key}')
        else:
            download_script(value, script_name)
        modify_script(script_name)
        parse_script_for_config(script_name, config_file_path)

        if args.run_exec:
            run_subprocess(["./" + script_name], f'running {script_name}')

        logging.info(f'Finished {key}')

def url_validator(url: str) -> bool:
    """Validate the URL (basic validation)."""
    # Implement URL validation logic
    return True

def parse_arguments():
    parser = argparse.ArgumentParser(description='Script to automate CMSSW script processing')
    parser.add_argument('--nevents', type=int, default=100, help='Number of events to process')
    parser.add_argument('--run_exec', action='store_true', help='Run the executable script after creation')
    parser.add_argument('--NOdownload', action='store_true', help='Do not download the scripts')
    return parser.parse_args()

def main():
    args = parse_arguments()

    print(f"Number of events: {args.nevents}")

    download_and_prepare_scripts(ChainDownloadLinkFromMccM_dict, args)
    generate_executable_script('CMSSWConfigFile.txt')

if __name__ == "__main__":
    main()
