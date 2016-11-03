SET EXPERIMENTNAME=validateAccuracy4
cd python
blender --background --python renderblender.py -- data\\%EXPERIMENTNAME%
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%')
cd ../..
cd ../matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%')
pause