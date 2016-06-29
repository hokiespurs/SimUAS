import bpy
import xml.etree.ElementTree as ET
from math import pi

class Sensor:
    def __init__(self, xmlsensor):
        tree = ET.parse(xmlsensor)
        root = tree.getroot()

        self.name = root.get('name')
        self.type = root.get('type')
        self.focalLength = float(root.find('physical').get('focallength'))
        self.sensorWidth = float(root.find('physical').get('sensorWidth'))
        self.resolution = (float(root.find('resolution').get('x')), float(root.find('resolution').get('y')))
        self.principalPoint = (float(root.find('principalPoint').get('x')), float(root.find('principalPoint').get('y')))
        self.compression = float(root.find('image').get('compression'))
        self.percentage = float(root.find('image').get('percentage'))
        self.antialiasing = root.find('image').get('antialiasing')

    def apply(self):
        print("applying settings")
        bpy.context.scene.render.resolution_percentage = self.percentage #Rendering to 100 percent
        bpy.context.scene.render.use_stamp_lens = True #Lens in Metadata
        bpy.context.scene.render.resolution_x = self.resolution[0]
        bpy.context.scene.render.resolution_y = self.resolution[1]

        # Unable to add the following parameters, bad bpy documentation?
        #bpy.context.scene.compression = self.compression  #Image Compression
        #bpy.context.scene.file_format = self.type #Output Format

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
            bpy.data.objects[iName].scale = (iObj.Scale.x, iObj.Scale.y, iObj.Scale.z)
            print('blender append new')

class Pose:
    def __init__(self, name, tx, ty, tz, rx, ry, rz):
        self.Translation = Triplet(tx, ty, tz)
        self.Rotation = Triplet(rx, ry, rz)
        self.name = name

    def add(self,Sensor):
        T = (self.Translation.x, self.Translation.y, self.Translation.z)
        R = (self.Rotation.x, self.Rotation.y, self.Rotation.z)
        bpy.ops.object.camera_add(view_align=True, enter_editmode=True, location=T, rotation=R)
        bpy.context.object.data.lens = Sensor.focalLength
        bpy.context.object.data.sensor_width = Sensor.sensorWidth
        bpy.context.object.name = self.name
        bpy.context.object.data.name = self.name
        print("ADDING POSE" + self.name)

    def link(self, num):
        curType = bpy.context.area.type
        bpy.context.area.type = 'TIMELINE'
        bpy.context.scene.camera = bpy.data.objects[self.name]
        bpy.context.scene.frame_current = num
        bpy.ops.marker.add()
        bpy.ops.marker.camera_bind()
        print("Linking" + self.name)
        bpy.context.area.type = curType

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

wipe()  # clear all objects

# User defined textbook
outputFolder = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/data/example/output/"
xmlLibrary = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/objects/objectLibrary.xml"
xmlScene = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/data/example/input/scene_example.xml"
xmlSensor = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/data/example/input/sensor_demo.xml"
xmlTrajectory = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/data/example/input/trajectory_demoGrid_121.xml"
doRender = True

# Populate Classes
myScene = Scene(xmlLibrary,xmlScene) # (build) object (add)
mySensor = Sensor(xmlSensor)
myTrajectory = Trajectory(xmlTrajectory) #pose (add) (link)

# MakeScene
myScene.build()
# Apply Sensor Parameters
mySensor.apply()
iCount = 0
for iPose in myTrajectory.Pose:
    iCount =   iCount + 1
    iPose.add(mySensor)
    iPose.link(iCount)
    if doRender:
        print('and Rendering')
        bpy.context.scene.camera = bpy.data.objects[iPose.name]
        bpy.context.scene.render.filepath = outputFolder + iPose.name
        bpy.ops.render.render( write_still=True )
        # update logfile
        # update extrinsics.txt