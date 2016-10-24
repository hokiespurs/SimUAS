import bpy
import xml.etree.ElementTree as ET
from math import pi
import glob
import logging
import csv
import copy
import math
import numpy as np

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

