SET EXPERIMENTNAME=bathytest\BATHY001
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY004
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY007
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY010
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

