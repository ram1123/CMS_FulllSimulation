#!/bin/env python
import os, glob, ROOT, subprocess, sys


# submitVersion = 'aTGC_nTuples_31Oct_2016'
submitVersion = str(sys.argv[1])
mainOutputDir = '/eos/user/r/rasharma/post_doc_ihep/aTGC/nanoAODnTuples/%s' % (submitVersion)
print("submitVersion: %s"%submitVersion)
print("mainOutputDir: %s"%mainOutputDir)

def system(command):
    # print "=="*51
    # print "COMMAND: ",command
    return subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)

# Check if valid ROOT file exists
def isValidRootFile(fname):
    if not os.path.exists(os.path.expandvars(fname)): return False
    f = ROOT.TFile(fname)
    if not f: return False
    try:
        return not (f.IsZombie() or f.TestBit(ROOT.TFile.kRecovered) or f.GetListOfKeys().IsEmpty())
    finally:
        f.Close()

# for eraDir in glob.glob(os.path.join(mainOutputDir, 'UL2016*')):
for eraDir in glob.glob(mainOutputDir+'/*'):
    print ("=="*51)
    if not os.path.isdir(eraDir): continue
    era = eraDir.split('/')[-1]
    # try:
        # os.makedirs(os.path.join(eraDir, 'merged'))
    # except:
        # pass
    print("eraDir:",eraDir)
    print("era:",era)
    Alreadymerged = ['WmZToLmNujj_01j_aTGC_pTZ-150toInf_mWV-150to600',
                                'WmZToLmNujj_01j_aTGC_pTZ-150toInf_mWV-800toInf',
                                'WpZToLpNujj_01j_aTGC_pTZ-150toInf_mWV-600to800',
                                'WpZToLpNujj_01j_aTGC_pTZ-150toInf_mWV-800toInf']
    # Check if era does not have any elements that belongs to Alreadymerged list
    if era in Alreadymerged:
        print("Skipping this era as it is already merged.")
        continue
    # Check if eraDir is a directory or not
    # print("merged: ",os.path.join(eraDir, 'merged'))
    # outputMergedFile = os.path.join(eraDir, 'merged')
    for crabDir in glob.glob(os.path.join(mainOutputDir)):
        print("crabDir: ",crabDir)
        targetFile   = os.path.join(eraDir, '.root')
        targetFile = targetFile.replace('/.root','.root')
        filesToMerge = glob.glob(os.path.join(eraDir, '*.root'))
        print "crabDir: ",crabDir
        print "targetFile: ",targetFile
        # print "filesToMerge: ",filesToMerge
        print "len(filesToMerge): ",len(filesToMerge)
        if len(filesToMerge) == 0:
            print("No files to merge. Skipping.")
            continue
        print "Check if the target file already exits or not?"
        if os.path.exists(targetFile): # if existing target file exists and looks ok, skip
            if isValidRootFile(targetFile):
                print("Seems hadd is already performed.")
                continue
            else:   os.system('rm %s' % targetFile)

        print "Check if all the files that we need to hadd is valid or not?"
        count = 0
        # Log every 1000 lines.
        LOG_EVERY_N = 500
        for f in filesToMerge:
            count += 1
            if not isValidRootFile(f):
                print('WARNING: something wrong with %s' % f)
            if (count % LOG_EVERY_N) == 0: print ("Checking file validity for file count : {} ".format(count))

        print "Start the hadd step with 100 files at once."
        if len(filesToMerge)>100:
            print('A lof of files to merge, this might take some time...')

            tempTargets = []
            # split the list of all root files into chunk of 100 files
            tempFilesToMerge = [filesToMerge[x:x+100] for x in range(0, len(filesToMerge), 100)]

            # print "tempFilesToMerge:",len(tempFilesToMerge)
            count = 1
            for i in range(0,len(tempFilesToMerge)):
                print "---"
                tempTargetFile = targetFile.replace('.root', '-temp%s.root' % str(i))
                print("tempTargetFile: %s"%tempTargetFile)
                tempTargets.append(tempTargetFile)
                if os.path.exists(tempTargetFile): # if existing target file exists and looks ok, skip
                    if isValidRootFile(tempTargetFile): continue
                    else:
                        print("Removing temp hadd file {}".format(tempTargetFile))
                        os.system('rm %s' % tempTargetFile)
                # tempFilesToMerge = [f for f in filesToMerge if ('%s.root' % str(i)) in f]
                # print(('python haddnano.py    %s %s' % (tempTargetFile, ' '.join(tempFilesToMerge[i]))))
                os.system('python haddnano.py    %s %s' % (tempTargetFile, ' '.join(tempFilesToMerge[i])))
                # if count > 0: break
            os.system('python haddnano.py   %s %s' % (targetFile, ' '.join(tempTargets)))
            for i in tempTargets:
                system('rm %s' % i)
        else:
            print(system('python haddnano.py   %s %s' % (targetFile, ' '.join(filesToMerge))))
