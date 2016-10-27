import logging
import bpy
import glob

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
def buildScene(Scene, rootname):
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
    addObjects(blenderScene, Scene, rootname)


def addObjects(blenderScene, Scene, rootname):
    for iObj in Scene.Object:
        iName = iObj.name
        iPath = Scene.objectdb + "\\" + iObj.objname + "\\"
        iPath.replace("\\", "\\\\")
        print(rootname + "\\" + iPath + '/*.obj')
        iObjFilepath = glob.glob(rootname + "\\" + iPath + '/*.obj')[0]

        bpy.ops.import_scene.obj(filepath=iObjFilepath, axis_forward="Y", axis_up="Z")
        bpy.data.objects[iObj.objname].name = iName
        bpy.data.objects[iName].data.name = iName

        for T in iObj.Position.T:
            blenderScene.frame_current = T.t
            bpy.data.objects[iName].location = (T.x, T.y, T.z)
            bpy.data.objects[iName].keyframe_insert(data_path='location')

        for R in iObj.Position.R:
            blenderScene.frame_current = R.t
            bpy.data.objects[iName].rotation_mode = 'ZYX'
            bpy.data.objects[iName].rotation_euler = (R.x, R.y, R.z)
            bpy.data.objects[iName].keyframe_insert(data_path='rotation_euler')

        for S in iObj.Position.S:
            blenderScene.frame_current = S.t
            bpy.data.objects[iName].scale = (S.x, S.y, S.z)
            bpy.data.objects[iName].keyframe_insert(data_path='scale')
        setLinear(bpy.data.objects[iName])
        logging.debug('Added ' + iName + " to scene")
        logging.debug('Applying Material and Textures')
        nmaterials = len(bpy.data.objects[iName].material_slots.values())
        if nmaterials == 1:
            bpy.data.objects[iName].active_material.diffuse_color = iObj.Material.Diffuse.rgb
            bpy.data.objects[iName].active_material.diffuse_intensity = iObj.Material.Diffuse.i
            bpy.data.objects[iName].active_material.specular_color = iObj.Material.Specular.rgb
            bpy.data.objects[iName].active_material.specular_intensity = iObj.Material.Specular.i

        for matIndex in range(0, nmaterials):
            iMaterial = bpy.data.objects[iName].material_slots[matIndex].material
            if iObj.Material.Shading.shadeless == 1:
                iMaterial.use_shadeless = True
            else:
                iMaterial.use_shadeless = False

            if iObj.Material.Shading.receive == 1:
                iMaterial.use_shadows = True
            else:
                iMaterial.use_shadows = False

            if iObj.Material.Shading.cast == 1:
                iMaterial.use_cast_shadows = True
            else:
                iMaterial.use_cast_shadows = False

            if iObj.Material.Transparency.alpha != 1:
                iMaterial.use_transparency = True
                iMaterial.alpha = iObj.Material.Transparency.alpha
                iMaterial.transparency_method = 'RAYTRACE'
                iMaterial.raytrace_transparency.ior = iObj.Material.Transparency.ior
            else:
                iMaterial.use_transparency = False

        if iObj.Texture.nSlots > 0:
            # remove previous textures
            for i in range(0,10):
                bpy.data.objects[iName].active_material.texture_slots.clear(i)

            slotNum = 0
            for Slot in iObj.Texture.Slot:

                realpath = rootname + "\\" + Slot.filename
                try:
                    img = bpy.data.images.load(realpath)
                except:
                    raise NameError("Cannot load image %s" % realpath)

                cTex = bpy.data.textures.new(iObj.name + str(slotNum), type='IMAGE')
                cTex.image = img
                cTex.repeat_x = Slot.repx
                cTex.repeat_y = Slot.repy
                activematerial = bpy.data.objects[iName].active_material
                mtex = activematerial.texture_slots.add()
                mtex.texture = cTex
                mtex.texture_coords = 'UV'
                if Slot.interpolate == 0:
                    mtex.filter_type = 'BOX'
                    mtex.use_interpolation = False
                    mtex.filter_size = 0.1

                mtex.use_map_color_diffuse = True
                mtex.diffuse_color_factor = Slot.color
                slotNum += 1

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
            obj.rotation_mode = 'ZYX'
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
        if Light.Shadow.enabled == 1:
            obj.data.shadow_method = 'RAY_SHADOW'
        else:
            obj.data.shadow_method = 'NOSHADOW'

        if Light.Shadow.qmc == 'Constant':
            obj.data.shadow_ray_sample_method = 'CONSTANT_QMC'
        else:
            obj.data.shadow_ray_sample_method = 'ADAPTIVE_QMC'

        obj.data.shadow_ray_samples = Light.Shadow.samples
        obj.data.shadow_soft_size = Light.Shadow.softsize

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

# Output OBJ File
def outputOBJ(foldername,t):
    print('output OBJ')

# Apply Sensor Parameters and Place Cameras
def addCameras(Trajectory, Sensor):
    logging.debug('Adding Cameras to Scene')
    BlenderScene = bpy.data.scenes.values()[0]
    for iPose in Trajectory.Pose:
        T = (iPose.Translation.x, iPose.Translation.y, iPose.Translation.z)
        R = (iPose.Rotation.x, iPose.Rotation.y, iPose.Rotation.z)
        bpy.ops.object.camera_add(view_align=True, enter_editmode=True, location=T, rotation=(0, 0, 0))
        bpy.context.object.rotation_euler = R
        bpy.context.object.data.sensor_width = Sensor.rendersensorwidth
        xyRatio = Sensor.renderresolution[1] / Sensor.renderresolution[0]
        bpy.context.object.data.sensor_height = Sensor.rendersensorwidth * xyRatio
        # calculate lens angle in degrees
        f = Sensor.focalLength

        bpy.context.object.data.lens_unit = 'MILLIMETERS'
        bpy.context.object.data.lens = f
        logging.debug(["Set focal length to: " + str(f)])
        # clipping constants
        bpy.context.object.data.clip_end = Sensor.clipEnd
        bpy.context.object.data.clip_start = Sensor.clipStart

        bpy.context.object.data.shift_x = (Sensor.principalPoint[0] - Sensor.resolution[0] / 2) \
                                            / -Sensor.renderresolution[0]
        bpy.context.object.data.shift_y = - (Sensor.principalPoint[1] - Sensor.resolution[1] / 2) \
                                            / -Sensor.renderresolution[0]

        logging.debug(bpy.context.object.data.shift_x)
        logging.debug(bpy.context.object.data.shift_y)

        bpy.context.object.name = iPose.name
        bpy.context.object.data.name = iPose.name
        logging.debug("Added Pose: " + iPose.name)
        curType = bpy.context.area.type
        bpy.context.area.type = 'TIMELINE'
        bpy.context.scene.camera = bpy.data.objects[iPose.name]
        BlenderScene.frame_current = iPose.t
        bpy.ops.marker.add()
        bpy.ops.marker.camera_bind()
        logging.debug("Linking: " + iPose.name)
        bpy.context.area.type = curType

# Render Imagery
def render(Trajectory, outputFolder):
    print('render images')
    BlenderScene = bpy.data.scenes.values()[0]
    for iPose in Trajectory.Pose:
        BlenderScene.frame_current = iPose.t
        logging.debug("Rendering [" + iPose.name + "] started")
        bpy.context.scene.render.filepath = outputFolder + "/" + iPose.name
        logging.debug("Writing to: " + outputFolder + "/" + iPose.name)
        bpy.ops.render.render(write_still=True)
        logging.debug("Rendered Finished")

def applyRenderSettings(Sensor):
    logging.debug('Applying render settings')
    bpy.context.scene.render.resolution_percentage = Sensor.percentage
    bpy.context.scene.render.use_stamp_lens = True  # Lens in Metadata
    bpy.context.scene.render.resolution_x = Sensor.renderresolution[0]
    bpy.context.scene.render.resolution_y = Sensor.renderresolution[1]
    bpy.context.scene.render.use_antialiasing = Sensor.antialiasing
    bpy.context.scene.render.image_settings.compression = Sensor.compression
    bpy.context.scene.render.image_settings.file_format = Sensor.fileformat