SET EXPERIMENTNAME=bathytest\BATHY003
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY006
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY009
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY012
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY015
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

