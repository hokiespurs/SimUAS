SET EXPERIMENTNAME=validateAccuracy1
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

SET EXPERIMENTNAME=validateAccuracy2
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

SET EXPERIMENTNAME=validateAccuracy3
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

SET EXPERIMENTNAME=validateAccuracy4
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

SET EXPERIMENTNAME=validateAccuracy5
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

SET EXPERIMENTNAME=validateAccuracy1d
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

SET EXPERIMENTNAME=validateAccuracy2d
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

SET EXPERIMENTNAME=validateAccuracy3d
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

SET EXPERIMENTNAME=validateAccuracy4d
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

SET EXPERIMENTNAME=validateAccuracy5d
cd ./matlab/validatePhotogrammetry
matlab -r analyzeMarkerProjections('data/%EXPERIMENTNAME%',2,1)
cd ../..
timeout 150

pause