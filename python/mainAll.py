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


    def apply(self, intrinsicsXML):
        logging.debug("applying settings")
        bpy.context.scene.render.resolution_percentage = self.percentage
        bpy.context.scene.render.use_stamp_lens = True #Lens in Metadata
        bpy.context.scene.render.resolution_x = self.resolution[0]
        bpy.context.scene.render.resolution_y = self.resolution[1]
        bpy.context.scene.render.use_antialiasing = self.antialiasing
        bpy.context.scene.render.image_settings.compression = self.compression
        bpy.context.scene.render.image_settings.file_format = self.fileformat

        # output sensor.xml
        intrinsicsFileHandle = open(intrinsicsXML, 'w', newline='')

        f = self.resolution[0] / self.sensorWidth * self.focalLength

        intrinsicsFileHandle.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n")
        intrinsicsFileHandle.write("<calibration>\r\n")
        intrinsicsFileHandle.write("\t<projection>frame</projection>\r\n")
        intrinsicsFileHandle.write("\t<width>" + str(self.resolution[0]*self.percentage/100) + "</width>\r\n")
        intrinsicsFileHandle.write("\t<height>" + str(self.resolution[1]*self.percentage/100) + "</height>\r\n")
        intrinsicsFileHandle.write("\t<fx>" + str(f*self.percentage/100) + "</fx>\r\n")
        intrinsicsFileHandle.write("\t<fy>" + str(f*self.percentage/100) + "</fy>\r\n")
        intrinsicsFileHandle.write("\t<cx>" + str(self.principalPoint[0]*self.percentage/100) + "</cx>\r\n")
        intrinsicsFileHandle.write("\t<cy>" + str(self.principalPoint[1]*self.percentage/100) + "</cy>\r\n")
        intrinsicsFileHandle.write("\t<skew>0</skew>\r\n")
        intrinsicsFileHandle.write("\t<k1>0</k1>\r\n")
        intrinsicsFileHandle.write("\t<k2>0</k2>\r\n")
        intrinsicsFileHandle.write("\t<k3>0</k3>\r\n")
        intrinsicsFileHandle.write("\t<k4>0</k4>\r\n")
        intrinsicsFileHandle.write("\t<p1>0</p1>\r\n")
        intrinsicsFileHandle.write("\t<p2>0</p2>\r\n")
        intrinsicsFileHandle.write("\t<date>" + time.strftime('%Y-%m-%dT%H:%M:%SZ') + "</date>\r\n")
        intrinsicsFileHandle.write("</calibration>\r\n")


class BObject:
    def __init__(self, LibObj, iName, T, R, S, isControl, isMarker):
        self.libname = LibObj.libname
        self.name = iName
        self.path = LibObj.path
        self.blenderType = LibObj.blenderType
        self.filename = LibObj.filename
        self.markerPath = LibObj.markerPath
        self.Translation = T
        self.Rotation = R
        self.Scale = S
        self.isControl = isControl
        self.isMarker = isMarker


class Objlib:
    def __init__(self, name, path, blenderType, filename, markerPath):
        self.libname = name
        self.path = path
        self.blenderType = blenderType
        self.filename = filename
        self.markerPath = markerPath


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
            iname = i.find('name').text
            ipath = i.find('path').text
            iMarkerPath = i.find('markerPath').text
            iblenderType = i.find('blenderType').text
            ifilename = i.find('libname').text
            iLibObj = Objlib(iname, ipath, iblenderType, ifilename, iMarkerPath)
            AllLibObj.append(iLibObj)
            allLibNames.append(iname)
        print(allLibNames)
        self.name = rootscene.get('name')
        self.BObjects = list()
        for iObj in rootscene.findall('object'):
            libname = iObj.get('libname')
            iname = iObj.get('name')
            ind = allLibNames.index(libname)

            isControl = iObj.get('isControl')
            isMarker = iObj.get('isMarker')
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

            iBObject = BObject(AllLibObj[ind], iname, iT, iR, iS, isControl, isMarker)
            self.BObjects.append(iBObject)

    def build(self,controlCSV, markerCSV, outputOBJ):
        logging.info("Building " + self.name)

        controlFileHandle = open(controlCSV, 'w', newline='')
        controlwriter = csv.writer(controlFileHandle)
        controlHeader = ["ControlPointName", "Tx", "Ty", "Tz", "Rx", "Ry", "Rz"]
        controlwriter.writerow(controlHeader)

        markerFileHandle = open(markerCSV, 'w', newline='')
        markerwriter = csv.writer(markerFileHandle)
        markerHeader = ["objectName_markerName", "X", "Y", "Z", "localX", "localY", "localZ"]
        markerwriter.writerow(markerHeader)

        for iObj in self.BObjects:
            iName = iObj.name
            iPath = iObj.path
            iPath.replace("\\", "\\\\")
            iPath = iPath + "\\" + iObj.blenderType + "\\"
            iFilename = iObj.filename
            bpy.ops.wm.append(directory=iPath, link=False, filename=iFilename)
            bpy.data.objects[iFilename].name = iName
            bpy.data.objects[iName].location = (iObj.Translation.x, iObj.Translation.y, iObj.Translation.z)
            bpy.data.objects[iName].rotation_mode = 'ZYX'
            bpy.data.objects[iName].rotation_euler = (iObj.Rotation.x, iObj.Rotation.y, iObj.Rotation.z)
            bpy.data.objects[iName].scale = (iObj.Scale.x, iObj.Scale.y, iObj.Scale.z)
            logging.debug('Added ' + iName + " to scene")
            print(iObj.name, iObj.isControl)

            logging.debug(iObj.name + " isControl = " + iObj.isControl)

            if iObj.isControl == "1":
                controlwriter.writerow([iObj.name, iObj.Translation.x, iObj.Translation.y, iObj.Translation.z,
                                    iObj.Rotation.x*180/pi, iObj.Rotation.y*180/pi, iObj.Rotation.z*180/pi])
                controlFileHandle.flush()

            if iObj.isMarker == "1":
                logging.debug(iObj.name + " being used as marker")
                # load marker points from csv
                rawMarkerPts = readXyzCsv(iObj.markerPath)
                # rotate, translate, and scale marker points
                logging.debug("MARKER")
                logging.debug(iObj.markerPath)
                logging.debug([iObj.Rotation.x, iObj.Rotation.y, iObj.Rotation.z])
                logging.debug([iObj.Translation.x, iObj.Translation.y, iObj.Translation.z])
                logging.debug([iObj.Scale.x, iObj.Scale.y, iObj.Scale.z])

                newMarkerPts = RotatePoint(rawMarkerPts, iObj.Rotation, iObj.Translation, iObj.Scale)
                # print to csv file
                for i in range(len(newMarkerPts.x)):
                    markerwriter.writerow([iObj.name + '_' + rawMarkerPts.names[i],
                                           newMarkerPts.x[i], newMarkerPts.y[i], newMarkerPts.z[i],
                                           rawMarkerPts.x[i], rawMarkerPts.y[i], rawMarkerPts.z[i]])
                markerFileHandle.flush()

        controlFileHandle.close()
        markerFileHandle.close()

        bpy.ops.export_scene.obj(filepath=outputOBJ, axis_forward='Y', axis_up='Z')


class Pose:
    def __init__(self, name, tx, ty, tz, rx, ry, rz):
        self.Translation = Triplet(tx, ty, tz)
        self.Rotation = Triplet(rx, ry, rz)
        self.name = name

    def add(self, camSensor):
        T = (self.Translation.x, self.Translation.y, self.Translation.z)
        R = (self.Rotation.x, self.Rotation.y, self.Rotation.z)
        bpy.ops.object.camera_add(view_align=True, enter_editmode=True, location=T, rotation=(0, 0, 0))
        # bpy.context.object.rotation_mode = 'ZYX'
        bpy.context.object.rotation_euler = R
        bpy.context.object.data.sensor_width = camSensor.sensorWidth
        xyRatio = camSensor.resolution[1]/camSensor.resolution[0]
        bpy.context.object.data.sensor_height = camSensor.sensorWidth * xyRatio
        #calculate lens angle in degrees
        f = camSensor.focalLength
        x = camSensor.sensorWidth/2

        fov = math.atan(x/f)*2

        bpy.context.object.data.lens_unit = 'FOV'
        bpy.context.object.data.angle = fov
        logging.debug(["Set FOV to: " + str(fov)])
        #clipping constants
        bpy.context.object.data.clip_end = camSensor.clipEnd
        bpy.context.object.data.clip_start = camSensor.clipStart

        # move principal point by 0.5 pixels because it appears as though blender uses the center of the pixel??
        halfpixel = 0.5/ camSensor.resolution[0]
        bpy.context.object.data.shift_x = halfpixel + (camSensor.principalPoint[0] - camSensor.resolution[0]/2)\
                                          / -camSensor.resolution[0]
        bpy.context.object.data.shift_y = -halfpixel + (camSensor.principalPoint[1] - camSensor.resolution[1]/2)\
                                          / -camSensor.resolution[0]

        logging.debug(bpy.context.object.data.shift_x)
        logging.debug(bpy.context.object.data.shift_y)

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


def RotatePoint(Points, Rotate, Translate, Scale):
    newPoints = copy.deepcopy(Points)
    # Apply Scale
    for i in range(len(newPoints.x)):
        newPoints.x[i] = newPoints.x[i] * Scale.x
        newPoints.y[i] = newPoints.y[i] * Scale.y
        newPoints.z[i] = newPoints.z[i] * Scale.z

    # Apply Rotation
    cosx = math.cos(Rotate.x)
    sinx = math.sin(Rotate.x)
    cosy = math.cos(Rotate.y)
    siny = math.sin(Rotate.y)
    cosz = math.cos(Rotate.z)
    sinz = math.sin(Rotate.z)

    Rz = [[cosz, -sinz, 0],
          [sinz, cosz, 0],
          [0, 0, 1]]

    Ry = [[cosy, 0, siny],
          [0, 1, 0],
          [-siny, 0, cosy]]

    Rx = [[1, 0, 0],
          [0, cosx, -sinx],
          [0, sinx, cosx]]

    R = np.dot(Rx, np.dot(Ry, Rz))

    for i in range(len(newPoints.x)):
        # Should make everything a numpy array rather than storing as an object
        # so few computations that performance shouldnt be too bad
        P = np.array([newPoints.x[i], newPoints.y[i], newPoints.z[i]])
        Pnew = np.dot(R,P)
        newPoints.x[i] = Pnew[0]
        newPoints.y[i] = Pnew[1]
        newPoints.z[i] = Pnew[2]

    # Apply Translation
    for i in range(len(newPoints.x)):
        newPoints.x[i] = newPoints.x[i] + Translate.x
        newPoints.y[i] = newPoints.y[i] + Translate.y
        newPoints.z[i] = newPoints.z[i] + Translate.z
        logging.debug(" PRE")
        logging.debug([Points.x[i], Points.y[i], Points.z[i]])
        logging.debug(" POST")
        logging.debug([newPoints.x[i], newPoints.y[i], newPoints.z[i]])

    return newPoints


def readXyzCsv(csvfilename):
    csvfile = open(csvfilename)
    allrows = csv.reader(csvfile)

    x = []
    y = []
    z = []
    names = []

    for row in allrows:
        if len(row) == 4:
            names.append(row[0])
            x.append(float(row[1]))
            y.append(float(row[2]))
            z.append(float(row[3]))
        else:
            x.append(float(row[0]))
            y.append(float(row[1]))
            z.append(float(row[2]))
            names.append('')

    return Triplet(x, y, z)


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
    # parse argument
    argv = sys.argv
    try:
        argv = argv[argv.index("--") + 1:]
        experimentName = argv[0]
    except ValueError:
        experimentName = 'C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest\\data\\20160711_testMarkers'

    makedir(experimentName + "/output/")
    makedir(experimentName + "/output/images/")

    outputFolder = experimentName + "/output/"
    xmlScene = glob.glob(experimentName + '/input/scene*.xml')[0]
    xmlSensor = glob.glob(experimentName + '/input/sensor*.xml')[0]
    xmlTrajectory = glob.glob(experimentName + '/input/trajectory*.xml')[0]
    LOGFORMAT = "[%(asctime)s] %(funcName)s: %(message)s"
    logging.basicConfig(filename=experimentName + "/output/log.txt", level=logging.DEBUG, format=LOGFORMAT)
    logging.debug('logger opened')
    logging.info(sys.version)

    trajectoryCSV = experimentName + "/output/trajectory.txt"
    controlCSV = experimentName + "/output/control.txt"
    markerCSV = experimentName + "/output/marker.txt"
    IntrinsicsXML = experimentName + "/output/sensor.xml"
    outputOBJ = experimentName + "/output/model.obj"
    # Populate Classes
    myScene = Scene(xmlScene)
    mySensor = Sensor(xmlSensor)
    myTrajectory = Trajectory(xmlTrajectory)

    # MakeScene
    wipe()
    myScene.build(controlCSV, markerCSV, outputOBJ)
    # Apply Sensor Parameters
    mySensor.apply(IntrinsicsXML)
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

        rawrow = [iPose.name + '.png', iPose.Translation.x, iPose.Translation.y, iPose.Translation.z,
                  iPose.Rotation.x*180/pi, iPose.Rotation.y*180/pi, iPose.Rotation.z*180/pi]
        writer.writerow(rawrow)
        trajectoryFile.flush()
    trajectoryFile.close()

if __name__ == "__main__":
    main()
