import xml.etree.ElementTree as ET
from Triplet import *
import bpy
from math import pi

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