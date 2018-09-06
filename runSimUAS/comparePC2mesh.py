import subprocess
import glob
import os
import time

CC = r"C:\Program Files\CloudCompare\CloudCompare.exe"
objname = r"O:\simUAS\EXPERIMENTS\TOPOHOLE\TOPOFIELDHOLE\output\model\obj\allmodel.obj"
lasdir = r"O:\simUAS\EXPERIMENTS\TOPOHOLE\TOPOFIELDHOLE\proc\results\setting03\las\*high*.las"

lasnames = glob.glob(lasdir)
nlas = len(lasnames)

for lasname in lasnames:    
    print(lasname)
    ccString = CC + ' -SILENT -o ' + lasname + ' -o ' + objname + ' -c2m_dist'
    ccString = ccString + ' -C_EXPORT_FMT ASC -PREC 3 -ADD_HEADER -SAVE_CLOUDS'

    subprocess.call(ccString)
