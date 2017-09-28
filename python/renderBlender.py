import sys
import logging
import os
import glob

# parse arguments and add relative python paths
argv = sys.argv
doallmodel = False
try:
    argv = argv[argv.index("--") + 1:] #throws ValueError if not from Blender
    nargs = len(argv)
    print(nargs)
    print(argv)
    if nargs==1: # default when run from blender
        dorender = True
        experimentName = argv[0]
        rootname = os.path.dirname(os.path.dirname(__file__))
    elif nargs==2:
        dorender = True
        experimentName = argv[0]
        if argv[1]=='-allmodel':
            doallmodel = True
            rootname = os.path.dirname(os.path.dirname(__file__))			
        else:
            rootname = argv[1]
    elif nargs==3:
        dorender = True
        experimentName = argv[0]
        rootname = argv[1]
        doallmodel = True
except ValueError: # This is supposed to be if it is running from blender
    print('Running with Default Values')
    dorender = False
    rootname = 'C:\\Users\\slocumr.ONID\\github\\SimUAS'
    experimentName = rootname + '\\data\\demobeaver'
	
sys.path.append(rootname + '\\python') #add python functions

print(rootname)

from myScene import *
from mySensor import *
from myTrajectory import *
from pyblender import *
from subprocess import call

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
    objFolder = modelFolder + 'obj/'
    orthoFolder = modelFolder + 'ortho/'
    logFolder = experimentName + "/output/log/"
    logfilename = "renderblender.log"
    makedir(outputFolder)
    makedir(imageFolder)
    makedir(imageFolderPre)
    makedir(modelFolder)
    makedir(logFolder)
    makedir(procFolder)
    makedir(objFolder)
    makedir(orthoFolder)

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
    if doallmodel:
        for iPose in BlenderTrajectory.Pose:  # output a folder with models for each image
            savefolderobj = objFolder + iPose.name + '/'
            makedir(savefolderobj)
            outputOBJ(BlenderScene, savefolderobj, iPose.t)
    else:
        outputOBJ(BlenderScene, objFolder, 0)

    if dorender:
        # Render Ortho images
        outputOrthos(BlenderTrajectory, orthoFolder)

    # Place Cameras
    addCameras(BlenderTrajectory, BlenderSensor)

    # Apply Render Parameters
    applyRenderSettings(BlenderSensor)

	
    if dorender:
        # Render images
        render(BlenderTrajectory, imageFolderPre)


if __name__ == '__main__':
    run()