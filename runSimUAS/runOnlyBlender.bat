SET EXPERIMENTNAME=topofield2b
cd ../python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../runSimUAS