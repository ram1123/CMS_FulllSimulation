"""
This script automates the process of downloading, preparing, and processing CMS full detector simulation starting from gridpack.

This script depends on the four external files. They are:

1. [ChainDownloadLinkFromMccM_dict.py](ChainDownloadLinkFromMccM_dict.py) - Contains the chain name and the download link from McM.
    1. [CMSSWConfigFile.txt](CMSSWConfigFile.txt) - Contains the list of configuration files you want to generate.
        This file is generated by the script, [GetFullSimScriptsFromMCCM.py](GetFullSimScriptsFromMCCM.py) based on the
        [ChainDownloadLinkFromMccM_dict.py](ChainDownloadLinkFromMccM_dict.py). If you already have the configuration files,
        then just set properly the file CMSWConfigFile.txt. **Note:** you can also change the name of this file using command line
1. [gridpack_lists.py](gridpack_lists.py) - Contains the list of gridpacks you want to generate.

The script performs the following tasks:
1. Download the scripts from the provided URLs.
2. Modify the downloaded scripts.
3. Parse the scripts for CMSSW version and configuration file information.
4. Generate an executable script from the configuration file.
5. Generate a JDL file  and sh for condor submission.
6. Submit the jobs using the generated JDL file.
"""

import os
import re
import sys
import subprocess
import logging
import argparse
from urllib.parse import urlparse
from pathlib import Path
from collections import OrderedDict
import datetime
import json

# Setup logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
class ColorfulFormatter(logging.Formatter):
    """Custom logging Formatter that adds colors."""

    grey = "\x1b[38;21m"
    yellow = "\x1b[33;21m"
    red = "\x1b[31;21m"
    bold_red = "\x1b[31;1m"
    green = "\x1b[33m"
    blue = "\x1b[34m"
    reset = "\x1b[0m"
    format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

    FORMATS = {
        logging.DEBUG: green + format + reset,
        logging.INFO: blue + format + reset,
        logging.WARNING: yellow + format + reset,
        logging.ERROR: red + format + reset,
        logging.CRITICAL: bold_red + format + reset
    }

    def format(self, record):
        log_fmt = self.FORMATS.get(record.levelno)
        formatter = logging.Formatter(log_fmt)
        return formatter.format(record)

# Setup logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger()
logger.handlers[0].setFormatter(ColorfulFormatter())

# Importing configurations from external files
from utils.ChainDownloadLinkFromMccM_dict import ChainDownloadLinkFromMccM_dict
from utils.condor_script_template import jdl_file_template_part1of2, jdl_file_template_part2of2, ReplacementDict
from utils.gridpack_lists import models


def run_subprocess(command: list, task_description: str) -> subprocess.CompletedProcess:
    """Execute a subprocess command and handle errors."""
    try:
        result = subprocess.run(command, check=True, text=True, capture_output=True)
        logging.info(f'Successfully completed {task_description}: {result.stdout}')
        return result
    except subprocess.CalledProcessError as e:
        logging.error(f'Error during {task_description}: {e.stderr}')
        raise

def run_subprocess_os(command: str, task_description: str):
    """As running the bash script from mccm requires the grid password, we need to run the script using os.system."""
    try:
        logging.info(f'Running {task_description}')
        os.system(command)
        logging.info(f'Successfully completed {task_description}')
    except Exception as e:
        logging.error(f'Error during {task_description}: {e}')
        raise

def url_validator(url: str) -> bool:
    """Validate the URL."""
    try:
        result = urlparse(url)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False

def download_script(url: str, script_name: str):
    """Download a script from a given URL after validating the URL."""
    if not url_validator(url):
        logging.error(f'Invalid URL: {url}')
        return
    logging.info(f'Downloading {script_name} from {url}')
    run_subprocess(["wget", url, "-O", script_name], f'downloading {script_name}')

def modify_script(script_name: str, config_file_path: Path):
    """Perform modifications on the downloaded script using sed command."""
    logging.debug(f'Modifying {script_name}')
    logging.debug(f'Config file path: {config_file_path}')
    script_path = Path(script_name)
    if not script_path.exists():
        logging.error(f'Script not found: {script_name}')
        return
    run_subprocess(["sed", "-i", "/cd \\/afs/s/^/#/", script_name], 'commenting out cd /afs')
    run_subprocess(["sed", "-i", "s/mv ../cp -r ../g", script_name], 'replacing mv with cp -r')
    run_subprocess(["chmod", "+x", script_name], 'making script executable')

    # Get the input file name and output file name from the script
    filein_name = None
    fileout_name = None

    # Read and search for filein and fileout
    with open(script_path, 'r') as file:
        for line in file:
            if 'cmsDriver.py' in line:
                # Search for --filein and --fileout values
                filein_match = re.search(r"--filein (file:[^\s]+)", line)
                fileout_match = re.search(r"--fileout (file:[^\s]+)", line)

                if filein_match:
                    filein_name = filein_match.group(1)
                else:
                    if "step1" not in str(script_name):
                        logging.warning(f"Filein not found in {script_name}, so lets grab it from the CMSSW config file which is --CMSSWConfigFile its format is json")
                        with open(config_file_path, 'r') as file:
                            config_data = json.load(file)[0]
                            for step, details in config_data.items():
                                logging.warning(f"Step: {step}")
                                logging.warning(f"  Script Name: {details['script_name']}")
                                logging.warning(f"  fileout: {details['fileout']}")
                                filein_name = details['fileout']    # FIXME: It dpends on the last argument. If it read the json in random order then it may break
                                # Replace --filein in the script
                                update_filein_in_script(script_path, filein_name)

                if fileout_match:
                    fileout_name = fileout_match.group(1)
                break

    logging.info(f"Filein: {filein_name}, Fileout: {fileout_name}")

    return filein_name, fileout_name

def update_filein_in_script(script_path, new_filein):
    """
    Update the --filein argument in a CMS driver script.

    Args:
    - script_path: Path to the script file.
    - new_filein: New value to set for --filein.
    """
    # Ensure script_path is a Path object for easier handling
    script_path = Path(script_path) if not isinstance(script_path, Path) else script_path

    # Read the existing script content
    with open(script_path, 'r') as file:
        lines = file.readlines()

    # Prepare the new content
    new_content = []
    filein_pattern = re.compile(r'--filein \S+')
    for line in lines:
        # Check if this line contains the --filein argument
        if '--filein' in line:
            # Replace the entire --filein argument
            new_line = filein_pattern.sub(f'--filein {new_filein}', line)
            new_line = new_line.replace("NANOEDMAODSIM", "NANOAODSIM")
            new_content.append(new_line)
        else:
            new_content.append(line)


    # Write the modified content back to the script
    with open(script_path, 'w') as file:
        file.writelines(new_content)

def parse_script_for_config(script_name: str, config_file_path: str, filein_name: str, fileout_name: str):
    """Extract CMSSW version and config file information from a script."""
    CMSSWVersion, CMSSW_ConfigFile = None, None
    with open(script_name, 'r') as file:
        for line in file:
            if 'CMSSW' in line and '-r' in line:
                CMSSWVersion = line.split('-r')[1].split('/')[0].strip()
            if '--python_filename' in line:
                CMSSW_ConfigFile = line.split('--python_filename')[1].split()[0].strip()

    if CMSSWVersion and CMSSW_ConfigFile:
        details = {
            'script_name': str(script_name),
            'CMSSWVersion': CMSSWVersion,
            'CMSSW_ConfigFile': str( script_name.parent / CMSSW_ConfigFile ),
            'filein': filein_name,
            'fileout': fileout_name
        }

        # Extract step name from script_name (excluding the file extension)
        step_name = Path(script_name).stem

        update_json_file(config_file_path, step_name, details)

def update_json_file(config_file_path, step_name, details):
    # Initialize an empty dictionary to hold all configurations
    all_configs = {}

    # If the file exists and is not empty, load its content
    if Path(config_file_path).is_file():
        with open(config_file_path, 'r') as file:
            try:
                # The JSON file should contain a list with a single object
                all_configs = json.load(file)[0]
            except json.JSONDecodeError:
                pass  # If JSON is empty or invalid, we keep all_configs empty

    # Update the dictionary with the new step details
    all_configs[step_name] = details

    # Write the updated configurations back to the file
    with open(config_file_path, 'w') as file:
        # Wrapping the dictionary in a list
        json.dump([all_configs], file, indent=4)

def download_and_prepare_scripts(chain_dict: OrderedDict, args: argparse.Namespace):
    """Download and prepare scripts from the provided dictionary."""
    # config_file_path = Path(args.CMSSWConfigFile)
    config_file_path = Path('ConfigFiles') / args.model / args.year / args.CMSSWConfigFile
    if os.path.exists(config_file_path):
        os.remove(config_file_path)

    logging.debug(f'Chain dict: {chain_dict}')
    for key, value in chain_dict[args.model][args.year].items():
        logging.info(f'Starting preparation for {key}')
        logging.debug(f'Value: {value}')
        script_name = f"{key}.sh"
        script_path =  Path(script_name)
        script_path = Path('ConfigFiles') / args.model / args.year / script_path
        script_path.parent.mkdir(parents=True, exist_ok=True)  # Ensure the directory exists

        if args.NOdownload:
            logging.info(f'Skipping download for {key}')
        else:
            download_script(value, script_path)
        filein_name, fileout_name = modify_script(script_path, config_file_path)
        parse_script_for_config(script_path, config_file_path, filein_name, fileout_name)

        if args.run_exec:
            # change the directory to the script path and run the script
            logging.info(f'Executing {script_path}')
            os.chdir(script_path.parent)
            logging.debug(f'Current directory: {os.getcwd()}')
            run_subprocess_os("./" + str(script_path.name), f'executing {script_path}')
            # change back to the original directory
            os.chdir(os.path.dirname(os.path.realpath(__file__)))
            logging.debug(f'Current directory: {os.getcwd()}')

        logging.info(f'Finished {key}')

def generate_executable_script(args: argparse.Namespace):
    """Generate an executable script from the configuration file."""

    config_file_path = Path('ConfigFiles') / args.model / args.year / args.CMSSWConfigFile
    logging.info(f"Generating executable script from {config_file_path}")

    cmssw_versions = {}
    cmssw_config_files = {}

    with open(config_file_path, 'r') as file:
        config_data = json.load(file)[0]

    # Iterate through the dictionary to print details for each step
    for step, details in config_data.items():
        logging.debug(f"Step: {step}")
        logging.debug(f"  Script Name: {details['script_name']}")
        logging.debug(f"  CMSSW Version: {details['CMSSWVersion']}")
        logging.debug(f"  CMSSW Config File: {details['CMSSW_ConfigFile']}\n")
        script_name = details['script_name']
        CMSSWVersion = details['CMSSWVersion']
        CMSSW_ConfigFile = details['CMSSW_ConfigFile']

        # Conditionally update the CMSSW version if the argument is set
        if args.UseCustomNanoAOD and CMSSWVersion == 'CMSSW_10_6_26':
            CMSSWVersion = 'CMSSW_10_6_30'

        # Extract the numeric part of the step for use in the dictionaries
        step_number = step.split('_')[0][-1]

        cmssw_versions[f"step{step_number}"] = CMSSWVersion
        cmssw_config_files[f"step{step_number}"] = CMSSW_ConfigFile

    script_content = build_bash_script(cmssw_versions, cmssw_config_files, args)
    with open(args.jobName + '.sh', 'w') as f:
        f.write(script_content)

def build_bash_script(versions: dict, config_files: dict, args: argparse.Namespace) -> str:
    """
    Constructs the bash script content based on the provided CMSSW versions and configuration files.
    """
    script_content = f"""#!/bin/bash

echo "Job started..."
echo "Starting job on " $(date)
echo "Running on: $(uname -a)"
echo "System software: $(cat /etc/redhat-release)"
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc7_amd64_gcc700
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

    # Loop through the steps and generate the script content
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
        if args.UseCustomNanoAOD and step == 'step7': # FIXME: This is a temporary fix
            script_content += f"git cms-merge-topic -u ram1123:CMSSW_10_6_30_HHWWgg_nanoV9\n"
            script_content += f"./PhysicsTools/NanoTuples/scripts/install_onnxruntime.sh\n"
        script_content += f"scram b\n"
        script_content += f"cd -\n"
        if i == 1:
            # Special handling for step 1 with seed value
            script_content += f"cmsRun ${{{step}_cfg}} seedval=${{seed}} maxEvents=${{5}} gridpack=${{4}}\n"
        else:
            script_content += f"cmsRun ${{{step}_cfg}}\n"
        script_content += "echo \"list all files\"\n"
        script_content += "ls -ltrh\n"

    # copy output nanoAOD file to output directory with cluster ID and process ID as suffix of the root file
    script_content += "\n# Copy output nanoAOD file to output directory\n"
    script_content += "echo \"Copying output nanoAOD file to output directory\"\n"
    script_content += "ls -ltrh\n"
    script_content += "echo \"cp -r HIG-RunIISummer20UL17NanoAODv9-03735.root $3/nanoAOD_$1_$2.root\"\n"    # FIXME: Hardcoded nanoAOD output file name
    script_content += "cp -r HIG-RunIISummer20UL17NanoAODv9-03735.root $3/nanoAOD_$1_$2.root\n" # FIXME: Hardcoded nanoAOD output file name
    script_content += "echo \"Job finished on \" $(date)\n"

    return script_content

def generate_jdl_file(args: argparse.Namespace):
    """Generate the JDL file."""
    # Ensure the log directory exists
    log_dir = Path("log")
    log_dir.mkdir(exist_ok=True)

    # Prepare the comma-separated list of configuration files from JSON file
    config_file_path = Path('ConfigFiles') / args.model / args.year / Path(args.CMSSWConfigFile)
    comma_separated_config_files = ''
    with open(config_file_path, 'r') as file:
        config_data = json.load(file)[0]
    comma_separated_config_files = ', '.join(details['CMSSW_ConfigFile'] for step, details in config_data.items())

    # Prepare paths and template replacements
    jdl_content = []
    logging.debug(f"Comma-separated config files: {comma_separated_config_files}")
    jdl_content.append(jdl_file_template_part1of2.format(
        CondorExecutable=os.path.abspath(args.jobName),
        CommaSeparatedConfigFiles=comma_separated_config_files,
        CondorQueue=args.queue
    ))

    # Loop through the models and generate specific JDL configurations
    for gridpack in models[args.model]:
        TimeStamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

        # For the naming convention grab sample info from gridpack path
        SampleName = gridpack.split('/')[-1]
        for key, value in ReplacementDict.items():
            # Update the SampleName using the replacement dict
            SampleName = SampleName.replace(key, value)

        model_log_dir = log_dir / args.model / SampleName / TimeStamp
        model_log_dir.mkdir(parents=True, exist_ok=True)

        output_dir = Path(args.outDir) / args.model / SampleName / TimeStamp
        output_dir.mkdir(parents=True, exist_ok=True)

        logging.debug(f"Log directory: {model_log_dir}")
        logging.debug(f"Output directory: {output_dir}")

        jdl_content.append(jdl_file_template_part2of2.format(
            CondorLogPath=str(model_log_dir),
            OutputDir=str(output_dir),
            GridpackWithPath=gridpack,
            maxEvents=args.nevents,
            Queue=args.nJobs
        ))
        if args.debug:
            break

    # Write the JDL content to a file
    jdl_filename = f"{args.jobName}.jdl"
    with open(jdl_filename, 'w') as jdl_file:
        jdl_file.write("\n".join(jdl_content))

    logging.info(f"JDL file '{jdl_filename}' has been generated.")

def UpdatewmLHEConfigFile():
    """Update the wmLHEConfigFile with the gridpack path, nevents, and seed."""
    # Append the gridpack path, nevents, and seed to the LHE config file
    logging.info("Appending gridpack path, nevents, and seed to the LHE config file.")

    ArgInfo = """
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
"""
    with open(Path('ConfigFiles') / args.model / args.year / 'HIG-RunIISummer20UL17wmLHEGEN-03707_1_cfg.py', 'r') as file:
        data = file.readlines()

    insert_index = 0
    insert_index = next((i for i, line in enumerate(data) if 'from Configuration.Eras' in line), None) + 1
    data.insert(insert_index, ArgInfo)

    ArgInfo = """process.MessageLogger.cerr.FwkReport.reportEvery = cms.untracked.int32(500)"""
    insert_index = next((i for i, line in enumerate(data) if 'process.maxEvents ' in line), None) - 1
    data.insert(insert_index, ArgInfo)

    with open(Path('ConfigFiles') / args.model / args.year / 'HIG-RunIISummer20UL17wmLHEGEN-03707_1_cfg.py', 'w') as file:
        file.writelines(data)
    logging.debug("Exitting after appending gridpack path, nevents, and seed to the LHE config file.")

def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description='Script to automate CMSSW script processing')
    parser.add_argument('--nevents', type=int, default=100, help='Number of events to process')
    parser.add_argument('--run_exec', action='store_true', help='Run the executable script after creation')
    parser.add_argument('--NOdownload', action='store_true', help='Do not download the scripts')
    parser.add_argument('--CMSSWConfigFile', type=str, default='CMSSWConfigFile.json', help='Name of the CMSSW configuration file, default path should be in ConfigFiles/model/year/')
    parser.add_argument('--model', type=str, default='HHbbgg', help='Gridpack model from gridpack_lists.py')
    parser.add_argument('--year', type=str, default='2017', help='Year of the gridpack')
    parser.add_argument('--queue', type=str, default='testmatch',choices=['espresso', 'microcentury', 'longlunch', 'workday', 'tomorrow', 'testmatch', 'nextweek'],  help='Condor queue to use')
    parser.add_argument('--outDir', type=str, help='Output directory', required=True)
    parser.add_argument('--nJobs', type=int, default=1, help='Number of jobs to submit with each gridpack')
    parser.add_argument('--jobName', type=str, default='run_simulation_HHbbgg', help='Job name')
    parser.add_argument('--UseCustomNanoAOD', action='store_true', help='Use custom nanoAOD file for analysis')
    parser.add_argument('--debug', action='store_true', help='Submit only one job for debugging')
    return parser.parse_args()

def printInfoToSubmit(args: argparse.Namespace):
    CondorExecutable = os.path.abspath(args.jobName)

    print("===> Set Proxy Using:")
    print("\033[92mvoms-proxy-init --voms cms --valid 168:00\033[0m")
    print("===> copy proxy to home path")
    print("\033[92mcp /tmp/x509up_u48539 ~/\033[0m")
    print("===> export the proxy")
    print("\033[92mexport X509_USER_PROXY=~/x509up_u48539\033[0m")
    print("===> Submit jobs using:")
    print(f"\033[92mcondor_submit {CondorExecutable}.jdl\033[0m")

def main():
    """Main function."""
    args = parse_arguments()

    logging.info(f"Processing with the following parameters: {args}")

    if not args.NOdownload:
        # FIXME: Improve this function and the working of `NOdownload` flag
        # INFO: Users may need to modify the generated .sh file or the configuration file
        download_and_prepare_scripts(ChainDownloadLinkFromMccM_dict, args)
    else:
        # Before running this we need to ensure that we updated the LHE config file to include the gridpack path, nevents, and seed
        logging.info("Skipping download and preparation of scripts.")

        append_to_config_file = False
        if append_to_config_file:
            UpdatewmLHEConfigFile()
        else:
            user_input = input("Have you updated the LHE config file with the gridpack path, nevents, and seed? (y/n): ").strip().lower()

            if user_input == 'yes' or user_input == 'y':
                logging.info("Continuing with the script processing.")
                generate_executable_script(args)
                generate_jdl_file(args)
                printInfoToSubmit(args)
            else:
                logging.error("Please update the LHE config file with the gridpack path, nevents, and seed.")
                sys.exit(1)

    logging.info("Script processing completed.")

if __name__ == "__main__":
    main()
