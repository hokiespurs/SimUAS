# AGIRPROC.PY
#  This script is used to parse processing settings from an xml file and 
#  apply them to process a data in agisoft photoscan. It is written to 
#  follow the folder structure in simUAS.  
#
#  The settings.xml file dictates:
#     - Folders for the input/output data
#     - All processing settings
#     - Additional Output Pointclouds
#     
#  This script automatically logs all messages from photoscan, and computes
#  the processing time for each step.
#
#  Input Arguments:
#    xmlsetting : full file path to the xml settings file
#
#  Author        : Richie Slocum
#  Email         : richie.slocum@cormorantanalytics.com 
#  Date Created  : Jul 06, 2017
#  Date Modified : Jul 09, 2018
#  Github        : 

import xml.etree.ElementTree as ET
import logging
import sys
import PhotoScan
from glob import glob
import time
from time import gmtime, strftime
#import numpy as np
from os.path import join
import os
class ProcSettings:
    def __init__(self,xmlName):
        # Read Data from XML
        print('AGIPROC: Reading Processing Parameters ')
        try:
            tree = ET.parse(xmlName)
        except ET.ParseError:  # could not parse the xml file
            logging.error('Unable to Parse XML File')
            logging.error('XML Name= ' + xmlName)
            print('AGIPROC: ERROR: Unable to read XML... file is poorly formatted')
            raise

        procsettings = tree.getroot()
        if procsettings.tag != 'procsettings':
            logging.error('XML doesnt start with <procsettings> tag')
            logging.error('XML Name= ' + xmlName)
            print('AGIPROC: ERROR:  XML file doesnt start with a <procsettings> tag')
            raise SyntaxError

        self.projectname = procsettings.get('projectname')
        # Read Import Files
        self.importfiles = self.__ImportFiles(procsettings.find('importfiles'))

        # Read Photoscan Processing Parameters
        self.photoscan = self.__PS(procsettings.find('photoscan'))
        
        # Read Export Info
        self.export = self.__Export(procsettings.find('export'))

    class __ImportFiles:
        def __init__(self,root):
            # Read Data
            self.imagesfoldername = root.find('images').get('foldername')
            self.imagesToUse = root.find('images').get('imagesToUse')
            self.sensorfilename = root.find('sensor').get('filename')
            self.sensorlock = root.find('sensor').get('lock')
            self.trajectoryfilename = root.find('trajectory').get('filename')
            self.controlfilename = root.find('controldata').get('filename')
            self.rootname = root.get('rootname')
            try:
                self.epsg = root.find('crs').get('epsg')
            except:
                self.epsg = ''

    class __PS:
        def __init__(self,root):
            self.referencesettingsmeasurementaccuracycamerapos = root.find('referencesettings').find('measurementaccuracy').get('camerapos')
            self.referencesettingsmeasurementaccuracycamerarot = root.find('referencesettings').find('measurementaccuracy').get('camerarot')
            self.referencesettingsmeasurementaccuracymarker = root.find('referencesettings').find('measurementaccuracy').get('marker')
            self.referencesettingsmeasurementaccuracyscalebar = root.find('referencesettings').find('measurementaccuracy').get('scalebar')
            self.referencesettingsimageaccuracymarker = root.find('referencesettings').find('imageaccuracy').get('marker')
            self.referencesettingsimageaccuracytiepoint = root.find('referencesettings').find('imageaccuracy').get('tiepoint')
            self.referencesettingsmiscellaneousgroundalt = root.find('referencesettings').find('miscellaneous').get('groundalt')
            self.optimizeexecute = root.find('optimize').get('execute')
            self.optimizefits = root.find('optimize').get('fits')
            self.aligngeneralaccuracy = root.find('aligngeneral').get('accuracy')
            self.aligngeneralgenericpre = root.find('aligngeneral').get('genericpre')
            self.aligngeneralreferencepre = root.find('aligngeneral').get('referencepre')
            self.alignadvancedadaptivecam = root.find('alignadvanced').get('adaptivecam')
            self.alignadvancedkeypointlim = root.find('alignadvanced').get('keypointlim')
            self.alignadvancedmaskconstrain = root.find('alignadvanced').get('maskconstrain')
            self.alignadvancedtiepointlim = root.find('alignadvanced').get('tiepointlim')
            self.densedepthfilt = root.find('dense').get('depthfilt')
            self.densequality = root.find('dense').get('quality')

    class __Export:
        def __init__(self,root):
            # Read Data
            self.reprocMVSfoldername = root.find('reprocMVS').get('foldername')
            self.reprocMVSquality = root.find('reprocMVS').get('quality')
            self.reprocMVSdepthfilt = root.find('reprocMVS').get('depthfilt')
            self.logfilefilename = root.find('logfile').get('filename')
            self.PhotoscanReportfilename = root.find('PhotoscanReport').get('filename')
            self.sparsepointsfilename = root.find('sparsepoints').get('filename')
            self.densepointsfilename = root.find('densepoints').get('filename')
            self.camcalibrationfilename = root.find('camcalibration').get('filename')
            self.camerasfilename = root.find('cameras').get('filename')
            self.markersfilename = root.find('markers').get('filename')
            self.matchesfilename = root.find('matches').get('filename')
            self.rootname = root.get('rootname')

def procDense(qualityval, filterval):
    if qualityval=='lowest':
        densequal = PhotoScan.Quality.LowestQuality
    elif qualityval=='low':
        densequal = PhotoScan.Quality.LowQuality
    elif qualityval=='medium':
        densequal = PhotoScan.Quality.MediumQuality
    elif qualityval=='high':
        densequal = PhotoScan.Quality.HighQuality
    elif qualityval=='ultrahigh':
        densequal = PhotoScan.Quality.UltraQuality

    if filterval=='disabled':
        densefilt = PhotoScan.FilterMode.NoFiltering
    elif filterval=='mild':
        densefilt = PhotoScan.FilterMode.MildFiltering
    elif filterval=='moderate':
        densefilt = PhotoScan.FilterMode.ModerateFiltering
    elif filterval=='aggressive':
        densefilt = PhotoScan.FilterMode.AggressiveFiltering

    #Noticed Change in API with 1.4.1
    try:
        chunk.buildDepthMaps(quality=densequal,filter=densefilt)
        chunk.buildDenseCloud()
    except:
        chunk.buildDenseCloud(quality=densequal,filter=densefilt)

def elaptime(starttime,endtime):
    hours, rem = divmod(endtime-starttime, 3600)
    minutes, seconds = divmod(rem, 60)
    return("{:0>3}:{:0>2}:{:05.2f}".format(int(hours),int(minutes),seconds))

## Read XML File
if len(sys.argv)==1:
    argv = 'C:\\Users\\slocumr.ONID\\github\\SimUAS\\batchphotoscan\\example.xml'
    xmlname = argv
else:
    xmlname = sys.argv[1]
ProcParams = ProcSettings(xmlname)
procstarttime = time.time()

rootdir, name = os.path.split(xmlname)

# Make output directories 
# Make Directories
saverootname = rootdir + "\\" + ProcParams.export.rootname
if not os.path.exists(saverootname):
    os.makedirs(saverootname)
if not os.path.exists(saverootname + "\\las"):
    os.makedirs(saverootname + "\\las")

# Make Processing Time Logfile
proctimelogname = rootdir + "\\" + ProcParams.export.rootname + "\\proctime.log"
proctime = open(proctimelogname,"wt")
msg = "Initialized"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , HHH:MM:SS\n")
lasttime = time.time()
proctime.flush()

# Photoscan Convenience Variables
doc = PhotoScan.app.document
app = PhotoScan.Application()

# clear project and console
app.console.clear()
doc.clear()

# FIND ALL PHOTOS IN PATH
ImageFiles = []
ImagePath = join(rootdir + "\\" + ProcParams.importfiles.rootname,ProcParams.importfiles.imagesfoldername)
print(ImagePath)

for ext in ('\*.tif', '\*.png', '\*.jpg', '\*.dng'):
   ImageFiles.extend(sorted(glob(ImagePath + ext)))


if (len(ProcParams.importfiles.imagesToUse)!=0):
    print("Deleting Some Images")
    indbad = []
    for ind in range(0,len(ImageFiles)):
        if (len(ProcParams.importfiles.imagesToUse)-1 < ind):
            indbad.append(ind)
            print("Dont Use: " + str(ind))
        elif ProcParams.importfiles.imagesToUse[ind]=='0':
            indbad.append(ind)
            print("Done Use: " + str(ind))
    for index in sorted(indbad, reverse=True):
        del ImageFiles[index-1]
else:
    print("Using all images")

for imagename in ImageFiles:
    print(imagename)

msg = "Found Images"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# Add Photos
chunk = PhotoScan.app.document.addChunk()
chunk.label = 'agiprocdata'
chunk.addPhotos(ImageFiles,strip_extensions=False)

msg = "Added Photos"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# Add Sensor (Camera Calibration)
if ProcParams.importfiles.sensorfilename!='':
    sensorname = rootdir + "\\" + ProcParams.importfiles.rootname + "\\" + ProcParams.importfiles.sensorfilename
    calib = PhotoScan.Calibration()
    calib.load(sensorname)
    sensor = chunk.sensors[0]
    sensor.label = 'simUASsensor'
    sensor.user_calib = calib
    if ProcParams.importfiles.sensorlock=='1':
        sensor.fixed = True

# Set Reference Settings (Do before loading stuff so accuracy isnt overwritten)
camlocacc = float(ProcParams.photoscan.referencesettingsmeasurementaccuracycamerapos)
chunk.camera_location_accuracy = [camlocacc,camlocacc,camlocacc]

camrotacc = float(ProcParams.photoscan.referencesettingsmeasurementaccuracycamerarot)
chunk.camera_rotation_accuracy = [camrotacc,camrotacc,camrotacc]

markacc = float(ProcParams.photoscan.referencesettingsmeasurementaccuracymarker)
chunk.marker_location_accuracy = [markacc,markacc,markacc]

chunk.scalebar_accuracy = float(ProcParams.photoscan.referencesettingsmeasurementaccuracyscalebar)
chunk.marker_projection_accuracy = float(ProcParams.photoscan.referencesettingsimageaccuracymarker)
chunk.tiepoint_accuracy = float(ProcParams.photoscan.referencesettingsimageaccuracytiepoint)
if ProcParams.photoscan.referencesettingsmiscellaneousgroundalt =="":
    chunk.elevation = None
else:
    chunk.elevation = float(ProcParams.photoscan.referencesettingsmiscellaneousgroundalt)

# Add Trajectory
if ProcParams.importfiles.trajectoryfilename!="":
    trajectoryname = rootdir + "\\" + ProcParams.importfiles.rootname + "\\" + ProcParams.importfiles.trajectoryfilename
    chunk.loadReference(trajectoryname)

# Add Markers
if ProcParams.importfiles.controlfilename!="":
    markername = rootdir + "\\" + ProcParams.importfiles.rootname + "\\" + ProcParams.importfiles.controlfilename
    chunk.importMarkers(markername)

# DEFINE COORDINATE SYSTEM
if not (ProcParams.importfiles.epsg==''):
    doc.chunk.crs = PhotoScan.CoordinateSystem("EPSG::" + ProcParams.importfiles.epsg)
else:
    print("Using PhotoScan Default CRS")

msg = "Added Trajectory/Reference Data"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

## Do Sparse Alignment
# Match Photos
if ProcParams.photoscan.aligngeneralaccuracy == 'lowest':
    matchacc = PhotoScan.Accuracy.LowestAccuracy
elif ProcParams.photoscan.aligngeneralaccuracy == 'low':
    matchacc = PhotoScan.Accuracy.LowAccuracy
elif ProcParams.photoscan.aligngeneralaccuracy == 'medium':
    matchacc = PhotoScan.Accuracy.MediumAccuracy
elif ProcParams.photoscan.aligngeneralaccuracy == 'high':
    matchacc = PhotoScan.Accuracy.HighAccuracy
elif ProcParams.photoscan.aligngeneralaccuracy == 'highest':
    matchacc = PhotoScan.Accuracy.HighestAccuracy

if ProcParams.photoscan.aligngeneralgenericpre=='1':
    genpre = True
else:
    genpre = False
	
if ProcParams.photoscan.aligngeneralreferencepre=='1':
    refpre = True
else:
    refpre = False

nkeypoints = int(ProcParams.photoscan.alignadvancedkeypointlim)
ntiepoints = int(ProcParams.photoscan.alignadvancedtiepointlim)

chunk.matchPhotos(accuracy=matchacc,\
    generic_preselection=genpre,\
    reference_preselection=refpre,\
    keypoint_limit = nkeypoints,\
    tiepoint_limit = ntiepoints)

msg = "Matched Photos"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# align photos
if ProcParams.photoscan.alignadvancedadaptivecam=='1':
    adaptivecam = True
else:
    adaptivecam = False

chunk.alignCameras(adaptive_fitting=adaptivecam)

msg = "Aligned Photos"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# optimize
if ProcParams.photoscan.optimizeexecute=='1':
    fitf = ProcParams.photoscan.optimizefits[0]=='1'
    fitcx = ProcParams.photoscan.optimizefits[1]=='1'
    fitcy = ProcParams.photoscan.optimizefits[2]=='1'
    fitb1 = ProcParams.photoscan.optimizefits[3]=='1'
    fitb2 = ProcParams.photoscan.optimizefits[4]=='1'
    fitk1 = ProcParams.photoscan.optimizefits[5]=='1'
    fitk2 = ProcParams.photoscan.optimizefits[6]=='1'
    fitk3 = ProcParams.photoscan.optimizefits[7]=='1'
    fitk4 = ProcParams.photoscan.optimizefits[8]=='1'
    fitp1 = ProcParams.photoscan.optimizefits[9]=='1'
    fitp2 = ProcParams.photoscan.optimizefits[10]=='1'
    fitp3 = ProcParams.photoscan.optimizefits[11]=='1'
    fitp4 = ProcParams.photoscan.optimizefits[12]=='1'
    fitshutter = ProcParams.photoscan.optimizefits[13]=='1'
    chunk.optimizeCameras(fitf,fitcx,fitcy,fitb1,fitb2,\
        fitk1,fitk2,fitk3,fitk4,fitp1,fitp2,fitp3,fitp4,fitshutter)
    msg = "Optimization Complete"
    proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
    lasttime = time.time()
    proctime.flush()

# Reset Region
chunk.resetRegion()

# dense pointcloud 
procDense(ProcParams.photoscan.densequality, ProcParams.photoscan.densedepthfilt)
msg = "Dense Reconstruction Complete"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

## Save Data

# Save Sparse
sparsesavename = saverootname + "\\" + ProcParams.export.sparsepointsfilename
chunk.exportPoints(sparsesavename,PhotoScan.DataSource.PointCloudData.PointCloudData,projection=doc.chunk.crs)
msg = "Saved Sparse"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# Save Dense
densesavename = saverootname + "\\" + ProcParams.export.densepointsfilename
chunk.exportPoints(densesavename,PhotoScan.DataSource.PointCloudData.DenseCloudData,projection=doc.chunk.crs)
msg = "Saved Dense"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# Save Project
projsavename = saverootname + "\\" + ProcParams.projectname + ".psz"
doc.save(projsavename)
msg = "Saved Project"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# Export Report
reportsavename = saverootname + "\\" + ProcParams.export.PhotoscanReportfilename
chunk.exportReport(reportsavename,"simUAS:" + ProcParams.projectname,\
    "Data was processed automatically using agiproc.py with: \n" + xmlname)
msg = "Saved Report"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# Export Camera Calibration File
calibrationsavename = saverootname + "\\" + ProcParams.export.camcalibrationfilename
camCal = chunk.sensors[0]
camCal.calibration.save(calibrationsavename)
msg = "Saved Camera Calibration"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# Export Trajectory (Cameras)
trajectorysavename = saverootname + "\\" + ProcParams.export.camerasfilename
chunk.exportCameras(trajectorysavename)
msg = "Saved Trajectory"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()
proctime.flush()

# Export Markers
if ProcParams.export.markersfilename!='':
    markersavename = saverootname + "\\" + ProcParams.export.markersfilename
    chunk.exportMarkers(markersavename)

# Export Matches
if ProcParams.export.matchesfilename!='':
    matchessavename = saverootname + "\\" + ProcParams.export.matchesfilename
    chunk.exportMatches(matchessavename)

# Save Reproc Dense
QualityType = ['lowest','low','medium','high','ultrahigh']
FilterType = ['disabled','mild','moderate','aggressive']
mvsfolder = saverootname + "\\"  + ProcParams.export.reprocMVSfoldername
for indq,q in enumerate(ProcParams.export.reprocMVSquality):
    for indf,f in enumerate(ProcParams.export.reprocMVSdepthfilt):
        if f=='1' and q=='1':
            procDense(QualityType[indq],FilterType[indf])
            msg = "MVS Dense Processing (" + QualityType[indq] + "," + FilterType[indf] + ")"
            proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
            lasttime = time.time()
            mvssavename = mvsfolder + "\\dense_" + QualityType[indq] + "_" + FilterType[indf] + ".las"
            print("Saving Dense MVS: " + mvssavename)
            chunk.exportPoints(mvssavename,PhotoScan.DataSource.PointCloudData.DenseCloudData,projection=doc.chunk.crs)
            msg = "MVS Dense Saving (" + QualityType[indq] + "," + FilterType[indf] + ")"
            proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
            lasttime = time.time()
            proctime.flush()
			
# Save Log File
logsavename = saverootname + "\\" + ProcParams.export.logfilefilename
file = open(logsavename,"wt")
file.write(app.console.contents)
file.flush()
file.close()
msg = "Save Log File"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(lasttime,time.time()) +"\n")
lasttime = time.time()

# Close ProcTime Logfile
msg = "Total"
proctime.write(msg.ljust(40) + " , " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " , " + elaptime(procstarttime,time.time()) +"\n")
proctime.flush()
proctime.close()
