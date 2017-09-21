import subprocess
import glob
import os
import time
import sys
import xml.etree.ElementTree as ET
import getpass
import psutil

blendername        = r"blender.exe"
rendername         = r"C:\Users\slocumr.ONID\github\SimUAS\python\renderBlender.py"
renderargs         = r""
foldernames        = r"F:\bathytestdata2\BATHY*"
matlabname         = r"C:\Program Files\MATLAB\R2017a\bin\matlab.exe"
matlabfunctionname = r"C:\Users\slocumr.ONID\github\SimUAS\matlab\postprocess\postProcFolder"
nprocesses         = 3

SLEEPTIME = 30
DODEBUG = True

# Get Folder Names
folders = glob.glob(foldernames)
nfolders = len(folders)

# Preallocate
processes = []
procname  = []
procind   = []
logname   = []
currentlognames = []
currentind      = []

for i, fname in enumerate(folders):
    logname.append(fname + "/proc/autorender.log")
    procind.append(i+1)
    if os.path.exists(fname + "/proc/autorender.log"):
        nexist = nexist+1

logfile = logname[-1]

# start processing
dname,foo = os.path.split(rendername)

experimentName = fname
blenderrendercmd = blendername + " --background --python " + rendername + " -- " + experimentName + " " + renderargs
matdir, matfun = os.path.split(matlabfunctionname)
matlabpostproccmd = '\"' + matlabname + "\" -wait -r \"cd(\'" + matdir + '\');' + matfun + '(\'' + experimentName + '\',1,\'\')\"'
fullcmd = blenderrendercmd + "&" + matlabpostproccmd
print(fullcmd)

#process=subprocess.Popen(fullcmd,shell=True)
