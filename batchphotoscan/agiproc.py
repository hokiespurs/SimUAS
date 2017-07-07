import xml.etree.ElementTree as ET
import logging
import sys
#import Photoscan
from glob import glob
import time
import numpy as np
from os.path import join

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
        self.importfiles = self.ImportFiles(procsettings.find('importfiles'))

        # Read Photoscan Processing Parameters
        self.photoscan = self.PS(procsettings.find('photoscan'))
        
        # Read Export Info
        self.export = self.Export(procsettings.find('export'))
 

    class ImportFiles:
        def __init__(self,root):
            # Read Data
            self.imagesfoldername = root.find('images').get('foldername')
            self.imagesimagesToUse = root.find('images').get('imagesToUse')
            self.sensorfilename = root.find('sensor').get('filename')
            self.sensorlock = root.find('sensor').get('lock')
            self.trajectoryfilename = root.find('trajectory').get('filename')
            self.controlpixfilename = root.find('controlpix').get('filename')
            self.controlxyzfilename = root.find('controlxyz').get('filename')
            self.rootname = root.get('rootname')

    class PS:
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

    class Export:
        def __init__(self,root):
            # Read Data
            self.reprocMVS = root.get('reprocMVS')
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
                                  
# Set up agiproc logfile
LOGFORMAT = "[%(asctime)s] %(funcName)s: %(message)s"
logging.basicConfig(filename="proc.log", level=logging.DEBUG, format=LOGFORMAT)
logging.debug('logger opened')
logging.info(sys.version)


##argv = sys.argv
##if argv[0]=='xml':
##    ProcParams = ProcSettings(argv[0])
##else:
##    ProcParams = ProcSettings(argv[1])                              

# HARDCODED DELETE THIS
argv = 'C:\\Users\\slocumr.ONID\\github\\SimUAS\\batchphotoscan\\example.xml'
ProcParams = ProcSettings(argv)
                                  
### PHOTOSCAN PROCESSING
### get main app objects
##doc = PhotoScan.app.document
##app = PhotoScan.Application()
##
### create chunk
##chunk = PhotoScan.Chunk()
##chunk.label = "New_Chunk"
##doc.chunks.add(chunk)

# FIND ALL PHOTOS IN PATH
ImageFiles = []
ImagePath = join(ProcParams.importfiles.rootname,ProcParams.importfiles.imagesfoldername)

print(ImagePath)

for ext in ('\*.tif', '\*.png', '\*.jpg'):
   ImageFiles.extend(glob(ImagePath + ext))
   print(ImagePath)
   print(ImagePath + ext)
   print(join(ImagePath, ext))

indexes = [2, 3, 5]
for index in sorted(indexes, reverse=True):
    del ImageFiles[index]

for imagename in ImageFiles:
    print(imagename)
