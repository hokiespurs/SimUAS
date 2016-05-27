import xml.etree.ElementTree as ET
import bpy

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
