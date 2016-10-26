import xml.etree.ElementTree as ET
import logging


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

class myPosition:
    class Xyzt:
        def __init__(self, x, y, z, t):
            X = 0
            Y = 0
            Z = 0
            T = 0
            self.x = val_default(x, X)
            self.y = val_default(y, Y)
            self.z = val_default(z, Z)
            self.t = val_default(t, T)

    def __init__(self, root):
        self.interp = root.get('interpolation')
        if self.interp is None:
            self.interp = 'linear'

        # Translation, Rotation, Scale
        self.T = self.calcXyzt(root.findall('translation'))
        self.R = self.calcXyzt(root.findall('rotation'))
        self.S = self.calcXyzt(root.findall('scale'))

    def calcXyzt(self, allroot):
        X = list()
        for root in allroot:
            iT = self.Xyzt(root.get('x'),
                                      root.get('y'),
                                      root.get('z'),
                                      root.get('t'))
            X.append(iT)

        if len(X) == 0:
            X.append(self.Xyzt(0,0,0,0))
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

            alightroot = root.findall('light')
            ahorizonroot = root.findall('horizon')
            azenithroot = root.findall('zenith')
            if alightroot is not None:
                for lightroot in alightroot:
                    ilight = lightroot.get('environmentlight')
                    it = lightroot.get('t')
                    self.Light.append(self.ELight(ilight,it))
            else:
                self.Light.append(self.ELight(None, None))

            if ahorizonroot is not None:
                for horizonroot in ahorizonroot:
                    irgb = (horizonroot.get('red'),
                            horizonroot.get('green'),
                            horizonroot.get('blue'))
                    it = horizonroot.get('t')
                    self.Horizon.append(self.Ergbt(irgb,it))
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
                    alpha = root.get('infalpha')
                    normal = root.get('infnormal')
                    self.interpolate = val_default(interp, INTERP)
                    self.filename = fname
                    self.repx = val_default(repx, REPX)
                    self.repy = val_default(repy, REPY)
                    self.color = val_default(color, COLOR)
                    self.alpha = val_default(alpha, ALPHA)
                    self.normal = val_default(normal, NORMAL)

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
                SAMPLES = '1'
                SOFTSIZE = '0.1'
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

        def __init__(self, root):
            self.type = root.get('type')
            self.intensity = root.get('intensity')

            positionroot = root.find('position')
            self.Position = myPosition(positionroot)
            shadow = root.find('shadow')
            self.Shadow = self.myShadow(shadow)

    def __init__(self, xmlName):
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
        try:
            environmentroot = sceneroot.find('environment')
            self.Environment = self.myEnvironment(environmentroot)
        except:
            logging.error('Unable to Parse XML Scene Environment')
            logging.error('Scene XML Name = ' + xmlName)
            print('ERROR: Unable to read Scene XML: Environment')
            raise

        # Parse Array of Object Structures
        try:
            for objroot in sceneroot.findall('object'):
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
        try:
            for lightroot in sceneroot.findall('light'):
                self.Light.append(self.myLight(lightroot))

        except:
            logging.error('Unable to Parse XML Scene Lights')
            logging.error('Scene XML Name = ' + xmlName)
            print('ERROR: Unable to read Scene XML: Lights')
            raise

if __name__ == '__main__':
    logging.basicConfig(filename='test.log', level=logging.DEBUG)
    xmlName = "C:\\Users\\Richie\\Documents\\GitHub\\BlenderPythonTest\\data\\lightnmove\\input\\scene_example.xml"
    Test = Scene(xmlName)
    print(Test)
