SET EXPERIMENTNAME=validateAccuracy1
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
delay 600

SET EXPERIMENTNAME=validateAccuracy2
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
delay 600

SET EXPERIMENTNAME=validateAccuracy3
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
delay 600

SET EXPERIMENTNAME=validateAccuracy4
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
delay 600

SET EXPERIMENTNAME=validateAccuracy5
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
delay 600

SET EXPERIMENTNAME=validateAccuracy1d
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
delay 600

SET EXPERIMENTNAME=validateAccuracy2d
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
delay 600

SET EXPERIMENTNAME=validateAccuracy3d
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
delay 600

SET EXPERIMENTNAME=validateAccuracy4d
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
delay 600

SET EXPERIMENTNAME=validateAccuracy5d
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../..
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',1,1)
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..

pause
