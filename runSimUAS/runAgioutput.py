import subprocess
import time
import datetime
import glob
import os

photoscanname = r"C:\Program Files\Agisoft\PhotoScan Pro\photoscan.exe"
scriptname    = r"C:\Users\slocumr\github\SimUAS\batchphotoscan\agioutput.py"
projdirs =r"P:\Slocum\USVI_project\01_DATA\20180319_USVI_UAS_BATHY\02_PROCDATA\06_PROCIMAGES\*\06_QUICKPROC\*\*.psx"

projnames = glob.glob(projdirs)
nfiles = len(projnames)

for i,projname in enumerate(projnames):
    dname, justname = os.path.split(projname)
    
    markername = dname + '\\markers.txt'
    print("(%d/%d) " %(i+1,nfiles),end='')
    if not os.path.isfile(markername):
        

        tstart = datetime.datetime.now()

        p = subprocess.Popen([photoscanname,"-r",scriptname,projname])

        
    
    
        print(justname.ljust(60) + "... " + time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())),end='')

        while p.poll() is None:
            time.sleep(1)

        tend = datetime.datetime.now()
        dt = tend-tstart
        d = datetime.datetime(1,1,1)+dt
        print(" | %02d:%02d:%02d" % (d.hour, d.minute, d.second))
    else:
        print(justname.ljust(60) + "... already exists")
