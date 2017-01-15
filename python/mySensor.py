import xml.etree.ElementTree as ET
import logging
import math
import time
import numpy as np


class Sensor:
    def __init__(self, xmlsensor):
        # Default Clip for Z Buffer
        logging.debug('Initializing Sensor')
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

        correctionroot = root.find('correction')
        if correctionroot is None:
            self.exposure = None
            self.gamma = None
        else:
            self.exposure = float(correctionroot.get('exposure'))
            self.gamma = float(correctionroot.get('gamma'))

        f = self.resolution[0] / self.sensorWidth * self.focalLength
        self.padistortion = (self.distortion[0] / (f ** 2),
                             self.distortion[1] / (f ** 4),
                             self.distortion[2] / (f ** 6),
                             self.distortion[3] / (f ** 8),
                             self.distortion[4] / (f ** 1),
                             self.distortion[5] / (f ** 1))

        sx, sy = calcdistortionpadding(self.resolution, self.principalPoint, self.padistortion, self.percentage)

        self.renderresolution = (np.round(self.resolution[0]) * sx, np.round(self.resolution[1] * sy))
        self.rendersensorwidth = self.sensorWidth * sx
        logging.debug('Resolution Pre: (' + str(self.resolution[0]) + ' , ' + str(self.resolution[1]) + ')')
        logging.debug('Resolution Post: (' + str(self.renderresolution[0]) + ' , ' + str(self.renderresolution[1]) + ')')
        logging.debug('Sensor Width Pre: ' + str(self.sensorWidth))
        logging.debug('Sensor Width Post: ' + str(self.rendersensorwidth))
        logging.debug('Done Initializing Sensor')

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


def calcdistortionpadding(res, cxcy, distortion, percentage):
    topleft = calcDistortedCorner(0, 0, -1, -1, res, cxcy, distortion)
    topright = calcDistortedCorner(res[0], 0, 1, -1, res, cxcy, distortion)
    botleft = calcDistortedCorner(0, res[1], -1, 1, res, cxcy, distortion)
    botright = calcDistortedCorner(res[0], res[1], 1, 1, res, cxcy, distortion)
    logging.debug('Top left : (' + str(topleft[0]) + ' , ' + str(topleft[1]) + ')')
    logging.debug('Top right: (' + str(topright[0]) + ' , ' + str(topright[1]) + ')')
    logging.debug('Bot left : (' + str(botleft[0]) + ' , ' + str(botleft[1]) + ')')
    logging.debug('Bot right: (' + str(botright[0]) + ' , ' + str(botright[1]) + ')')

    padx = np.max((1 - topleft[0], 1 - botleft[0], topright[0] - res[0], botright[0] - res[0]))
    pady = np.max((1 - topleft[1], 1 - topright[1], botleft[1] - res[1], botright[1] - res[1]))

    # pad to largest number that is an integer when multiplied by percentage
    padx = np.ceil(padx * (percentage / 100)) / (percentage / 100)
    pady = np.ceil(pady * (percentage / 100)) / (percentage / 100)

    logging.debug('pad x = ' + str(padx) + '\t pad y = ' + str(pady))
    newresolution = (res[0] + 2 * padx, res[1] + 2 * pady)

    sx = newresolution[0] / res[0]
    sy = newresolution[1] / res[1]
    logging.debug('scale x = ' + str(sx) + '\t scale y = ' + str(sy))

    return sx, sy


def calcDistortedCorner(x, y, dx, dy, res, cxcy, distortion):
    xgood = False
    ygood = False
    count = 0
    while (not xgood or not ygood) and count < 1000:
        count += 1
        newx, newy = calcBrownDistortedCoords(x, y, cxcy[0], cxcy[1], distortion[0:4], distortion[4:6])
        inx, iny = inimage(newx, newy, res)

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
    logging.debug("Finding Corner Count: " + str(count))
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

if __name__ == '__main__':
    logging.basicConfig(filename='test.log', level=logging.DEBUG)
    xmlName = "C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest\\data\\validatePoint\\input\\sensor_A5000.xml"
    Test = Sensor(xmlName)
    Test.writeXML('C:/tmp/testSensor')
