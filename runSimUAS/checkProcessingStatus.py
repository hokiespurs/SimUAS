import glob
import os
import datetime

print(datetime.datetime.now())

## CONSTANTS
FOLDERNAME = r'O:\simUAS\EXPERIMENTS\OVERSIDEB'
SETTINGNAME = r"*.xml"
## Determine if each folder has been rendered

# get folder names
folders = glob.glob(FOLDERNAME + "/*")
nfolders = len(folders)

procfolders = []
renderstatus = []
agiprocstatus = []
allsettingdir = []
for fname in folders:
    proctimefilename = fname + "/output/log/processingTime.txt"
    if os.path.exists(proctimefilename):
        file = open(proctimefilename, "r") 
        foo = file.readline()
        matlabline = file.readline()
        file.close()
        if matlabline[0:11] == "Matlab Time":
            procfolders.append(fname)
            renderstatus.append(1)
        else:
            renderstatus.append(2)
            print("RENDER INPROGRESS: " + fname)
    else:
        autorendername = fname + "/output/autorender.log"
        if os.path.exists(autorendername):
            renderstatus.append(2)
            print("RENDER INPROGRESS: " + fname)
        else:
            renderstatus.append(3)
            
    ## For each rendered folder
    ##   determine which photoscan settings have been processed
    allsettings = glob.glob(fname + "/proc/settings/" + SETTINGNAME)
    for settingdir in allsettings:
        allsettingdir.append(settingdir)
        foo,settingname = os.path.split(settingdir)
        if os.path.exists(fname + "/proc/results/" + settingname[0:-4]):
            proctimelog = fname + "/proc/results/" + settingname[0:-4] + "/proctime.log"
            if os.path.exists(proctimelog):
                file = open(proctimelog, "r") 
                alllines = file.readlines()
                if len(alllines)==16:
                    agiprocstatus.append(1)
                else:
                    agiprocstatus.append(2)
                    print("AGIPROC INPROGRESS: " + settingdir)
            else:
                agiprocstatus.append(2)
                print("AGIPROC INPROGRESS: " + settingdir)
        else:
            agiprocstatus.append(3)    

nRendered  = sum(1 for i in renderstatus if i==1)
nRendering = sum(1 for i in renderstatus if i==2)
nToRender  = sum(1 for i in renderstatus if i==3)
print("\nBLENDER RENDERING")
print("Rendered: " + str(nRendered))
print("Rendering: " + str(nRendering))
print("Remaining: " + str(nToRender))

nProcessed  = sum(1 for i in agiprocstatus if i==1)
nProcessing = sum(1 for i in agiprocstatus if i==2)
nToProcess  = sum(1 for i in agiprocstatus if i==3)
print("PHOTOSCAN PROCESSING")
print("Processed: " + str(nProcessed))
print("Processing: " + str(nProcessing))
print("Remaining: " + str(nToProcess))

# DANGER - DELETE AGIPROC PROCESSING FOLDERS
import shutil
for settingdir, processingstatus in zip(allsettingdir,agiprocstatus):
    if (processingstatus==2):
        foo,settingname = os.path.split(settingdir)
        procdirname, foo = os.path.split(foo)
        rmdirname = procdirname + "/results/" + settingname[0:-4]
        # print("Removing: " + rmdirname)
        # shutil.rmtree(rmdirname)
