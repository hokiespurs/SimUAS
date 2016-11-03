SET EXPERIMENTNAME=validateAccuracy1
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%')
cd ../..

SET EXPERIMENTNAME=validateAccuracy2
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%')
cd ../..

SET EXPERIMENTNAME=validateAccuracy3
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%')
cd ../..

SET EXPERIMENTNAME=validateAccuracy4
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%')
cd ../..

SET EXPERIMENTNAME=validateAccuracy5
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%')
cd ../..