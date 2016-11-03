import bpy
import xml.etree.ElementTree as ET
from math import pi
import glob
import sys
import logging
import csv
import os
import copy
import numpy as np
import math
import time
from subprocess import call

# my scripts
argv = sys.argv

try:
    argv = argv[argv.index("--") + 1:]
    rootname = os.path.dirname(os.path.dirname(__file__))
    experimentName = rootname + '/' + argv[0]
    dorender = True
    sys.path.append(os.path.dirname(__file__))
except ValueError:
    experimentName = 'C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest\\data\\calroom'
    rootname = 'C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest'
    addpathname = rootname + '\\python'
    sys.path.append(addpathname)
    dorender = False

from class_Scene import *
from class_Trajectory import *
from class_Sensor import *


class Triplet:
    def __init__(self, x, y, z, names=''):
        self.x = x
        self.y = y
        self.z = z
        if isinstance(x, list):
            if len(names) < len(x):
                names = []
                for i in range(len(x)):
                    buf = "%03.0d" % i
                    names.append(buf)

        self.names = names


def wipe():
    logging.info("Clearing all existing blender objects")
    scene = bpy.context.scene
    objs = bpy.data.objects
    meshes = bpy.data.meshes
    datcams = bpy.data.cameras.data.cameras
    cameras = bpy.data.cameras

    for obj in objs:
        scene.objects.unlink(obj)
        objs.remove(obj)

    for mesh in meshes:
        meshes.remove(mesh)

    for icam in datcams:
        bpy.data.cameras.remove(icam)

    for cam in cameras:
        cameras.remove(cam)


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

    # Read XML Files into Classes
    xmlScene = glob.glob(experimentName + '/input/scene*.xml')[0]
    xmlSensor = glob.glob(experimentName + '/input/sensor*.xml')[0]
    xmlTrajectory = glob.glob(experimentName + '/input/trajectory*.xml')[0]
    myScene = Scene(xmlScene, rootname)
    mySensor = Sensor(xmlSensor)
    myTrajectory = Trajectory(xmlTrajectory)

    # Generate Scene
    wipe() #clears anything in the scene
    myScene.build()

    # Apply Sensor Parameters
    mySensor.apply()

    # Output Files
    myTrajectory.writecsv(outputFolder + "Trajectory.csv")                                        # Trajectory CSV
    mySensor.writeXML(outputFolder + "Sensor")                                                    # Sensor XML
    myScene.saveOBJ(modelFolder)                                                                  # OBJ files
    myScene.writeControlXYZ(outputFolder + "xyzcontrol.csv")                                      # xyzcontrol.csv
    myScene.writeFiducialXYZ(outputFolder + "xyzfiducial.csv")                                    # xyzmfiducial.csv
    #writePixelControl(myScene, myTrajectory, mySensor, outputFolder + "pixelFiducial.csv")       # pixelControl.csv
    #writePixelFiducial(myScene, myTrajectory, mySensor, outputFolder + "pixelFiducial.csv")      # pixelFiducial.csv


    # Place Cameras and Render Images
    myTrajectory.render(mySensor, imageFolderPre, dorender)              # Render images
    if dorender:
        print("----------------------------------")
        print("POSTPROCESSING IMAGES WITH MATLAB")
        print("----------------------------------")
        call("matlab -r postProcFolder('" + experimentName + "')")

    # postprocess images
    # add distortion
    # add gaussian noise
    # add salt/pepper noise
    # add blur
    # add vignetting

if __name__ == '__main__':
    run()
