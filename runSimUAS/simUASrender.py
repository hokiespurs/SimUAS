import subprocess
import glob
import os
import time
import sys
import xml.etree.ElementTree as ET
import getpass
import psutil

if len(sys.argv)==1:
    blendername        = r"blender.exe"
    rendername         = r"C:\Users\slocumr.ONID\github\SimUAS\python\renderBlender.py"
    foldernames        = r"F:\bathytestdata/BATHY00*"
    matlabname         = r"matlab.exe"
    matlabfunctionname = r"C:\Users\slocumr.ONID\github\SimUAS\matlab\postprocess\postProcFolder.m"
    nprocesses         = 3
else:
    blendername        = sys.argv[1]
    rendername         = sys.argv[2]
    foldernames        = sys.argv[3]
    matlabname         = sys.argv[4]
    matlabfunctionname = sys.argv[5]
    nprocesses         = sys.argv[6]

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

proclog = open("simUASrender_log.log",'at')
try:
    # detect already processed or processing folders
    for i, fname in enumerate(folders):
        logname.append(fname + "/proc/autorender.log")
        procind.append(i+1)
        if os.exist(fname + "/proc/autorender.log"):
            nexist = nexist+1
    print('{:3d}/{:3d} ALREADY EXIST'.format(nexist,nfolders)
    proclog.write('{:3d}/{:3d} ALREADY EXIST'.format(nexist,nfolders) + '\n')

    # loop through folders that hadnt been processed at start
    for fname,i,logfile in zip(folders,procind,logname):
        # skip the file if it is already being processed
        if not os.path.exists(logfile):
            currentind.append(i)
            # open logfile to indicate it's being processed
            currentlognames.append(logfile)
            iloghandle = open(logfile,'wt')
            iloghandle.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + "\n")
            iloghandle.write(getpass.getuser() + "\n")
            iloghandle.flush()
            iloghandle.close()
            # Print status to screen
            print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : START : " + '{:3d}/{:3d}'.format(i,nfiles) + " : " + fname)
            proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : START : " + '{:3d}/{:3d}'.format(i,nfiles) + " : " + fname + '\n')

            # start processing
            dname,foo = os.path.split(rendername)
          
            cmd = 
            processes.append()#ADD COMMANDS HERE
            procname.append(fname)

            # loop while processes are maxed out
            while len(processes)>=nprocesses:
                # sleep
                time.sleep(SLEEPTIME)
                if DODEBUG:
                    
                # if debug print stuff to screen
                # search through each process to see if its done
                    # if its done print output saying so
                # trim the process, ind, name, and logname to reflect finished process

    # keep looping until all processes are finished
except KeyboardInterrupt:
    # close down all processes and remove flags
    
# flush processing log
