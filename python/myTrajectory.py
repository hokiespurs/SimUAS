import xml.etree.ElementTree as ET
import logging
import csv
import math


def val_default(x, defaultx):
    if x is None:
        return defaultx
    else:
        return float(x)


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


class Trajectory:
    class myPose:
        def __init__(self, root):
            self.name = root.get('name')
            self.t = val_default(root.get('t'), 0)

            tx = float(root.find('translation').get('x'))
            ty = float(root.find('translation').get('y'))
            tz = float(root.find('translation').get('z'))
            rx = float(root.find('rotation').get('x')) * math.pi / 180
            ry = float(root.find('rotation').get('y')) * math.pi / 180
            rz = float(root.find('rotation').get('z')) * math.pi / 180

            self.Translation = Triplet(tx, ty, tz)
            self.Rotation = Triplet(rx, ry, rz)

    def __init__(self, xmlName):
        logging.debug('Initializing Trajectory')
        try:
            tree = ET.parse(xmlName)
        except ET.ParseError:  # could not parse the xml file
            logging.error('Unable to Parse XML Trajectory')
            logging.error('Trajectory XML Name= ' + xmlName)
            print('ERROR: Unable to read Trajectory XML... file is poorly formatted')
            raise

        trajroot = tree.getroot()
        if trajroot.tag != 'trajectory':
            logging.error('Trajectory XML doesnt start with <trajectory> tag')
            logging.error('Trajectory XML Name= ' + xmlName)
            print('ERROR: Trajectory XML file doesnt start with a <trajectory> tag')
            raise SyntaxError

        self.name = trajroot.get('name')
        self.version = trajroot.get('version')

        self.Pose = list()

        for iPose in trajroot.findall('pose'):
            self.Pose.append(self.myPose(iPose))

        if len(self.Pose) == 0:
            logging.error('No Camera Positions Found in XML Trajectory File')
            logging.error('Trajectory XML Name = ' + xmlName)
            print('ERROR: No Camera Positions Found in Trajectory XML File')
            raise SyntaxError

        logging.debug('Finished Initializing Trajectory Class')

    def writecsv(self, csvname):
        trajectoryFile = open(csvname, 'w', newline='')
        writer = csv.writer(trajectoryFile)
        trajectoryHeader = ["ImageName", "Tx", "Ty", "Tz", "Rx", "Ry", "Rz"]
        writer.writerow(trajectoryHeader)
        for iPose in self.Pose:
            rawrow = [iPose.name + '.png',
                      iPose.Translation.x,
                      iPose.Translation.y,
                      iPose.Translation.z,
                      iPose.Rotation.x * 180 / math.pi,
                      iPose.Rotation.y * 180 / math.pi,
                      iPose.Rotation.z * 180 / math.pi]
            writer.writerow(rawrow)

        trajectoryFile.close()

if __name__ == '__main__':
    logging.basicConfig(filename='test.log', level=logging.DEBUG)
    xmlName = "C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest\\data\\lightnmove\\input\\trajectory_grid.xml"
    Test = Trajectory(xmlName)
    Test.writecsv('C:/tmp/testTrajectory.csv')