import sys
import numpy as np
from scipy import misc
from scipy import ndimage
import matplotlib.pyplot as plt
from scipy.interpolate import griddata


def saveBrownDistortedImage(filename, outputfilename, k, p, xc, yc):
    # load image
    img_array = misc.imread(filename)

    # get xu, yu coordinates
    ly, lx, lz = img_array.shape
    xu, yu = np.meshgrid(range(0, lx), range(0, ly))

    # calculate distorted coordinates
    xd, yd = calcBrownDistortedCoords(xu, yu, xc, yc, k, p)

    # do bilinear interpolation
    image_array_distorted = calcBilinearInterpImage(xu, yu, xd, yd, img_array)

    # save Image
    saveImage(outputfilename, image_array_distorted)


def makeQuiver(xd, yd, xu, yu):
    plt.figure()
    u = xd-xu
    v = yd-yu
    n = 15
    Q = plt.quiver(xu[::n, ::n], yu[::n, ::n], u[::n, ::n], v[::n, ::n])
    plt.show()


def calcBrownDistortedCoords(xu, yu, xc, yc, k, p):
    # radial distortion
    r = np.sqrt((xu - xc) ** 2 + (yu - yc) ** 2)
    dx_radial = (xu - xc) * (1 + (k[0] * r ** 2) + (k[1] * r ** 4) + (k[2] * r ** 6) + (k[3] * r ** 8))
    dy_radial = (yu - yc) * (1 + (k[0] * r ** 2) + (k[1] * r ** 4) + (k[2] * r ** 6) + (k[3] * r ** 8))

    # tangential distortion
    dx_tangential = (p[0] * (r**2 + 2*(xu - xc)**2) + 2 * p[1] * (xu - xc) * (yu - yc))
    dy_tangential = (p[1] * (r**2 + 2*(yu - yc)**2) + 2 * p[0] * (xu - xc) * (yu - yc))

    # calculate distorted coordinate
    xd = np.array(xc + dx_radial + dx_tangential)
    yd = np.array(yc + dy_radial + dy_tangential)

    return xd, yd


def calcBilinearInterpImage(xu, yu, xd, yd, img_array):
    #convert xd, yd coordinates to image coordinates
    distortedpoints = np.array((np.hstack(xd), np.hstack(yd))).T
    imagePoints = (xu, yu)
    img_array_distorted = img_array.copy()

    for i in range(0,img_array.shape[2]):
        imageValues = np.hstack(img_array[:, :, i])
        newImageValues = griddata(distortedpoints, imageValues, imagePoints, method='linear')
        newImageValues[np.isnan(newImageValues)] = 0
        img_array_distorted[:, :, i] = newImageValues

    return img_array_distorted


def saveImage(filename, img_array):
    misc.imsave(filename, img_array)

def readPhotoscanCalibrationXML(xmlfilename):

    fx, fy, cx, cy, k, p = (0, 0, 0, 0, 0, 0)

    return cx, cy, k, p


def normalizePhotoscanDistortion(k, p, f):
    for i in range(0,len(k)):
        k[i] = k[i]/(f**(2*(i+1)))

    for i in range(0,len(p)):
        p[i] = p[i]/f**2

    return 0


if __name__ == '__main__':
#    filename = sys.argv[1]
#    outputname = sys.argv[2]
#    k = np.array((sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]))
#    p = np.array((sys.argv[7], sys.argv[8]))
#    xc = sys.argv[9]
#    yc = sys.argv[10]
#    fx = sys.argv[11]
#    fy = sys.argv[12]


    # dummy data
    filename = 'C:/Users/Richie/Documents/GitHub/BlenderPythonTest/python/distortImage/face.png'
    outputname = 'C:/Users/Richie/Documents/GitHub/BlenderPythonTest/python/distortImage/face_dist.png'
    k = np.array((-0.057964277585941942, 0.074910467879875708, -0.027975957030031758, 0)) * 100
    p = np.array((-0.02, 0.02)) * 100
    xc = 250
    yc = 250
    fx = 3683
    fy = 3683


    f = (fx + fy) / 2
    normalizePhotoscanDistortion(k, p, f)

    saveBrownDistortedImage(filename, outputname, k, p, xc, yc)