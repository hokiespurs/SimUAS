import xml.etree.ElementTree as ET
import logging
import csv
import glob
import copy
import numpy as np
import math


def val_default(x, defaultx):
    if x is None:
        return defaultx
    else:
        return float(x)


def val_default_str(x, defaultx):
    if x is None:
        return defaultx
    else:
        return x


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


def rotatePoint(Points, Rotate, Translate, Scale):
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
        logging.debug(" PRE Rotation")
        logging.debug([Points.x[i], Points.y[i], Points.z[i]])
        logging.debug(" POST Rotation")
        logging.debug([newPoints.x[i], newPoints.y[i], newPoints.z[i]])

    return newPoints


class myPosition:
    class Xyzt:
        def __init__(self, x, y, z, t, const=1):
            X = 0
            Y = 0
            Z = 0
            T = 0
            self.x = val_default(x, X) * const
            self.y = val_default(y, Y) * const
            self.z = val_default(z, Z) * const
            self.t = val_default(t, T)

    def __init__(self, root):

        # Translation, Rotation, Scale
        self.T = self.calcXyzt(root.findall('translation'), 1)
        self.R = self.calcXyzt(root.findall('rotation'), math.pi/180)
        self.S = self.calcXyzt(root.findall('scale'), 1)

    def calcXyzt(self, allroot, const):
        X = list()
        for root in allroot:
            iT = self.Xyzt(root.get('x'),
                           root.get('y'),
                           root.get('z'),
                           root.get('t'),
                           const)
            X.append(iT)

        if len(X) == 0:
            X.append(self.Xyzt(0,0,0,0,1))
        return X


class Scene:
    class myEnvironment:
        class ELight:
            def __init__(self, envlight, t):
                ENVLIGHT = 0.2
                T = 0
                self.envlight = val_default(envlight, ENVLIGHT)
                self.t = val_default(t, T)

        class Ergbt:
            def __init__(self, rgb, t):
                RGB = (1, 1, 1)
                T = 0
                if rgb[0] is None:
                    self.rgb = RGB
                else:
                    self.rgb = (float(rgb[0]), float(rgb[1]), float(rgb[2]))

                self.t = val_default(t, T)

        def __init__(self, root):
            self.Light = list()
            self.Horizon = list()
            self.Zenith = list()
            if root is None:
                alightroot = None
                ahorizonroot = None
                azenithroot = None
            else:
                alightroot = root.findall('light')
                ahorizonroot = root.findall('horizon')
                azenithroot = root.findall('zenith')

            if alightroot is not None:
                for lightroot in alightroot:
                    ilight = lightroot.get('environmentlight')
                    it = lightroot.get('t')
                    self.Light.append(self.ELight(ilight, it))
            else:
                self.Light.append(self.ELight(None, None))

            if ahorizonroot is not None:
                for horizonroot in ahorizonroot:
                    irgb = (horizonroot.get('red'),
                            horizonroot.get('green'),
                            horizonroot.get('blue'))
                    it = horizonroot.get('t')
                    self.Horizon.append(self.Ergbt(irgb, it))
            else:
                self.Horizon.append(self.Ergbt((None, None, None), None))

            if azenithroot is not None:
                for zenithroot in azenithroot:
                    irgb = (zenithroot.get('red'),
                            zenithroot.get('green'),
                            zenithroot.get('blue'))
                    it = zenithroot.get('t')
                    self.Zenith.append(self.Ergbt(irgb,it))
            else:
                self.Zenith.append(self.Ergbt((None, None, None), None))

        def setDefaults(self):
            self.envlight = 0.5
            self.t_envlight = 0
            self.horizon = [(1, 1, 1)]
            self.t_horizon = 0
            self.zenith = [(1, 1, 1)]
            self.t_zenith = 0

    class myObject:
        class myMaterial:
            class rgbi:
                def __init__(self, root):
                    R = 0.5
                    G = 0.5
                    B = 0.5
                    I = 0.8
                    if root is None:
                        self.rgb = (R, G, B)
                        self.i = I
                    else:
                        r = root.get('red')
                        g = root.get('green')
                        b = root.get('blue')
                        i = root.get('intensity')

                        self.rgb = (val_default(r, R), val_default(g, G), val_default(b, B))
                        self.i = val_default(i, I)

            class MaterialShading:
                def __init__(self, root):
                    SHADELESS = 0
                    RECEIVE = 1
                    CAST = 1
                    if root is None:
                        self.shadeless = SHADELESS
                        self.receive = RECEIVE
                        self.cast = CAST
                    else:
                        shadeless = root.get('shadeless')
                        receive = root.get('receiveshadow')
                        cast = root.get('castshadow')
                        self.shadeless = val_default(shadeless, SHADELESS)
                        self.receive = val_default(receive, RECEIVE)
                        self.cast = val_default(cast, CAST)

            class MaterialTransparency:
                def __init__(self, root):
                    ALPHA = 1
                    IOR = 1
                    if root is None:
                        self.alpha = ALPHA
                        self.ior = IOR
                    else:
                        alpha = root.get('alpha')
                        ior = root.get('ior')
                        self.alpha = val_default(alpha, ALPHA)
                        self.ior = val_default(ior, IOR)

            def __init__(self, root):
                if root is None:
                    self.Diffuse = self.rgbi(None)
                    self.Specular = self.rgbi(None)
                    self.Shading = self.MaterialShading(None)
                    self.Transparency = self.MaterialTransparency(None)
                else:
                    self.Diffuse = self.rgbi(root.find('diffuse'))
                    self.Specular = self.rgbi(root.find('specular'))
                    self.Shading = self.MaterialShading(root.find('shading'))
                    self.Transparency = self.MaterialTransparency(root.find('transparency'))

        class myTexture:
            class mySlot:
                def __init__(self, root):
                    INTERP = 1
                    REPX = 1
                    REPY = 1
                    COLOR = 1
                    ALPHA = 0
                    NORMAL = 0
                    interp = root.get('interpolate')
                    fname = root.get('filename')
                    repx = root.get('repeatx')
                    repy = root.get('repeaty')
                    color = root.get('infcolor')
                    self.interpolate = val_default(interp, INTERP)
                    self.filename = fname
                    self.repx = val_default(repx, REPX)
                    self.repy = val_default(repy, REPY)
                    self.color = val_default(color, COLOR)

            def __init__(self, root):
                if root is None:
                    self.nSlots = 0
                else:
                    aslots = root.findall('slot')
                    self.nSlots = len(aslots)
                    self.Slot = list()
                    for slots in aslots:
                        self.Slot.append(self.mySlot(slots))

        def __init__(self, root):
            self.objname = root.get('objname')
            self.name = root.get('name')
            self.iscontrol = val_default(root.get('isControl'), 0)
            self.isfiducial = val_default(root.get('isFiducial'), 0)

            positionroot = root.find('position')
            self.Position = myPosition(positionroot)
            materialroot = root.find('material')
            self.Material = self.myMaterial(materialroot)
            textureroot = root.find('texture')
            self.Texture = self.myTexture(textureroot)

    class myLight:
        class myShadow:
            def __init__(self, shadow):
                ENABLED = 1
                QMC = 'Constant'
                SAMPLES = 1
                SOFTSIZE = 0.1
                if shadow is None:
                    self.enabled = ENABLED
                    self.qmc = QMC
                    self.samples = SAMPLES
                    self.softsize = SOFTSIZE
                else:
                    self.enabled = val_default(shadow.get('enabled'),ENABLED)
                    self.qmc = val_default_str(shadow.get('QMC'), QMC)
                    self.samples = val_default(shadow.get('samples'), SAMPLES)
                    self.softsize = val_default(shadow.get('softsize'), SOFTSIZE)
        class myEmission:
            class myColor:
                def __init__(self, root):
                    R = 1
                    G = 1
                    B = 1
                    I = 1
                    T = 0
                    if root is None:
                        self.rgb = (R, G, B)
                        self.i = I
                        self.t = T
                    else:
                        r = root.get('red')
                        g = root.get('green')
                        b = root.get('blue')
                        i = root.get('intensity')
                        t = root.get('t')
                        self.rgb = (val_default(r,R), val_default(g,G), val_default(b,B))
                        self.i = val_default(i,I)
                        self.t = val_default(t,T)

            def __init__(self, root):
                self.Color = list()
                if root is None:
                    self.Color.append(self.myColor(None))
                else:
                    allcolors = root.findall('color')
                    if allcolors is None:
                        self.Color.append(self.myColor(None))
                    else:
                        for color in allcolors:
                            self.Color.append(self.myColor(color))

        def __init__(self, root):
            self.type = root.get('type')
            emissionroot = root.find('emission')
            self.Emission = self.myEmission(emissionroot)
            positionroot = root.find('position')
            self.Position = myPosition(positionroot)
            shadow = root.find('shadow')
            self.Shadow = self.myShadow(shadow)

    def __init__(self, xmlName):
        logging.debug('Initializing Scene')
        try:
            tree = ET.parse(xmlName)
        except ET.ParseError:  # could not parse the xml file
            logging.error('Unable to Parse XML Scene')
            logging.error('Scene XML Name= ' + xmlName)
            print('ERROR: Unable to read Scene XML... file is poorly formatted')
            raise

        sceneroot = tree.getroot()
        if sceneroot.tag != 'scene':
            logging.error('Scene XML doesnt start with <scene> tag')
            logging.error('Scene XML Name= ' + xmlName)
            print('ERROR: Scene XML file doesnt start with a <scene> tag')
            raise SyntaxError

        self.name = sceneroot.get('name')
        self.objectdb = sceneroot.get('objectdb')
        self.version = sceneroot.get('version')

        self.Light = list()
        self.Object = list()

        # Parse Environment Structure
        logging.debug('Parsing Environment Structure')
        try:
            environmentroot = sceneroot.find('environment')
            self.Environment = self.myEnvironment(environmentroot)
        except:
            logging.error('Unable to Parse XML Scene Environment')
            logging.error('Scene XML Name = ' + xmlName)
            print('ERROR: Unable to read Scene XML: Environment')
            raise

        # Parse Array of Object Structures
        logging.debug('Parsing Objects')
        try:
            for objroot in sceneroot.findall('object'):
                logging.debug('Parsing Object: ' + objroot.get('name'))
                self.Object.append(self.myObject(objroot))

            if len(self.Object) == 0:
                logging.error('No Objects Found in XML File')
                logging.error('Scene XML Name = ' + xmlName)
                print('ERROR: No Objects found in XML File')
                raise SyntaxError
        except:
            logging.error('Unable to Parse XML Scene Objects')
            logging.error('Scene XML Name = ' + xmlName)
            print('ERROR: Unable to read Scene XML: Objects')
            raise

        # Parse Array of Light Structures
        logging.debug('Parsing Lights')
        try:
            for lightroot in sceneroot.findall('light'):
                logging.debug('Parsing Light Type: ' + lightroot.get('type'))
                self.Light.append(self.myLight(lightroot))

        except:
            logging.error('Unable to Parse XML Scene Lights')
            logging.error('Scene XML Name = ' + xmlName)
            print('ERROR: Unable to read Scene XML: Lights')
            raise

    def writeControlXYZ(self, fname):
        logging.debug('Writing Control to File: ' + fname)
        controlFileHandle = open(fname, 'w', newline='')
        controlwriter = csv.writer(controlFileHandle)
        controlHeader = ["ControlPointName", "Tx", "Ty", "Tz"]
        controlwriter.writerow(controlHeader)

        for iObj in self.Object:
            if iObj.iscontrol == 1:
                logging.debug('writing Control for : ' + iObj.name)
                controlwriter.writerow([iObj.name, iObj.Position.T[0].x, iObj.Position.T[0].y, iObj.Position.T[0].z])
                controlFileHandle.flush()

        controlFileHandle.close()
        logging.debug('Finished Writing Control')

    def writeFiducialXYZ(self, fname, rootname):
        logging.debug('Writing Fiducial to File: ' + fname)
        fiducialFileHandle = open(fname, 'w', newline='')
        fiducialwriter = csv.writer(fiducialFileHandle)
        fiducialHeader = ["objectName_fiducialName", "X", "Y", "Z"]
        fiducialwriter.writerow(fiducialHeader)

        for iObj in self.Object:
            if iObj.isfiducial == 1:
                logging.debug(iObj.name + " being used as fiducial")
                # load fiducial points from csv
                iPath = self.objectdb + '/' +  iObj.objname + "/"
                iPath.replace("\\", "/")
                try:
                    txtsearch = rootname + '/' + iPath + '*.txt'
                    fiducialtxtname = glob.glob(txtsearch)[0]
                except IndexError:
                    logging.error('Cant find Object Fiducial Txt file in : ' + rootname + "/" + iPath + '*.txt')
                    raise
                rawFiducialPts = readXyzCsv(fiducialtxtname)
                # rotate, translate, and scale fiducial points
                newFiducialPts = rotatePoint(rawFiducialPts, iObj.Position.R[0], iObj.Position.T[0], iObj.Position.S[0])
                # print to csv file
                for i in range(len(newFiducialPts.x)):
                    fiducialwriter.writerow([iObj.name + '_' + rawFiducialPts.names[i],
                                           newFiducialPts.x[i], newFiducialPts.y[i], newFiducialPts.z[i]])
                fiducialFileHandle.flush()

        fiducialFileHandle.close()
        logging.debug('finished writing fiducials')

if __name__ == '__main__':
    logging.basicConfig(filename='test.log', level=logging.DEBUG)
    xmlName = "C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest\\data\\lightnmove\\input\\scene_example.xml"
    Test = Scene(xmlName)
    Test.writeControlXYZ('C:/tmp/testControl.csv')
    Test.writeFiducialXYZ('C:/tmp/testFiducial.csv', 'C:/Users/Richie/Documents/GitHub/BlenderPythonTest')