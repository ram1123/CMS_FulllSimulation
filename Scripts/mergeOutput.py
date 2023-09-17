#!/usr/bin/env python
import os
import glob
import ROOT
import subprocess
import sys
import logging

logging.basicConfig(level=logging.INFO)

def system(command):
    return subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)

def system_with_terminal_display(command):
    logging.debug(command)
    return subprocess.call(command, shell=True)

def isValidRootFile(fname):
    if not os.path.exists(fname):
        return False
    f = ROOT.TFile.Open(fname)
    if not f:
        return False
    isValid = not (f.IsZombie() or f.TestBit(ROOT.TFile.kRecovered) or f.GetListOfKeys().IsEmpty())
    f.Close()
    if not isValid:
        logging.warning("Zombie found: {}".format(faultyfiles))
    return isValid

def checkfaulty(fname):
    faultyfiles = []  # Initialize an empty list to hold the names of faulty files
    probe = ROOT.TFile.Open(fname)

    for e in probe.GetListOfKeys():
        name = e.GetName()
        try:
            otherObj = probe.GetListOfKeys().FindObject(name).ReadObj()
        except Exception as ex:
            print("Exception occurred: ", ex)
            faultyfiles.append(probe.GetName())

    probe.Close()

    if faultyfiles:
        logging.warning("Faulty files found: {}".format(faultyfiles))
        return False

    return True

def isValidAndFaultFree(fname):
    # First check if it's a valid ROOT file
    if not isValidRootFile(fname):
        return False

    # Then check for faulty keys
    return checkfaulty(fname)

def merge_files(targetFile, filesToMerge):
    # If there are more than 100 files, split them into groups of 100
    if len(filesToMerge) > 100:
        logging.info('A lot of files to merge; this might take some time...')
        tempTargets = []
        tempFilesToMerge = [filesToMerge[x:x+100] for x in range(0, len(filesToMerge), 100)]

        for i, batch in enumerate(tempFilesToMerge):
            tempTargetFile = targetFile.replace('.root', '-temp{}.root'.format(i))
            tempTargets.append(tempTargetFile)

            # Check if temporary target file already exists and is valid
            if os.path.exists(tempTargetFile):
                if isValidAndFaultFree(tempTargetFile):
                    continue
                else:
                    logging.info("Removing temp hadd file {tempTargetFile}".format(tempTargetFile=tempTargetFile))
                    system_with_terminal_display('rm {tempTargetFile}'.format(tempTargetFile=tempTargetFile))

            system_with_terminal_display('python haddnano.py {0} {1}'.format(tempTargetFile, ' '.join(batch)))


        # Merge temporary files into the final target file
        system_with_terminal_display('python haddnano.py {targetFile} {" ".join(tempTargets)}'.format(targetFile=targetFile))

        # Remove temporary files
        for tempTarget in tempTargets:
            system_with_terminal_display('rm {tempTarget}'.format(tempTarget=tempTarget))

    # If there are 100 or fewer files, directly merge them
    else:
        logging.info(system('python haddnano.py {targetFile} {" ".join(filesToMerge)}'.format(targetFile=targetFile)))


def main():
    # Validate arguments
    if len(sys.argv) < 2:
        logging.error("Usage: script_name.py <submitVersion>")
        sys.exit(1)

    submitVersion = str(sys.argv[1])
    mainOutputDir = '/eos/user/r/rasharma/post_doc_ihep/aTGC/nanoAODnTuples/{submitVersion}'.format(submitVersion=submitVersion)
    logging.info("submitVersion: {submitVersion}".format(submitVersion=submitVersion))
    logging.info("mainOutputDir: {mainOutputDir}".format(mainOutputDir=mainOutputDir))

    # List of already merged eras
    Alreadymerged = [
        'WmZToLmNujj_01j_aTGC_pTZ-150toInf_mWV-150to600',
        'WmZToLmNujj_01j_aTGC_pTZ-150toInf_mWV-800toInf',
        'WpZToLpNujj_01j_aTGC_pTZ-150toInf_mWV-600to800',
        'WpZToLpNujj_01j_aTGC_pTZ-150toInf_mWV-800toInf'
    ]
    # Loop through each era directory
    for eraDir in glob.glob("{mainOutputDir}/*".format(mainOutputDir=mainOutputDir)):
        if not os.path.isdir(eraDir):
            continue
        era = os.path.basename(eraDir)
        logging.info("Processing era: {era}".format(era=era))

        if era in Alreadymerged:
            logging.info("Skipping this era as it is already merged.")
            continue

        targetFile = os.path.join(eraDir, '.root').replace('/.root', '.root')
        filesToMerge = glob.glob(os.path.join(eraDir, '*.root'))

        if len(filesToMerge) == 0:
            logging.info("No files to merge. Skipping.")
            continue

        # Check if the target file already exists and is valid
        if os.path.exists(targetFile):
            if isValidAndFaultFree(targetFile):
                logging.info("Seems hadd is already performed. Skipping.")
                continue
            else:
                logging.info("Removing invalid target file {targetFile}".format(targetFile=targetFile))
                system_with_terminal_display('rm {targetFile}'.format(targetFile=targetFile))

        # Merge the files
        merge_files(targetFile, filesToMerge)

if __name__ == "__main__":
    main()
