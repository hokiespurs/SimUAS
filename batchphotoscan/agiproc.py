import xml.etree.ElementTree as ET
import logging
import sys
import Photoscan
import glob
import time
import numpy as np

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

        sceneroot = tree.getroot()
        if sceneroot.tag != 'procsettings':
            logging.error('XML doesnt start with <procsettings> tag')
            logging.error('XML Name= ' + xmlName)
            print('ERROR:  XML file doesnt start with a <procsettings> tag')
            raise SyntaxError

        self.projectname = sceneroot.get('projectname')
        # Read Import Files
        self.objectdb = sceneroot.get('objectdb')
        self.version = sceneroot.get('version')

        # Read Photoscan Processing Parameters


        # Read Export Info



# Set up agiproc logfile
LOGFORMAT = "[%(asctime)s] %(funcName)s: %(message)s"
logging.basicConfig(filename="proc.log", level=logging.DEBUG, format=LOGFORMAT)
logging.debug('logger opened')
logging.info(sys.version)

argv = sys.argv

ProcParams = ProcSettings(argv[0])
# PHOTOSCAN PROCESSING
# get main app objects
doc = PhotoScan.app.document
app = PhotoScan.Application()

# create chunk
chunk = PhotoScan.Chunk()
chunk.label = "New_Chunk"
doc.chunks.add(chunk)

# FIND ALL PHOTOS IN PATH
AerialImageFiles = glob.glob(AerialImagesPattern)
