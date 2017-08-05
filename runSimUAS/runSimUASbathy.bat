SET DNAME=R:\\simUASdata\\bathytest

SET EXPERIMENTNAME=BATHY001
cd ../python
blender --background --python renderblender.py -- %EXPERIMENTNAME% %DNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('%EXPERIMENTNAME%',1,'%DNAME%')
cd ../../runSimUAS