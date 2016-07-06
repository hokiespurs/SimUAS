import bpy
import xml.etree.ElementTree as ET
from math import pi
import glob
import sys
import logging
import csv
import os

class Sensor:
    def __init__(self, xmlsensor):
        tree = ET.parse(xmlsensor)
        root = tree.getroot()

        self.name = root.get('name')
        self.fileformat = root.get('fileformat')
        self.focalLength = float(root.find('physical').get('focallength'))
        self.sensorWidth = float(root.find('physical').get('sensorWidth'))
        self.resolution = (float(root.find('resolution').get('x')), float(root.find('resolution').get('y')))
        self.principalPoint = (float(root.find('principalPoint').get('x')), float(root.find('principalPoint').get('y')))
        self.compression = float(root.find('image').get('compression'))
        self.percentage = float(root.find('image').get('percentage'))
        self.antialiasing = float(root.find('image').get('antialiasing'))
        self.clipStart = float(root.find('clipping').get('start'))
        self.clipEnd = float(root.find('clipping').get('end'))

    def apply(self):
        logging.debug("applying settings")
        bpy.context.scene.render.resolution_percentage = self.percentage
        bpy.context.scene.render.use_stamp_lens = True #Lens in Metadata
        bpy.context.scene.render.resolution_x = self.resolution[0]
        bpy.context.scene.render.resolution_y = self.resolution[1]
        bpy.context.scene.render.use_antialiasing = self.antialiasing
        bpy.context.scene.render.image_settings.compression = self.compression
        bpy.context.scene.render.image_settings.file_format = self.fileformat


class BObject:
    def __init__(self, LibObj, iName, T, R, S, isGCP):
        self.libname = LibObj.libname
        self.name = iName
        self.path = LibObj.path
        self.blenderType = LibObj.blenderType
        self.filename = LibObj.filename
        self.Translation = T
        self.Rotation = R
        self.Scale = S
        self.isGCP = isGCP


class Objlib:
    def __init__(self, name, path, blenderType, filename):
        self.libname = name
        self.path = path
        self.blenderType = blenderType
        self.filename = filename


class Scene:
    def __init__(self, xmlScene):
        treescene = ET.parse(xmlScene)
        rootscene = treescene.getroot()
        xmlLibrary = rootscene.get('lib')

        treelib = ET.parse(xmlLibrary)
        rootlib = treelib.getroot()

        AllLibObj = list()
        allLibNames = list()
        for i in rootlib.findall('object'):
            iname = i.get('name')
            ipath = i.get('path')
            iblenderType = i.get('blenderType')
            ifilename = i.get('filename')
            iLibObj = Objlib(iname, ipath, iblenderType, ifilename)
            AllLibObj.append(iLibObj)
            allLibNames.append(iname)

        self.name = rootscene.get('name')
        self.BObjects = list()
        for iObj in rootscene.findall('object'):
            libname = iObj.get('libname')
            iname = iObj.get('name')
            ind = allLibNames.index(libname)

            isGCP = iObj.get('isGCP')
            Tx = float(iObj.find('translation').get('x'))
            Ty = float(iObj.find('translation').get('y'))
            Tz = float(iObj.find('translation').get('z'))
            Rx = float(iObj.find('rotation').get('x'))*pi/180
            Ry = float(iObj.find('rotation').get('y'))*pi/180
            Rz = float(iObj.find('rotation').get('z'))*pi/180
            Sx = float(iObj.find('scale').get('x'))
            Sy = float(iObj.find('scale').get('y'))
            Sz = float(iObj.find('scale').get('z'))

            iT = Triplet(Tx, Ty, Tz)
            iR = Triplet(Rx, Ry, Rz)
            iS = Triplet(Sx, Sy, Sz)

            iBObject = BObject(AllLibObj[ind], iname, iT, iR, iS, isGCP)
            self.BObjects.append(iBObject)

    def build(self,controlCSV):
        logging.info("Building " + self.name)

        controlFileHandle = open(controlCSV, 'w', newline='')
        GCPwriter = csv.writer(controlFileHandle)
        trajectoryHeader = ["ControlPointName", "Tx", "Ty", "Tz", "Rx", "Ry", "Rz"]
        GCPwriter.writerow(trajectoryHeader)

        for iObj in self.BObjects:
            iName = iObj.name

            iPath = iObj.path
            iPath.replace("\\", "\\\\")
            iPath = iPath + "\\" + iObj.blenderType + "\\"
            iFilename = iObj.filename
            bpy.ops.wm.append(directory=iPath, link=False, filename=iFilename)
            bpy.data.objects[iFilename].name = iName
            bpy.data.objects[iName].location = (iObj.Translation.x, iObj.Translation.y, iObj.Translation.z)
            bpy.data.objects[iName].rotation_euler = (iObj.Rotation.x, iObj.Rotation.y, iObj.Rotation.z)
            bpy.data.objects[iName].scale = (iObj.Scale.x, iObj.Scale.y, iObj.Scale.z)
            logging.debug('Added ' + iName + " to scene")
            logging.debug(iObj.name + " isGCP = " + iObj.isGCP)

            if iObj.isGCP == "1":
                GCPwriter.writerow([iObj.name, iObj.Translation.x, iObj.Translation.y, iObj.Translation.z,
                                    iObj.Rotation.x*180/pi, iObj.Rotation.y*180/pi, iObj.Rotation.z*180/pi])
                controlFileHandle.flush()
        controlFileHandle.close()


class Pose:
    def __init__(self, name, tx, ty, tz, rx, ry, rz):
        self.Translation = Triplet(tx, ty, tz)
        self.Rotation = Triplet(rx, ry, rz)
        self.name = name

    def add(self, camSensor):
        T = (self.Translation.x, self.Translation.y, self.Translation.z)
        R = (self.Rotation.x, self.Rotation.y, self.Rotation.z)
        bpy.ops.object.camera_add(view_align=True, enter_editmode=True, location=T, rotation=R)
        bpy.context.object.data.lens = camSensor.focalLength
        bpy.context.object.data.sensor_width = camSensor.sensorWidth

        #clipping constants
        bpy.context.object.data.clip_end = camSensor.clipEnd
        bpy.context.object.data.clip_start = camSensor.clipStart
        #assume square pixels
        pixPerMm = camSensor.sensorWidth / camSensor.resolution[0]
        bpy.context.object.data.shift_x = (camSensor.principalPoint[0] - camSensor.resolution[0]/2) * pixPerMm
        bpy.context.object.data.shift_y = (camSensor.principalPoint[1] - camSensor.resolution[1]/2) * pixPerMm

        bpy.context.object.name = self.name
        bpy.context.object.data.name = self.name
        logging.debug("ADDING POSE: " + self.name)

    def link(self, num):
        try:
            curType = bpy.context.area.type
            bpy.context.area.type = 'TIMELINE'
            bpy.context.scene.camera = bpy.data.objects[self.name]
            bpy.context.scene.frame_current = num
            bpy.ops.marker.add()
            bpy.ops.marker.camera_bind()
            logging.debug("Linking: " + self.name)
            bpy.context.area.type = curType
        except AttributeError:
            logging.info('running as background')


class Trajectory:
    def __init__(self, xmlExtrinsics):
        tree = ET.parse(xmlExtrinsics)
        root = tree.getroot()
        self.Pose = list()
        self.name = root.get('name')
        for iObj in root.findall('pose'):

            iName = iObj.get('name')

            tx = float(iObj.find('translation').get('x'))
            ty = float(iObj.find('translation').get('y'))
            tz = float(iObj.find('translation').get('z'))
            rx = float(iObj.find('rotation').get('x'))*pi/180
            ry = float(iObj.find('rotation').get('y'))*pi/180
            rz = float(iObj.find('rotation').get('z'))*pi/180

            iPose = Pose(iName, tx, ty, tz, rx, ry, rz)
            self.Pose.append(iPose)


class Triplet:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z


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


def main():
    logging.info(sys.version)

    # parse argument
    argv = sys.argv
    try:
        argv = argv[argv.index("--") + 1:]
        experimentName = argv[0]
    except ValueError:
        experimentName = 'C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest\\data\\example'
    makedir(experimentName + "/output/")
    makedir(experimentName + "/output/images/")

    outputFolder = experimentName + "/output/"
    xmlScene = glob.glob(experimentName + '/input/scene*.xml')[0]
    xmlSensor = glob.glob(experimentName + '/input/sensor*.xml')[0]
    xmlTrajectory = glob.glob(experimentName + '/input/trajectory*.xml')[0]
    LOGFORMAT = "[%(asctime)s] %(funcName)s: %(message)s"
    logging.basicConfig(filename=experimentName + "/output/log.txt", level=logging.DEBUG, format= LOGFORMAT)
    trajectoryCSV = experimentName + "/output/trajectory.txt"
    controlCSV = experimentName + "/output/Control.txt"
    wipe()  # clear all blender objects

    # Populate Classes
    myScene = Scene(xmlScene)
    mySensor = Sensor(xmlSensor)
    myTrajectory = Trajectory(xmlTrajectory)

    # MakeScene
    myScene.build(controlCSV)
    # Apply Sensor Parameters
    mySensor.apply()
    iCount = 0

    trajectoryFile = open(trajectoryCSV, 'w', newline='')
    writer = csv.writer(trajectoryFile)
    trajectoryHeader = ["ImageName", "Tx", "Ty", "Tz", "Rx", "Ry", "Rz"]
    writer.writerow(trajectoryHeader)
    for iPose in myTrajectory.Pose:
        iCount += 1
        iPose.add(mySensor)
        iPose.link(iCount)
        logging.debug("Rendering [" + iPose.name + "] started")
        bpy.context.scene.camera = bpy.data.objects[iPose.name]
        bpy.context.scene.render.filepath = outputFolder + "/images/" + iPose.name
        bpy.ops.render.render( write_still=True )
        logging.debug("Rendered Finished")
        # write trajectory csv

        rawrow = [iPose.name + '.png', iPose.Translation.x, iPose.Translation.y, iPose.Translation.z, iPose.Rotation.x*180/pi,
                  iPose.Rotation.y*180/pi, iPose.Rotation.z*180/pi]
        writer.writerow(rawrow)
        trajectoryFile.flush()
    trajectoryFile.close()

if __name__ == "__main__":
    main()
