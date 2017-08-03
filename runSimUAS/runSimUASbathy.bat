SET EXPERIMENTNAME=bathytest\\BATHY001
SET DNAME=R:\\simUASdata
cd ../python
blender --background --python renderblender.py -- %DNAME%\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('%DNAME%/%EXPERIMENTNAME%',1)
cd ../../runSimUAS