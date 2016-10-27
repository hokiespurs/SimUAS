import logging
import bpy

def wipe():
    logging.info("Clearing all existing blender objects")
    scene = bpy.context.scene
    objs = bpy.data.objects
    meshes = bpy.data.meshes
    datcams = bpy.data.cameras.data.cameras
    cameras = bpy.data.cameras

    for obj in objs:
        scene.objects.unlink(obj)
        objs.remove(obj)

    for mesh in meshes:
        meshes.remove(mesh)

    for icam in datcams:
        bpy.data.cameras.remove(icam)

    for cam in cameras:
        cameras.remove(cam)


# Build Scene
def buildScene(Scene):
    print('building Scene')
    # wipe the scene
    wipe()
    # log some metadata about versions and whatnot
    logging.debug('Version: ' + str(bpy.data.version))

    # Name Scene
    blenderScene = bpy.data.scenes.values()[0]
    blenderScene.name = Scene.name

    # Set Environment Settings
    setEnvironment(blenderScene, Scene)

    # Add Lighting
    addLighting(blenderScene, Scene)

    # Add Objects
    addObjects(blenderScene, Scene)


def addObjects(blenderScene, Scene):
    for iObj in Scene.Object:
        iName = iObj.name
        iPath = Scene.dbfolder + "\\" + iObj.dbname + "\\"
        iPath.replace("\\", "\\\\")
        iObjFilepath = glob.glob(Scene.rootname + "\\" + iPath + '/*.obj')[0]

        bpy.ops.import_scene.obj(filepath=iObjFilepath, axis_forward="Y", axis_up="Z")
        bpy.data.objects[iObj.dbname].name = iName
        bpy.data.objects[iName].data.name = iName
        for activemat in bpy.data.objects[iName].material_slots.values():
            applyMaterial(activemat.material, iObj.Material)

        bpy.data.objects[iName].location = (iObj.Translation.x, iObj.Translation.y, iObj.Translation.z)
        bpy.data.objects[iName].rotation_mode = 'ZYX'
        bpy.data.objects[iName].rotation_euler = (iObj.Rotation.x, iObj.Rotation.y, iObj.Rotation.z)
        bpy.data.objects[iName].scale = (iObj.Scale.x, iObj.Scale.y, iObj.Scale.z)
        logging.debug('Added ' + iName + " to scene")


def applyMaterial(activematerial, material):
    tex = material.texture
    diffuse = material.diffuse
    alpha = material.alpha
    ior = material.ior
    dointerptex = material.dointerptex

    activematerial.use_shadeless = True

    if not activematerial.active_texture == None:
        if dointerptex == 0:
            activematerial.active_texture.filter_type = 'BOX'
            activematerial.active_texture.use_interpolation = False
            activematerial.active_texture.filter_size = 0.1

    if not (tex == None):
        try:
            if not (tex == "default" or tex == ""):
                activematerial.active_texture.image.filepath = self.rootname + "\\" + tex
            if tex == "":
                activematerial.texture_slots[0].use_map_color_diffuse = False
        except AttributeError:
            logging.info('error with texture')

        activematerial.diffuse_color = diffuse

        if alpha < 1:
            activematerial.transparency_method = "RAYTRACE"
            activematerial.alpha = alpha
            activematerial.raytrace_transparency.ior = ior


def addLighting(blenderScene, Scene):
    for Light in Scene.Light:
        if Light.type == 'sun' or Light.type == 'SUN':
            bpy.ops.object.lamp_add(type='SUN')
        elif Light.type == 'point' or Light.type == 'POINT':
            bpy.ops.object.lamp_add(type='POINT')
        obj = bpy.data.objects.values()[-1]  # last object added

        for T in Light.Position.T:
            blenderScene.frame_current = T.t
            obj.location = (T.x, T.y, T.z)
            obj.keyframe_insert(data_path='location')
        for R in Light.Position.R:
            blenderScene.frame_current = R.t
            obj.rotation_euler = (R.x, R.y, R.z)
            obj.keyframe_insert(data_path='rotation_euler')
        for color in Light.Emission.Color:
            blenderScene.frame_current = color.t
            obj.data.color = color.rgb
            obj.data.energy = color.i
            obj.data.keyframe_insert(data_path='color')
            obj.data.keyframe_insert(data_path='energy')

        setLinear(obj)
        setLinear(obj.data)

def setLinear(obj):
    fcurves = obj.animation_data.action.fcurves
    for fcurve in fcurves:
        for kf in fcurve.keyframe_points:
            kf.interpolation = 'LINEAR'


def setEnvironment(blenderScene, Scene):

    for Horizon in Scene.Environment.Horizon:
        blenderScene.frame_current = Horizon.t
        blenderScene.world.horizon_color = Horizon.rgb
        blenderScene.world.keyframe_insert(data_path="horizon_color")

    for Zenith in Scene.Environment.Zenith:
        blenderScene.frame_current = Zenith.t
        blenderScene.world.zenith_color = Zenith.rgb
        blenderScene.world.keyframe_insert(data_path="zenith_color")

    for Light in Scene.Environment.Light:
        blenderScene.frame_current = Light.t
        blenderScene.world.light_settings.use_environment_light = True
        blenderScene.world.light_settings.environment_energy = Light.envlight
        blenderScene.world.light_settings.environment_color = 'SKY_COLOR'
        blenderScene.world.light_settings.keyframe_insert(data_path="environment_energy")

    setLinear(blenderScene.world)
    setLinear(blenderScene.world.light_settings)

# Output OBJ File
def outputOBJ(foldername,t):
    print('output OBJ')

# Apply Sensor Parameters and Place Cameras
def addCameras(Sensor, Trajectory):
    print('add cameras')

# Render Imagery
def render():
    print('render images')
