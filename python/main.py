from Scene import Scene
from Sensor import Sensor
from Trajectory import Trajectory
from delobjects import wipe
import bpy

wipe()  # clear all objects

# User defined textbook
outputFolder = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/output/"
xmlLibrary = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/xml/objectLibrary.xml"
xmlScene = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/xml/scene.xml"
xmlSensor = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/xml/sensor.xml"
xmlTrajectory = "C:/Users/Richie/Documents/GitHub/BlenderPythonTest/xml/Extrinsics.xml"
doRender = True

# Populate Classes
myScene = Scene(xmlLibrary,xmlScene) # (build) object (add)
mySensor = Sensor(xmlSensor)
myTrajectory = Trajectory(xmlTrajectory) #pose (add) (link)

# MakeScene
myScene.build()
# Apply Sensor Parameters
mySensor.apply()
iCount = 0
for iPose in myTrajectory.Pose:
    iCount =   iCount + 1
    iPose.add(mySensor)
    iPose.link(iCount)
    if doRender:
        print('and Rendering')
        bpy.context.scene.camera = bpy.data.objects[iPose.name]
        bpy.context.scene.render.filepath = outputFolder + iPose.name
        bpy.ops.render.render( write_still=True )
        # update logfile
        # update extrinsics.txt