import xml.etree.ElementTree as ET
from Triplet import *
import bpy
from math import pi


class BObject:
    def __init__(self, LibObj, iName, T, R, S):
        self.linname = LibObj.libname
        self.name = iName
        self.path = LibObj.path
        self.blenderType = LibObj.blenderType
        self.filename = LibObj.filename
        self.Translation = T
        self.Rotation = R
        self.Scale = S


class Objlib:
    def __init__(self, name, path, blenderType, filename):
        self.libname = name
        self.path = path
        self.blenderType = blenderType
        self.filename = filename


class Scene:
    def __init__(self, xmlLibrary, xmlScene):
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

        treescene = ET.parse(xmlScene)
        rootscene = treescene.getroot()
        self.name = rootscene.get('name')
        self.BObjects = list()
        for iObj in rootscene.findall('object'):
            libname = iObj.get('libname')
            iname = iObj.get('name')
            ind = allLibNames.index(libname)

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

            iBObject = BObject(AllLibObj[ind], iname, iT, iR, iS)
            self.BObjects.append(iBObject)

    def build(self):
        print("Building" + self.name)
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

            print('blender append new')