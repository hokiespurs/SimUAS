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

sys.path.append(os.path.dirname(__file__))


class Sensor:
    def __init__(self, xmlsensor):
        # Default Clip for Z Buffer
        self.clipStart = 0.01
        self.clipEnd = 1000

        tree = ET.parse(xmlsensor)
        root = tree.getroot()

        self.name = root.get('name')
        self.fileformat = root.get('fileformat')
        self.focalLength = float(root.find('physical').get('focallength'))
        self.sensorWidth = float(root.find('physical').get('sensorWidth'))
        self.resolution = (float(root.find('resolution').get('x')),
                           float(root.find('resolution').get('y')))
        self.principalPoint = (float(root.find('principalPoint').get('x')),
                               float(root.find('principalPoint').get('y')))
        self.compression = float(root.find('blender').get('compression'))
        self.percentage = float(root.find('blender').get('percentage'))
        self.antialiasing = float(root.find('blender').get('antialiasing'))
        self.distortion = (float(root.find('postprocessing').find('distortion').get('k1')),
                           float(root.find('postprocessing').find('distortion').get('k2')),
                           float(root.find('postprocessing').find('distortion').get('k3')),
                           float(root.find('postprocessing').find('distortion').get('k4')),
                           float(root.find('postprocessing').find('distortion').get('p1')),
                           float(root.find('postprocessing').find('distortion').get('p2')))
        self.vignetting = (float(root.find('postprocessing').find('vignetting').get('v1')),
                           float(root.find('postprocessing').find('vignetting').get('v2')),
                           float(root.find('postprocessing').find('vignetting').get('v3')))
        self.saltnoise = float(root.find('postprocessing').find('saltnoise').get("prob"))
        self.peppernoise = float(root.find('postprocessing').find('peppernoise').get("prob"))
        self.gaussnoise = (float(root.find('postprocessing').find('gaussiannoise').get('mean')),
                           float(root.find('postprocessing').find('gaussiannoise').get('variance')))
        self.gaussianblur = float(root.find('postprocessing').find('gaussianblur').get("sigma"))

        f = self.resolution[0] / self.sensorWidth * self.focalLength
        self.psdistortion = (self.distortion[0] / (f ** 2),
                             self.distortion[1] / (f ** 4),
                             self.distortion[2] / (f ** 6),
                             self.distortion[3] / (f ** 8),
                             self.distortion[4] / (f ** 2),
                             self.distortion[5] / (f ** 2))

        sx, sy = calcdistortionpadding(self.resolution, self.principalPoint, self.psdistortion)

        self.renderresolution = (self.resolution[0] * sx, self.resolution[1] * sy)
        print(self.renderresolution)
        self.rendersensorwidth = self.sensorWidth * sx


    def apply(self):
        logging.debug("applying settings")
        bpy.context.scene.render.resolution_percentage = self.percentage
        bpy.context.scene.render.use_stamp_lens = True #Lens in Metadata
        bpy.context.scene.render.resolution_x = self.renderresolution[0]
        bpy.context.scene.render.resolution_y = self.renderresolution[1]
        bpy.context.scene.render.use_antialiasing = self.antialiasing
        bpy.context.scene.render.image_settings.compression = self.compression
        bpy.context.scene.render.image_settings.file_format = self.fileformat

    def writeXML(self, xmlname):
        # output sensor.xml
        intrinsicsFileHandle = open(xmlname + ".xml", 'w', newline='')

        f = self.resolution[0] / self.sensorWidth * self.focalLength

        intrinsicsFileHandle.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n")
        intrinsicsFileHandle.write("<calibration>\r\n")
        intrinsicsFileHandle.write("\t<projection>frame</projection>\r\n")
        intrinsicsFileHandle.write("\t<width>" + str(self.resolution[0] * self.percentage / 100) + "</width>\r\n")
        intrinsicsFileHandle.write("\t<height>" + str(self.resolution[1] * self.percentage / 100) + "</height>\r\n")
        intrinsicsFileHandle.write("\t<f>" + str(f * self.percentage / 100) + "</f>\r\n")
        intrinsicsFileHandle.write("\t<cx>" + str(self.principalPoint[0] * self.percentage / 100) + "</cx>\r\n")
        intrinsicsFileHandle.write("\t<cy>" + str(self.principalPoint[1] * self.percentage / 100) + "</cy>\r\n")
        intrinsicsFileHandle.write("\t<skew>0</skew>\r\n")
        intrinsicsFileHandle.write("\t<k1>" + str(self.distortion[0]) + "</k1>\r\n")
        intrinsicsFileHandle.write("\t<k2>" + str(self.distortion[1]) + "</k2>\r\n")
        intrinsicsFileHandle.write("\t<k3>" + str(self.distortion[2]) + "</k3>\r\n")
        intrinsicsFileHandle.write("\t<k4>" + str(self.distortion[3]) + "</k4>\r\n")
        intrinsicsFileHandle.write("\t<p1>" + str(self.distortion[4]) + "</p1>\r\n")
        intrinsicsFileHandle.write("\t<p2>" + str(self.distortion[5]) + "</p2>\r\n")
        intrinsicsFileHandle.write("\t<date>" + time.strftime('%Y-%m-%dT%H:%M:%SZ') + "</date>\r\n")
        intrinsicsFileHandle.write("</calibration>\r\n")

        intrinsicsFileHandle.close()
        # output sensor_photoscanCXCYdefinition.xml
        intrinsicsFileHandle = open(xmlname + "_photoscan.xml", 'w', newline='')

        f = self.resolution[0] / self.sensorWidth * self.focalLength
        photoscan_cx_offset = (self.principalPoint[0] - self.resolution[0]/2) * self.percentage / 100
        photoscan_cy_offset = (self.principalPoint[1] - self.resolution[1]/2) * self.percentage / 100

        intrinsicsFileHandle.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n")
        intrinsicsFileHandle.write("<calibration>\r\n")
        intrinsicsFileHandle.write("\t<projection>frame</projection>\r\n")
        intrinsicsFileHandle.write("\t<width>" + str(self.resolution[0] * self.percentage / 100) + "</width>\r\n")
        intrinsicsFileHandle.write("\t<height>" + str(self.resolution[1] * self.percentage / 100) + "</height>\r\n")
        intrinsicsFileHandle.write("\t<f>" + str(f * self.percentage / 100) + "</f>\r\n")
        intrinsicsFileHandle.write("\t<cx>" + str(photoscan_cx_offset) + "</cx>\r\n")
        intrinsicsFileHandle.write("\t<cy>" + str(photoscan_cy_offset) + "</cy>\r\n")
        intrinsicsFileHandle.write("\t<skew>0</skew>\r\n")
        intrinsicsFileHandle.write("\t<k1>" + str(self.distortion[0]) + "</k1>\r\n")
        intrinsicsFileHandle.write("\t<k2>" + str(self.distortion[1]) + "</k2>\r\n")
        intrinsicsFileHandle.write("\t<k3>" + str(self.distortion[2]) + "</k3>\r\n")
        intrinsicsFileHandle.write("\t<k4>" + str(self.distortion[3]) + "</k4>\r\n")
        intrinsicsFileHandle.write("\t<p1>" + str(self.distortion[4]) + "</p1>\r\n")
        intrinsicsFileHandle.write("\t<p2>" + str(self.distortion[5]) + "</p2>\r\n")
        intrinsicsFileHandle.write("\t<date>" + time.strftime('%Y-%m-%dT%H:%M:%SZ') + "</date>\r\n")
        intrinsicsFileHandle.write("</calibration>\r\n")

        intrinsicsFileHandle.close()


class Scene:
    class BlenderMaterial:
        def __init__(self, tex, rgb, alpha, ior, dointerptex):
            self.texture = tex
            self.diffuse = rgb
            self.alpha = alpha
            self.ior = ior
            self.dointerptex = dointerptex

    class BObject:
        def __init__(self, objname, iName, T, R, S, isControl, isFiducial, Material):
            self.dbname = objname
            self.name = iName
            self.Translation = T
            self.Rotation = R
            self.Scale = S
            self.isControl = isControl
            self.isFiducial = isFiducial
            self.Material = Material

    def __init__(self, xmlScene, rootname):
        tree = ET.parse(xmlScene)
        root = tree.getroot()

        self.name = root.get('name')
        self.dbfolder = root.get('objectdb')
        self.rootname = rootname
        self.BObjects = list()
        for iObj in root.findall('object'):
            iobjname = iObj.get('objname')
            iname = iObj.get('name')
            isControl = iObj.get('isControl')
            isFiducial = iObj.get('isFiducial')
            Tx = float(iObj.find('translation').get('x'))
            Ty = float(iObj.find('translation').get('y'))
            Tz = float(iObj.find('translation').get('z'))
            Rx = float(iObj.find('rotation').get('x')) * pi / 180
            Ry = float(iObj.find('rotation').get('y')) * pi / 180
            Rz = float(iObj.find('rotation').get('z')) * pi / 180
            Sx = float(iObj.find('scale').get('x'))
            Sy = float(iObj.find('scale').get('y'))
            Sz = float(iObj.find('scale').get('z'))

            iT = Triplet(Tx, Ty, Tz)
            iR = Triplet(Rx, Ry, Rz)
            iS = Triplet(Sx, Sy, Sz)

            material = iObj.find('material')

            if material == None:
                iMaterial = self.BlenderMaterial(None,None,None,None,None)
            else:
                itex = material.find('texture').get('img')
                dointerptex = float(material.find('texture').get('interp'))
                iDiffuseRGB = (float(material.find('diffuse').get('red')),
                               float(material.find('diffuse').get('green')),
                               float(material.find('diffuse').get('blue')))
                iTransparencyAlpha = float(material.find('transparency').get('alpha'))
                iTransparencyIOR = float(material.find('transparency').get('ior'))

                iMaterial = self.BlenderMaterial(itex,iDiffuseRGB, iTransparencyAlpha, iTransparencyIOR, dointerptex)
            iBObject = self.BObject(iobjname, iname, iT, iR, iS, isControl, isFiducial, iMaterial)
            self.BObjects.append(iBObject)

    def applyMaterial(self, activematerial, material):
        tex = material.texture
        diffuse = material.diffuse
        alpha = material.alpha
        ior = material.ior
        dointerptex = material.dointerptex

        activematerial.use_shadeless = True

        if not activematerial.active_texture == None:
            if dointerptex == 0:
                activematerial.active_texture.filter_type = 'BOX'
                activematerial.active_texture.use_interpolation = False
                activematerial.active_texture.filter_size = 0.1

        if not (tex==None):
            try:
                if not (tex == "default" or tex == ""):
                    activematerial.active_texture.image.filepath = self.rootname + "\\" + tex
                if tex == "":
                    activematerial.texture_slots[0].use_map_color_diffuse = False
            except AttributeError:
                logging.info('error with texture')

            activematerial.diffuse_color = diffuse

            if alpha < 1:
                activematerial.transparency_method = "RAYTRACE"
                activematerial.alpha = alpha
                activematerial.raytrace_transparency.ior = ior

    def build(self):
        logging.info("Building " + self.name)

        for iObj in self.BObjects:
            iName = iObj.name
            iPath = self.dbfolder + "\\" + iObj.dbname + "\\"
            iPath.replace("\\", "\\\\")
            iObjFilepath = glob.glob(self.rootname + "\\" + iPath + '/*.obj')[0]

            bpy.ops.import_scene.obj(filepath=iObjFilepath, axis_forward="Y", axis_up="Z")
            bpy.data.objects[iObj.dbname].name = iName
            bpy.data.objects[iName].data.name = iName
            for activemat in bpy.data.objects[iName].material_slots.values():
                self.applyMaterial(activemat.material, iObj.Material)

            bpy.data.objects[iName].location = (iObj.Translation.x, iObj.Translation.y, iObj.Translation.z)
            bpy.data.objects[iName].rotation_mode = 'ZYX'
            bpy.data.objects[iName].rotation_euler = (iObj.Rotation.x, iObj.Rotation.y, iObj.Rotation.z)
            bpy.data.objects[iName].scale = (iObj.Scale.x, iObj.Scale.y, iObj.Scale.z)
            logging.debug('Added ' + iName + " to scene")

        for iMat in bpy.data.materials:
            iMat.use_shadeless = True


    def saveOBJ(self, outputOBJfolder):
        #deselect all
        for iObj in self.BObjects:
            iName = iObj.name
            bpy.data.objects[iName].select = False

        for iObj in self.BObjects:
            iName = iObj.name
            bpy.data.objects[iName].select = True
            bpy.ops.export_scene.obj(filepath=outputOBJfolder + iName + ".obj", use_selection=True, axis_forward='Y',
                                     axis_up='Z', path_mode='COPY')
            bpy.data.objects[iName].select = False

        #write all as one big obj file
        bpy.ops.export_scene.obj(filepath=outputOBJfolder + "allmodel.obj", use_selection=False, axis_forward='Y',
                                 axis_up='Z', path_mode='COPY')

    def writeControlXYZ(self, controlCSV):
        controlFileHandle = open(controlCSV, 'w', newline='')
        controlwriter = csv.writer(controlFileHandle)
        controlHeader = ["ControlPointName", "Tx", "Ty", "Tz", "Rx", "Ry", "Rz"]
        controlwriter.writerow(controlHeader)

        for iObj in self.BObjects:
            if iObj.isControl == "1":
                controlwriter.writerow([iObj.name, iObj.Translation.x, iObj.Translation.y, iObj.Translation.z,
                                        iObj.Rotation.x*180/pi, iObj.Rotation.y*180/pi, iObj.Rotation.z*180/pi])
                controlFileHandle.flush()

        controlFileHandle.close()

    def writeFiducialXYZ(self, fiducialCSV):
        fiducialFileHandle = open(fiducialCSV, 'w', newline='')
        fiducialwriter = csv.writer(fiducialFileHandle)
        fiducialHeader = ["objectName_fiducialName", "X", "Y", "Z", "localX", "localY", "localZ"]
        fiducialwriter.writerow(fiducialHeader)

        for iObj in self.BObjects:
            if iObj.isFiducial == "1":
                logging.debug(iObj.name + " being used as fiducial")
                # load fiducial points from csv
                iPath = self.dbfolder + "\\" + iObj.dbname + "\\"
                iPath.replace("\\", "\\\\")
                fiducialtxtname = glob.glob(self.rootname + "/" + iPath + '/*.txt')[0]
                rawFiducialPts = readXyzCsv(fiducialtxtname)
                # rotate, translate, and scale fiducial points
                newFiducialPts = RotatePoint(rawFiducialPts, iObj.Rotation, iObj.Translation, iObj.Scale)
                # print to csv file
                for i in range(len(newFiducialPts.x)):
                    fiducialwriter.writerow([iObj.name + '_' + rawFiducialPts.names[i],
                                           newFiducialPts.x[i], newFiducialPts.y[i], newFiducialPts.z[i],
                                           rawFiducialPts.x[i], rawFiducialPts.y[i], rawFiducialPts.z[i]])
                fiducialFileHandle.flush()

        fiducialFileHandle.close()


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
        bpy.context.object.data.sensor_width = camSensor.rendersensorwidth
        xyRatio = camSensor.renderresolution[1] / camSensor.renderresolution[0]
        bpy.context.object.data.sensor_height = camSensor.rendersensorwidth * xyRatio
        # calculate lens angle in degrees
        f = camSensor.focalLength

        bpy.context.object.data.lens_unit = 'MILLIMETERS'
        bpy.context.object.data.lens = f
        logging.debug(["Set focal length to: " + str(f)])
        # clipping constants
        bpy.context.object.data.clip_end = camSensor.clipEnd
        bpy.context.object.data.clip_start = camSensor.clipStart

        # move principal point by 0.5 pixels because it appears as though blender uses the center of the pixel??
        halfpixel = 0.5 / camSensor.renderresolution[0]
        bpy.context.object.data.shift_x = halfpixel + (camSensor.principalPoint[0] - camSensor.resolution[0] / 2) \
                                                      / -camSensor.resolution[0]
        bpy.context.object.data.shift_y = -halfpixel - (camSensor.principalPoint[1] - camSensor.resolution[1] / 2) \
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
            rx = float(iObj.find('rotation').get('x')) * pi / 180
            ry = float(iObj.find('rotation').get('y')) * pi / 180
            rz = float(iObj.find('rotation').get('z')) * pi / 180

            iPose = Pose(iName, tx, ty, tz, rx, ry, rz)
            self.Pose.append(iPose)

    def render(self, mySensor, outputFolder, dorender):
        iCount =0
        for iPose in self.Pose:
            iCount += 1
            iPose.add(mySensor)
            iPose.link(iCount)
            logging.debug("Rendering [" + iPose.name + "] started")
            bpy.context.scene.camera = bpy.data.objects[iPose.name]
            bpy.context.scene.render.filepath = outputFolder + "/" + iPose.name
            logging.debug("Writing to: " + outputFolder + "/" + iPose.name)
            if dorender:
                bpy.ops.render.render(write_still=True)
                logging.debug("Rendered Finished")
            else:
                logging.debug("NO RENDER MODE")

    def writecsv(self, csvname):
        trajectoryFile = open(csvname, 'w', newline='')
        writer = csv.writer(trajectoryFile)
        trajectoryHeader = ["ImageName", "Tx", "Ty", "Tz", "Rx", "Ry", "Rz"]
        writer.writerow(trajectoryHeader)
        for iPose in self.Pose:
            rawrow = [iPose.name + '.png', iPose.Translation.x, iPose.Translation.y, iPose.Translation.z,
                      iPose.Rotation.x * 180 / pi, iPose.Rotation.y * 180 / pi, iPose.Rotation.z * 180 / pi]
            writer.writerow(rawrow)

        trajectoryFile.close()


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
        # ... but so few computations that performance shouldnt be too bad
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


def calcdistortionpadding(res, cxcy, distortion):
    topleft = calcDistortedCorner(0, 0, -1, -1, res, cxcy, distortion)
    topright = calcDistortedCorner(res[0], 0, 1, -1, res, cxcy, distortion)
    botleft = calcDistortedCorner(0, res[1], -1, 1, res, cxcy, distortion)
    botright = calcDistortedCorner(res[0], res[1], 1, 1, res, cxcy, distortion)

    padx = np.max((1 - topleft[0], 1 - botleft[0], topright[0] - res[0], botright[0] - res[0]))
    pady = np.max((1 - topleft[1], 1 - topright[1], botleft[1] - res[1], botright[1] - res[1]))

    newresolution = (res[0] + 2 * padx, res[1] + 2 * pady)

    sx = newresolution[0] / res[0]
    sy = newresolution[1] / res[1]

    return sx, sy


def calcDistortedCorner(x, y, dx, dy, res, cxcy, distortion):
    xgood = False
    ygood = False
    count = 0
    while not xgood and not ygood and count<1000:
        count += 1
        newx, newy = calcBrownDistortedCoords(x, y, cxcy[0], cxcy[1], distortion[0:4], distortion[4:6])
        inx, iny = inimage(newx, newy, res)

        print((x,y))

        if inx:
            x += dx
            xgood = False
        else:
            xgood = True

        if iny:
            y += dy
            ygood = False
        else:
            ygood = True

        print((newx, newy))
        print((inx, iny))
        print(xgood, ygood)
    return x, y


def inimage(x, y, resolution):
    inx = True
    iny = True

    if x < 1 or x > resolution[0]:
        inx = False

    if y<1 or y>resolution[1]:
        iny = False

    return inx, iny


def calcBrownDistortedCoords(xu, yu, xc, yc, k, p):
    # radial distortion
    r = np.sqrt((xu - xc) ** 2 + (yu - yc) ** 2)
    dx_radial = (xu - xc) * (1 + (k[0] * r ** 2) + (k[1] * r ** 4) + (k[2] * r ** 6) + (k[3] * r ** 8))
    dy_radial = (yu - yc) * (1 + (k[0] * r ** 2) + (k[1] * r ** 4) + (k[2] * r ** 6) + (k[3] * r ** 8))

    # tangential distortion
    dx_tangential = (p[0] * (r ** 2 + 2 * (xu - xc) ** 2) + 2 * p[1] * (xu - xc) * (yu - yc))
    dy_tangential = (p[1] * (r ** 2 + 2 * (yu - yc) ** 2) + 2 * p[0] * (xu - xc) * (yu - yc))

    # calculate distorted coordinate
    xd = np.array(xc + dx_radial + dx_tangential)
    yd = np.array(yc + dy_radial + dy_tangential)

    return xd, yd


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


def writePixelControl(myScene, myTrajectory, mySensor, xmlsavename):
    print("DUMMY FOR NOW")


def writePixelFiducial(myScene, myTrajectory, mySensor, xmlsavename):
    print("DUMMY FOR NOW")


def run():
    # Parse Arguments
    argv = sys.argv
    
    try:
        argv = argv[argv.index("--") + 1:]
        rootname = os.path.dirname(os.path.dirname(__file__))
        experimentName = rootname + '/' + argv[0]
        dorender = True
    except ValueError:
        experimentName = 'C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest\\data\\calroom'
        rootname = 'C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest'
        dorender = False

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
    myTrajectory.writecsv(outputFolder + "Trajectory.csv")                                    # Trajectory CSV
    mySensor.writeXML(outputFolder + "Sensor")                                            # Sensor XML
    myScene.saveOBJ(modelFolder)                                                              # OBJ files
    myScene.writeControlXYZ(outputFolder + "xyzcontrol.csv")                                  # xyzcontrol.csv
    myScene.writeFiducialXYZ(outputFolder + "xyzfiducial.csv")                                    # xyzmfiducial.csv
    #writePixelControl(myScene, myTrajectory, mySensor, outputFolder + "pixelFiducial.csv")      # pixelControl.csv
    #writePixelFiducial(myScene, myTrajectory, mySensor, outputFolder + "pixelFiducial.csv")       # pixelFiducial.csv


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
