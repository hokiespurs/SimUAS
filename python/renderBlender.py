import sys
import logging
import os
import glob

# parse arguments and add relative python paths
argv = sys.argv
try:
    argv = argv[argv.index("--") + 1:]
    rootname = os.path.dirname(os.path.dirname(__file__))
    experimentName = rootname + '/' + argv[0]
    dorender = True
    sys.path.append(os.path.dirname(__file__))
except ValueError:
    experimentName = 'C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest\\data\\lightnmove'
    rootname = 'C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest'
    addpathname = rootname + '\\python'
    sys.path.append(addpathname)
    dorender = False

from myScene import *
from mySensor import *
from myTrajectory import *
from pyblender import *

def makedir(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)


def run():

    # Make Folder Structure
    outputFolder = experimentName + "/output/"
    procFolder = experimentName + "/proc/"
    imageFolder = experimentName + "/output/images/pre/"
    imageFolderPre = experimentName + "/output/images/pre/"
    modelFolder = experimentName + "/output/model/"
    logFolder = experimentName + "/output/log/"
    logfilename = "renderblender.log"
    makedir(outputFolder)
    makedir(imageFolder)
    makedir(imageFolderPre)
    makedir(modelFolder)
    makedir(logFolder)
    makedir(procFolder)

    # Set up logfile
    LOGFORMAT = "[%(asctime)s] %(funcName)s: %(message)s"
    logging.basicConfig(filename=logFolder + logfilename, level=logging.DEBUG, format=LOGFORMAT)
    logging.debug('logger opened')
    logging.info(sys.version)

    if dorender:
        logging.debug('Render = True')
    else:
        logging.debug('Render = False')
    logging.debug('experimentName = ' + experimentName)
    logging.debug('rootname = ' + rootname)

    # Read XML Files into Classes
    xmlScene = glob.glob(experimentName + '/input/scene*.xml')[0]
    xmlSensor = glob.glob(experimentName + '/input/sensor*.xml')[0]
    xmlTrajectory = glob.glob(experimentName + '/input/trajectory*.xml')[0]
    BlenderScene = Scene(xmlScene)
    BlenderSensor = Sensor(xmlSensor)
    BlenderTrajectory = Trajectory(xmlTrajectory)

    # Output Control/Fiducial/Trajectory Files
    BlenderScene.writeControlXYZ(outputFolder + "xyzcontrol.csv")
    BlenderScene.writeFiducialXYZ(outputFolder + "xyzfiducial.csv", rootname)
    BlenderSensor.writeXML(outputFolder + "Sensor")
    BlenderTrajectory.writecsv(outputFolder + "Trajectory.csv")

    # Generate Scene
    buildScene(BlenderScene, rootname)

    # Output OBJ File

    # Apply Render Parameters
    applyRenderSettings(BlenderSensor)


    # Place Cameras
    addCameras(BlenderTrajectory, BlenderSensor)

    if dorender:
        # Render images
        render(BlenderTrajectory, BlenderSensor, imageFolderPre)

if __name__ == '__main__':
    run()