"""
Script to submit the condor jobs

This script generates a Condor script and job description file (JDL) to submit gridpacks for full CMSSW simulation processing. It takes command line arguments to customize the execution.

Command line arguments:
    --condor_executable: Name of the Condor executable
    --TopLogDirectory: Path for the log file
    --output_dir_name: Path for the output directory
    --condor_queue: Name of the Condor queue (espresso, testmatch)
    --queue: Number of jobs

The script creates a shell script and a job description file based on provided templates. It then loops over a list of gridpacks and adds them to the job description file. The output paths for the nanoAOD files and log files are created, and the job description is written to the file.

Finally, the shell script is made executable and instructions for submitting the job are printed.

Note: This script assumes the existence of the 'gridpack_lists' and 'condor_script_template' modules in the same directory.

Usage:
    python condor_setup_new.py --condor_executable=aTGC_WW_Signal_ext1 --TopLogDirectory=log_15Feb_cpBugFix --output_dir_name=/eos/user/r/rasharma/post_doc_ihep/aTGC/nanoAODnTuples/aTGC_SignalSamples_Sep2023_ext/ --condor_queue=testmatch --queue=1000
    # 1 April 2024
    python3 condor_setup_new.py --condor_executable="HHbbgg" --TopLogDirectory="Log_Apr2024" --output_dir_name="/eos/user/r/rasharma/post_doc_ihep/double-higgs/nanoAODnTuples/" --condor_queue=longlunch --queue=1 --maxEvents=100 --debug
"""
import argparse
import os
from gridpack_lists import models
from condor_script_template import sh_file_template
from condor_script_template import jdl_file_template_part1of2
from condor_script_template import jdl_file_template_part2of2


parser = argparse.ArgumentParser(description='Generate Condor script for aTGC samples')

parser.add_argument('--condor_executable', type=str, default="aTGC_WW_Signal_ext1",
                    help='Name of the Condor executable')
parser.add_argument('--TopLogDirectory', type=str, default="log_15Feb_cpBugFix",
                    help='Path for the log file')
parser.add_argument('--output_dir_name', type=str, default="/eos/user/r/rasharma/post_doc_ihep/aTGC/nanoAODnTuples/aTGC_SignalSamples_Sep2023_ext/",
                    help='Path for the output directory')
parser.add_argument('--condor_queue', type=str, default="testmatch",
                    help='Name of the Condor queue: espresso, testmatch')
parser.add_argument('--maxEvents', type=int, default=100, help='Number of events to process')
parser.add_argument('--queue', type=int, default=1,
                    help='Number of jobs')
parser.add_argument('--debug', action='store_true', help='Submit only one job for debugging')

args = parser.parse_args()

CondorExecutable = args.condor_executable
TopLogDirectory = args.TopLogDirectory
outputDirName = args.output_dir_name
CondorQueue = args.condor_queue
queue = args.queue

# Create the shell script
with open(f"{CondorExecutable}.sh","w") as fout:
    fout.write(sh_file_template.format(test="Job started..."))

# Create the job description file
with open(f"{CondorExecutable}.jdl","w") as fout:
    fout.write(jdl_file_template_part1of2.format(
                                            CondorExecutable = CondorExecutable,
                                            CondorQueue = CondorQueue))

    # Loop over all gridpacks  to  add them in the jdl file
    for gridpackWithPath in models['HHbbgg']:
        short_name = gridpackWithPath.split('/')[-1].replace('_4f_NLO_FXFX_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz','')
        short_name = short_name.replace('_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz','')

        # Create the output path, where the nanoAOD will be stored
        output_rootfile_path =  f"{outputDirName}/{CondorExecutable}/{short_name}"
        os.makedirs(output_rootfile_path, exist_ok=True)

        # Create the output log file path
        output_logfile_path = f"{TopLogDirectory}/{short_name}"
        os.makedirs(output_logfile_path, exist_ok=True)

        # Write the job description to the file
        fout.write(jdl_file_template_part2of2.format(
                                            CondorLogPath = output_logfile_path,
                                            OutPutDir = output_rootfile_path,
                                            GridpackWithPath = gridpackWithPath,
                                            maxEvents = args.maxEvents,
                                            queue = queue
                                            ))
        if args.debug:
            break

# Make the shell script executable
os.system(f"chmod 777 {CondorExecutable}.sh")

# Print the steps to submit the job
print("===> Set Proxy Using:")
print("voms-proxy-init --voms cms --valid 168:00")
print("===> copy proxy to home path")
print("cp /tmp/x509up_u48539 ~/")
print("===> export the proxy")
print("export X509_USER_PROXY=~/x509up_u48539")
print("===> Submit the job using the command:")
print(f'condor_submit {CondorExecutable}.jdl')
