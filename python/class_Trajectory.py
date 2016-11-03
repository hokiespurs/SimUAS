import bpy
import xml.etree.ElementTree as ET
from math import pi
import logging
import csv


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
        # halfpixel = 0.5 / camSensor.renderresolution[0]
        halfpixel = 0  # remove the half pixel offset... need to test to make sure its still not needed
        bpy.context.object.data.shift_x = halfpixel + (camSensor.principalPoint[0] - camSensor.resolution[0] / 2) \
                                                      / -camSensor.renderresolution[0]
        bpy.context.object.data.shift_y = -halfpixel - (camSensor.principalPoint[1] - camSensor.resolution[1] / 2) \
                                                       / -camSensor.renderresolution[0]

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