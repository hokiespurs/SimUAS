import subprocess
import glob
import os
import time
import sys
import xml.etree.ElementTree as ET
import getpass
import psutil

if len(sys.argv)==1:
    photoscanname = r"C:\Program Files\Agisoft\PhotoScan Pro\photoscan.exe"
    scriptname    = r"C:\Users\slocumr.ONID\github\SimUAS\batchphotoscan\agiproc.py"
    xmlnames      = r"F:\bathytestdata2/BATHY*/proc/settings/*.xml"
    nprocesses    = 1
else:
    photoscanname = sys.argv[1]
    scriptname    = sys.argv[2]
    xmlnames      = sys.argv[3]
    nprocesses    = 1

SLEEPTIME = 30
DODEBUG = True

# get xmlfiles
xmlfiles = glob.glob(xmlnames)
nfiles = len(xmlfiles)

# empty lists
processes = []
procname = []
procind = []
logname = []
currentloghandles = []
currentind = []

proclog = open("simUASagiproc_log.log",'at')
try:
    # detect already processed or processing folders
    nexist = 0
    for i,fname in enumerate(xmlfiles):
        rootdir,f = os.path.split(fname)
        rootoutput = ET.parse(fname).getroot().find('export').get('rootname')
        logname.append( rootdir + "/" + rootoutput + "/autoproc.log" )
        procind.append(i)
        if os.path.exists(rootdir + "/" + rootoutput + "/autoproc.log"):
            nexist = nexist+1
    print('{:3d}/{:3d} ALREADY EXIST'.format(nexist,nfiles))
    proclog.write('{:3d}/{:3d} ALREADY EXIST'.format(nexist,nfiles) + '\n')
    for fname,i,logfile in zip(xmlfiles,procind,logname):
        i = i+1
        if not os.path.exists(logfile):

            currentind.append(i)
            print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : START : " + '{:3d}/{:3d}'.format(i,nfiles) + " : " + fname)
            proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : START : " + '{:3d}/{:3d}'.format(i,nfiles) + " : " + fname + '\n')
            foldername,foo = os.path.split(logfile)
            if not os.path.exists(foldername):
                os.makedirs(foldername)
            iloghandle = open(logfile,'wt')
            iloghandle.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + "\n")
            iloghandle.write(getpass.getuser() + "\n")
            iloghandle.flush()
            currentloghandles.append(iloghandle)
            processes.append(subprocess.Popen([photoscanname,"-r",scriptname,fname],stdin=iloghandle, stdout=iloghandle, stderr=iloghandle))
            procname.append(fname)
            while len(processes)>=nprocesses:
                time.sleep(SLEEPTIME)
                if DODEBUG:
                    cpu_percent = psutil.cpu_percent()
                    ram_percent = psutil.virtual_memory().percent
                    print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + ' CPU: {:5.1f}  RAM: {:5.1f}'.format(cpu_percent,ram_percent))
                    proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + ' CPU: {:5.1f}  RAM: {:5.1f}'.format(cpu_percent,ram_percent) + '\n')
                for p, ind, name, log in zip(processes, currentind, procname, currentloghandles):
                    if p.poll() is not None:
                        print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : DONE  : " + '{:3d}/{:3d}'.format(ind,nfiles) + " : " + fname)
                        proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : DONE  : " + '{:3d}/{:3d}'.format(ind,nfiles) + " : " + fname + '\n')
                        iloghandle.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + "\n")
                        iloghandle.flush()
                        iloghandle.close()
                procname[:] = [n for n,p in zip(procname,processes) if p.poll() is None]
                currentind[:] = [ind for ind,p in zip(currentind,processes) if p.poll() is None]
                currentloghandles[:] = [log for log,p in zip(currentloghandles,processes) if p.poll() is None]
                processes[:] = [p for p in processes if p.poll() is None]
            
    # Wait for everything to finish
    while len(processes)>0:
        time.sleep(SLEEPTIME)
        if DODEBUG:
            cpu_percent = psutil.cpu_percent()
            ram_percent = psutil.virtual_memory().percent
            print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + ' CPU: {:5.1f}  RAM: {:5.1f}'.format(cpu_percent,ram_percent))
            proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + ' CPU: {:5.1f}  RAM: {:5.1f}'.format(cpu_percent,ram_percent) + '\n')
        for p, ind, name, log in zip(processes, currentind, procname, currentloghandles):
            if p.poll() is not None:
                print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : DONE  : " + '{:3d}/{:3d}'.format(ind,nfiles) + " : " + fname)
                proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : DONE  : " + '{:3d}/{:3d}'.format(ind,nfiles) + " : " + fname + '\n')
                iloghandle= log
                iloghandle.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + "\n")
                iloghandle.flush()
                iloghandle.close()
        procname[:] = [n for n,p in zip(procname,processes) if p.poll() is None]
        currentind[:] = [ind for ind,p in zip(currentind,processes) if p.poll() is None]
        currentloghandles[:] = [log for log,p in zip(currentloghandles,processes) if p.poll() is None]
        processes[:] = [p for p in processes if p.poll() is None]
except KeyboardInterrupt:
    for p, ind, name, iloghandle in zip(processes, currentind, procname, currentloghandles):
        print(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : KILL  : " + '{:3d}/{:3d}'.format(ind,nfiles) + " : " + name)
        proclog.write(time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())) + " : KILL  : " + '{:3d}/{:3d}'.format(ind,nfiles) + " : " + name + '\n')
        p.kill()
        iloghandle.flush()
        iloghandle.close()
        time.sleep(0.1)
        os.remove(logname[ind-1])
proclog.flush()
proclog.close()
print("Done")
