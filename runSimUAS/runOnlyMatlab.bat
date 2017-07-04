SET EXPERIMENTNAME=demobeaver
cd ../matlab/postprocess
matlab -r postProcFolder('data/%EXPERIMENTNAME%',1)
cd ../../runSimUAS