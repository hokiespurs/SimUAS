import xml.etree.ElementTree as ET
from Triplet import *

class Pose:
    def __init__(self, name, tx, ty, tz, rx, ry, rz):
        self.Translation = Triplet(tx,ty,tz)
        self.Rotation = Triplet(rx,ry,rz)
        self.name = name

    def add(self):
        print("ADDING POSE" + self.name)

    def link(self):
        print("Linking" + self.name)

class Trajectory:
    def __init__(self, xmlExtrinsics):
        self.foo = ""
        # tree = ET.parse(xmlExtrinsics)
        # root = tree.getroot()
        myPose = list()
        for i in range(0, 10):
            iPose = Pose('test', i, 2, 3, 4, 5, 6)
            myPose.append(iPose)
        self.Pose = myPose