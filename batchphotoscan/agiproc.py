import xml.etree.ElementTree as ET
import logging
import sys
import PhotoScan
from glob import glob
import time
#import numpy as np
from os.path import join
import os
class ProcSettings:
    def __init__(self,xmlName):
        # Read Data from XML
        logging.debug('Reading Processing Parameters ')
        try:
            tree = ET.parse(xmlName)
        except ET.ParseError:  # could not parse the xml file
            logging.error('Unable to Parse XML File')
            logging.error('XML Name= ' + xmlName)
            print('ERROR: Unable to read XML... file is poorly formatted')
            raise

        procsettings = tree.getroot()
        if procsettings.tag != 'procsettings':
            logging.error('XML doesnt start with <procsettings> tag')
            logging.error('XML Name= ' + xmlName)
            print('ERROR:  XML file doesnt start with a <procsettings> tag')
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
            self.meshgeneralfacecount = root.find('meshgeneral').get('facecount')
            self.meshgeneralsourcedata = root.find('meshgeneral').get('sourcedata')
            self.meshgeneralsurftype = root.find('meshgeneral').get('surftype')
            self.meshadvancedinteprolation = root.find('meshadvanced').get('inteprolation')
            self.texturegeneralblendingmode = root.find('texturegeneral').get('blendingmode')
            self.texturegeneralmappingmode = root.find('texturegeneral').get('mappingmode')
            self.texturegeneraltexcount = root.find('texturegeneral').get('texcount')
            self.texturegeneraltexsize = root.find('texturegeneral').get('texsize')
            self.textureadvancedcolorcorrection = root.find('textureadvanced').get('colorcorrection')
            self.textureadvancedholefill = root.find('textureadvanced').get('holefill')
            self.tiledmodelpixelsize = root.find('tiledmodel').get('pixelsize')
            self.tiledmodelsource = root.find('tiledmodel').get('source')
            self.tiledmodeltilesize = root.find('tiledmodel').get('tilesize')
            self.demprojectioncoordinates = root.find('dem').find('projection').get('coordinates')
            self.demprojectiontype = root.find('dem').find('projection').get('type')
            self.demparamsinterpolation = root.find('dem').find('params').get('interpolation')
            self.demparamssourcedata = root.find('dem').find('params').get('sourcedata')
            self.dempixelsizeresolution = root.find('dem').find('pixelsize').get('resolution')
            self.demregionmaxx = root.find('dem').find('region').get('maxx')
            self.demregionmaxy = root.find('dem').find('region').get('maxy')
            self.demregionminx = root.find('dem').find('region').get('minx')
            self.demregionminy = root.find('dem').find('region').get('miny')
            self.orthoprojectioncoordinates = root.find('ortho').find('projection').get('coordinates')
            self.orthoprojectiontype = root.find('ortho').find('projection').get('type')
            self.orthoparamsblending = root.find('ortho').find('params').get('blending')
            self.orthoparamscolorcorr = root.find('ortho').find('params').get('colorcorr')
            self.orthoparamsholefill = root.find('ortho').find('params').get('holefill')
            self.orthoparamssurface = root.find('ortho').find('params').get('surface')
            self.orthopixelsizex = root.find('ortho').find('pixelsize').get('x')
            self.orthopixelsizey = root.find('ortho').find('pixelsize').get('y')
            self.orthoregionmaxx = root.find('ortho').find('region').get('maxx')
            self.orthoregionmaxy = root.find('ortho').find('region').get('maxy')
            self.orthoregionminx = root.find('ortho').find('region').get('minx')
            self.orthoregionminy = root.find('ortho').find('region').get('miny')
            self.orthoregionresolution = root.find('ortho').find('region').get('resolution')

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
            self.modelfilename = root.find('model').get('filename')
            self.tiledmodelfilename = root.find('tiledmodel').get('filename')
            self.orthomosaicfilename = root.find('orthomosaic').get('filename')
            self.demfilename = root.find('dem').get('filename')
            self.camcalibrationfilename = root.find('camcalibration').get('filename')
            self.camerasfilename = root.find('cameras').get('filename')
            self.markersfilename = root.find('markers').get('filename')
            self.matchesfilename = root.find('matches').get('filename')
            self.texturefilename = root.find('texture').get('filename')
            self.orthophotofilename = root.find('orthophoto').get('filename')
            self.undistortphotosfoldername = root.find('undistortphotos').get('foldername')
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

    chunk.buildDenseCloud(quality=densequal,filter=densefilt)

##argv = sys.argv
##if argv[0]=='xml':
##    ProcParams = ProcSettings(argv[0])
##else:
##    ProcParams = ProcSettings(argv[1])                              

# TEMPORARY HARDCODED-DELETE THIS
argv = 'C:\\Users\\slocumr.ONID\\github\\SimUAS\\batchphotoscan\\example.xml'
ProcParams = ProcSettings(argv)

doc = PhotoScan.app.document
app = PhotoScan.Application()

# clear project and console
app.console.clear()
doc.clear()
			
# Set up agiproc logfile (NEED TO FIX, PHOTOSCAN ALREADY USING LOGGING)
LOGFORMAT = "[%(asctime)s] %(funcName)s: %(message)s"
logname = ProcParams.export.rootname + "\\" + ProcParams.export.logfilefilename
logging.basicConfig(filename=logname, level=logging.DEBUG, format=LOGFORMAT)
logging.debug('logger opened')
logging.info(sys.version)


                                  
# FIND ALL PHOTOS IN PATH
ImageFiles = []
ImagePath = join(ProcParams.importfiles.rootname,ProcParams.importfiles.imagesfoldername)

print(ImagePath)

for ext in ('\*.tif', '\*.png', '\*.jpg'):
   ImageFiles.extend(glob(ImagePath + ext))

if len(ProcParams.importfiles.imagesToUse)==len(ImageFiles):
    print("Deleting Some Images")
    indbad = []
    for ind in range(1,len(ImageFiles)):
        if ProcParams.importfiles.imagesToUse[ind]=='0':
            indbad.append(ind)
            print("Bad: " + str(ind))
    for index in sorted(indbad, reverse=True):
        del ImageFiles[index]
else:
    print("Using All Images:")

for imagename in ImageFiles:
    print(imagename)


# Add Photos
chunk = PhotoScan.app.document.addChunk()
chunk.label = 'simUASdata'
chunk.addPhotos(ImageFiles)


# Add Sensor (Camera Calibration)
sensorname = ProcParams.importfiles.rootname + "\\" + ProcParams.importfiles.sensorfilename
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
trajectoryname = ProcParams.importfiles.rootname + "\\" + ProcParams.importfiles.trajectoryfilename
chunk.loadReference(trajectoryname)

# Add Markers
markername = ProcParams.importfiles.rootname + "\\" + ProcParams.importfiles.controlfilename
chunk.importMarkers(markername)

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
	
# align photos
if ProcParams.photoscan.alignadvancedadaptivecam=='1':
    adaptivecam = True
else:
    adaptivecam = False

chunk.alignCameras(adaptive_fitting=adaptivecam)

# optimize
chunk.optimizeCameras()

# dense pointcloud 
procDense(ProcParams.photoscan.densequality, ProcParams.photoscan.densedepthfilt)

## Save Data
saverootname = ProcParams.export.rootname
if not os.path.exists(saverootname):
    os.makedirs(saverootname)
if not os.path.exists(saverootname + "\\las"):
    os.makedirs(saverootname + "\\las")
if not os.path.exists(saverootname + "\\model"):
    os.makedirs(saverootname + "\\model")	

# Save Sparse
sparsesavename = saverootname + "\\" + ProcParams.export.sparsepointsfilename
chunk.exportPoints(sparsesavename,PhotoScan.DataSource.PointCloudData.PointCloudData)

# Save Dense
densesavename = saverootname + "\\" + ProcParams.export.densepointsfilename
chunk.exportPoints(densesavename,PhotoScan.DataSource.PointCloudData.DenseCloudData)

# Save Reproc Dense
QualityType = ['lowest','low','medium','high','ultrahigh']
FilterType = ['disabled','mild','moderate','aggressive']
mvsfolder = saverootname + "\\"  + ProcParams.export.reprocMVSfoldername
for indq,q in enumerate(ProcParams.export.reprocMVSquality):
    for indf,f in enumerate(ProcParams.export.reprocMVSdepthfilt):
        if f=='1' and q=='1':
            procDense(QualityType[indq],FilterType[indf])
            mvssavename = mvsfolder + "\\dense_" + QualityType[indq] + "_" + FilterType[indf] + ".las"
            print("Saving Dense MVS: " + mvssavename)
            chunk.exportPoints(mvssavename,PhotoScan.DataSource.PointCloudData.DenseCloudData)