SET EXPERIMENTNAME=demobeaver
cd ../python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../runSimUAS