SET EXPERIMENTNAME=calroom
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%')
cd ../..
pause