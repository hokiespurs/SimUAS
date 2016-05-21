import bpy
import os
import random
from math import sin, cos, pi

DIST2CENTER = 10

def rtp2xyz(R,T,P):
    x_val = R * sin(P) * cos(T)
    y_val = R * sin(P) * sin(T)
    z_val = R * cos(P)
    return x_val, y_val, z_val

for i in range(0,100):
    iRange = DIST2CENTER
    iTheta = (random.random()) * 360 *pi/180
    iPhi = (random.random()) * 180 * pi/180
    iRoll = random.random() * 360 * pi/180
    x, y, z = rtp2xyz(iRange,iTheta,iPhi)
    bpy.ops.object.camera_add(view_align=True, enter_editmode=True, location=(x, y, z), rotation=(0, iPhi, iTheta))
    bpy.context.object.rotation_mode = 'QUATERNION'
    bpy.context.object.rotation_mode = 'ZYX'
    bpy.context.object.rotation_euler[2] = iRoll
    bpy.context.object.data.lens = 30+(i*0.5)
    camname = "IMG_%04.d" % (i)
    bpy.context.object.name = camname
    bpy.context.object.data.name = camname
    
    print(x)
    print(y)
    print(z)

i = 0

for ob in bpy.context.scene.objects:
    if ob.type == 'CAMERA':
        bpy.context.scene.camera = ob
        i=i+1
        camname = bpy.context.scene.camera.name
        file = os.path.join("C:/tmp", camname )
        bpy.context.scene.render.filepath = file
        bpy.ops.render.render( write_still=True )