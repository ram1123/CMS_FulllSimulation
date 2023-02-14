import os
from gridpack_lists import models
from condor_script_template import sh_file_template
from condor_script_template import jdl_file_template_part1of2
from condor_script_template import jdl_file_template_part2of2

CondorExecutable = "aTGC_WW_Signal_v2"
output_logfile_path = "log_14Feb"
outputDirName = "/eos/user/r/rasharma/post_doc_ihep/aTGC/nanoAODnTuples/aTGC_SignalSamples/"
CondorQueue = "testmatch" # espresso, testmatch
queue = 1000 # Number of jobs

with open(CondorExecutable + ".sh","w") as fout:
    fout.write(sh_file_template.format(test="Job started..."))

with open(CondorExecutable + ".jdl","w") as fout:
    fout.write(jdl_file_template_part1of2.format(
                                            CondorExecutable = CondorExecutable,
                                            CondorQueue = CondorQueue))

    # To generalize add a for loop over all root files.
    for gridpackWithPath in models['aTGC']:
        short_name = gridpackWithPath.split('/')[-1].replace('_4f_NLO_FXFX_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz','')

        output_rootfile_path =  outputDirName+'/'+short_name
        os.makedirs(output_rootfile_path, exist_ok=True)

        output_logfile_path = output_logfile_path + '/' + short_name
        os.makedirs(output_logfile_path, exist_ok=True)
        fout.write(jdl_file_template_part2of2.format(
                                            CondorLogPath = output_logfile_path,
                                            OutPutDir = output_rootfile_path,
                                            # GridpackWithPath = gridpackWithPath.replace('/','\/'),
                                            GridpackWithPath = gridpackWithPath,
                                            queue = queue
                                            ))

os.system("chmod 777 "+CondorExecutable+".sh");

print "===> Set Proxy Using:";
print "\tvoms-proxy-init --voms cms --valid 168:00";
print "===> copy proxy to home path"
print "cp /tmp/x509up_u48539 ~/"
print "===> export the proxy"
print "export X509_USER_PROXY=~/x509up_u48539"
print "\"condor_submit "+CondorExecutable+".jdl\" to submit";
