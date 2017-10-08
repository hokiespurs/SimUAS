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
    renderargs         = r""
    foldernames        = r"U:\presentations\Farid\2017-09-20 DPQF\SIMULATION*"
    matlabname         = r"C:\Program Files\MATLAB\R2017a\bin\matlab.exe"
    matlabfunctionname = r"C:\Users\slocumr.ONID\github\SimUAS\matlab\postprocess\postProcFolder"
    nprocesses         = 1
else:
    blendername        = sys.argv[1]
    rendername         = sys.argv[2]
    foldernames        = sys.argv[3]
    matlabname         = sys.argv[4]
    matlabfunctionname = sys.argv[5]
    nprocesses         = sys.argv[6]

SLEEPTIME = 120
DODEBUG = True

# Get Folder Names
folders = glob.glob(foldernames)
nfolders = len(folders)

# Preallocate
processes = []
procname  = []
procind   = []
logname   = []
currentloghandles = []
currentind        = []

proclog = open("simUASrender_log.log",'at')
try:
    # detect already processed or processing folders
    nexist=0
    for i, fname in enumerate(folders):
        logname.append(fname + "/output/autorender.log")
        procind.append(i+1)
        if os.path.exists(fname + "/output/autorender.log"):
            nexist = nexist+1
    print('{:3d}/{:3d} ALREADY EXIST'.format(nexist,nfolders))
    proclog.write('{:3d}/{:3d} ALREADY EXIST'.format(nexist,nfolders) + '\n')
          
    # loop through folders that hadnt been processed at start
    for fname,i,logfile in zip(folders,procind,logname):
        # skip the file if it is already being processed
        if not os.path.exists(logfile):
            currentind.append(i)
            # open logfile to indicate it's being processed
            if not os.path.exists(os.path.dirname(logfile)):
                os.makedirs(os.path.dirname(logfile))
            iloghandle = open(logfile,'wt')
            iloghandle.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + "\n")
            iloghandle.write(getpass.getuser() + "\n")
            iloghandle.flush()
            currentloghandles.append(iloghandle)
            # Print status to screen
            print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : START : " + '{:3d}/{:3d}'.format(i,nfolders) + " : " + fname)
            proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : START : " + '{:3d}/{:3d}'.format(i,nfolders) + " : " + fname + '\n')

            # start processing
            dname,foo = os.path.split(rendername)

            experimentName = fname
            blenderrendercmd = blendername + " --background --python \"" + rendername + "\" -- \"" + experimentName + "\" " + renderargs
            matdir, matfun = os.path.split(matlabfunctionname)
            matlabpostproccmd = '\"' + matlabname + "\" -wait -r \"cd(\'" + matdir + '\');' + matfun + '(\'' + experimentName + '\',1,\'\')\"'
            fullcmd = blenderrendercmd + "&" + matlabpostproccmd
            processes.append(subprocess.Popen(fullcmd,stdin=iloghandle, stdout=iloghandle, stderr=iloghandle,shell=True))
            procname.append(fname)

            # loop while processes are maxed out
            while len(processes)>=nprocesses:
                # sleep
                time.sleep(SLEEPTIME)
                if DODEBUG:
                    # if debug print stuff to screen
                    cpu_percent = psutil.cpu_percent()
                    ram_percent = psutil.virtual_memory().percent
                    print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + ' CPU: {:5.1f}  RAM: {:5.1f}'.format(cpu_percent,ram_percent))
                    proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + ' CPU: {:5.1f}  RAM: {:5.1f}'.format(cpu_percent,ram_percent) + '\n')
                # search through each process to see if its done
                for p, ind, name, iloghandle in zip(processes, currentind, procname, currentloghandles):
                    if p.poll() is not None:
                        # if its done print output saying so
                        print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : DONE  : " + '{:3d}/{:3d}'.format(ind,nfolders) + " : " + name)
                        proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : DONE  : " + '{:3d}/{:3d}'.format(ind,nfolders) + " : " + name + '\n')
                        iloghandle.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + "\n")
                        iloghandle.flush()
                        iloghandle.close()
                # trim the process, ind, name, and logname to reflect finished process
                procname[:] = [n for n,p in zip(procname,processes) if p.poll() is None]
                currentind[:] = [ind for ind,p in zip(currentind,processes) if p.poll() is None]
                currentloghandles[:] = [log for log,p in zip(currentloghandles,processes) if p.poll() is None]
                processes[:] = [p for p in processes if p.poll() is None]
    # keep looping until all processes are finished
    while len(processes)>0:
        time.sleep(SLEEPTIME)
        if DODEBUG:
            cpu_percent = psutil.cpu_percent()
            ram_percent = psutil.virtual_memory().percent
            print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + ' CPU: {:5.1f}  RAM: {:5.1f}'.format(cpu_percent,ram_percent))
            proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + ' CPU: {:5.1f}  RAM: {:5.1f}'.format(cpu_percent,ram_percent) + '\n')
        for p, ind, name, iloghandle in zip(processes, currentind, procname, currentloghandles):
            if p.poll() is not None:
                print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : DONE  : " + '{:3d}/{:3d}'.format(ind,nfolders) + " : " + name)
                proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : DONE  : " + '{:3d}/{:3d}'.format(ind,nfolders) + " : " + name + '\n')
                iloghandle.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + "\n")
                iloghandle.flush()
                iloghandle.close()
        procname[:] = [n for n,p in zip(procname,processes) if p.poll() is None]
        currentind[:] = [ind for ind,p in zip(currentind,processes) if p.poll() is None]
        currentloghandles[:] = [log for log,p in zip(currentloghandles,processes) if p.poll() is None]
        processes[:] = [p for p in processes if p.poll() is None]
except KeyboardInterrupt:
    # close down all processes and remove flags
    for p, ind, name, iloghandle in zip(processes, currentind, procname, currentloghandles):
        print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : KILL  : " + '{:3d}/{:3d}'.format(ind,nfolders) + " : " + name)
        proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : KILL  : " + '{:3d}/{:3d}'.format(ind,nfolders) + " : " + name + '\n')
        p.kill()
        iloghandle.flush()
        iloghandle.close()
        time.sleep(0.1)
        # doesnt delete file! fix this!
        
proclog.flush()
proclog.close()
print("Done")
