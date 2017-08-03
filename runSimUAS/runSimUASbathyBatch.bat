SET EXPERIMENTNAME=bathytest\BATHY001
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY002
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY003
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

SET EXPERIMENTNAME=bathytest\BATHY005
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

SET EXPERIMENTNAME=bathytest\BATHY007
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY008
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

SET EXPERIMENTNAME=bathytest\BATHY010
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY011
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

SET EXPERIMENTNAME=bathytest\BATHY013
cd ../python
blender --background --python renderblender.py -- data\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS

SLEEP 600

SET EXPERIMENTNAME=bathytest\BATHY014
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

