import argparse
import os
from gridpack_lists import models
from condor_script_template import sh_file_template
from condor_script_template import jdl_file_template_part1of2
from condor_script_template import jdl_file_template_part2of2

parser = argparse.ArgumentParser(description='Generate Condor script for aTGC samples')

parser.add_argument('--condor_executable', type=str, default="aTGC_WW_Signal_v2",
                    help='Name of the Condor executable')
parser.add_argument('--TopLogDirectory', type=str, default="log_15Feb_cpBugFix",
                    help='Path for the log file')
parser.add_argument('--output_dir_name', type=str, default="/eos/user/r/rasharma/post_doc_ihep/aTGC/nanoAODnTuples/aTGC_SignalSamples/",
                    help='Path for the output directory')
parser.add_argument('--condor_queue', type=str, default="testmatch",
                    help='Name of the Condor queue: espresso, testmatch')
parser.add_argument('--queue', type=int, default=1000,
                    help='Number of jobs')

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
    for gridpackWithPath in models['aTGC_Sep2023']:
        short_name = gridpackWithPath.split('/')[-1].replace('_4f_NLO_FXFX_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz','')

        # Create the output path, where the nanoAOD will be stored
        output_rootfile_path =  f"{outputDirName}/{short_name}"
        os.makedirs(output_rootfile_path, exist_ok=True)

        # Create the output log file path
        output_logfile_path = f"{TopLogDirectory}/{short_name}"
        os.makedirs(output_logfile_path, exist_ok=True)

        # Write the job description to the file
        fout.write(jdl_file_template_part2of2.format(
                                            CondorLogPath = output_logfile_path,
                                            OutPutDir = output_rootfile_path,
                                            GridpackWithPath = gridpackWithPath,
                                            queue = queue
                                            ))

# Make the shell script executable
os.system(f"chmod 777 {CondorExecutable}.sh")

# Print the steps to submit the job
print("===> Set Proxy Using:")
print("voms-proxy-init --voms cms --valid 168:00")
print("===> copy proxy to home path")
print("cp /tmp/x509up_u48539 ~/")
print("===> export the proxy")
print("export X509_USER_PROXY=~/x509up_u48539")
print(f"\"condor_submit {CondorExecutable}.jdl\" to submit")
