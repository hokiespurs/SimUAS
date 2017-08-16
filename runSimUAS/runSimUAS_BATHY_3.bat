SET DNAME=E:\\bathytestdata

SET EXPERIMENTNAME=BATHY099
cd ../python
blender --background --python renderblender.py -- %EXPERIMENTNAME% %DNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('%EXPERIMENTNAME%',1,'%DNAME%')
cd ../../runSimUAS

SET EXPERIMENTNAME=BATHY102
cd ../python
blender --background --python renderblender.py -- %EXPERIMENTNAME% %DNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('%EXPERIMENTNAME%',1,'%DNAME%')
cd ../../runSimUAS

SET EXPERIMENTNAME=BATHY105
cd ../python
blender --background --python renderblender.py -- %EXPERIMENTNAME% %DNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('%EXPERIMENTNAME%',1,'%DNAME%')
cd ../../runSimUAS

SET EXPERIMENTNAME=BATHY108
cd ../python
blender --background --python renderblender.py -- %EXPERIMENTNAME% %DNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('%EXPERIMENTNAME%',1,'%DNAME%')
cd ../../runSimUAS

SET EXPERIMENTNAME=BATHY111
cd ../python
blender --background --python renderblender.py -- %EXPERIMENTNAME% %DNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('%EXPERIMENTNAME%',1,'%DNAME%')
cd ../../runSimUAS

