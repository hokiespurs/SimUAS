function writeSensor(fname,varargin)

%% Input Parse
% Default values
defaultSensorName = 'Camera';
defaultFileformat = 'PNG';
defaultfocallength = 16;
defaultWidth = 20;
defaultResolution = [2000 2000];
defaultPrincipalPoint = [1000 1000];
defaultCompression = 100;
defaultPercentage = 100;
defaultAntiAliasing = 1;
defaultSeed = 1;
defaultDistortion = [0 0 0 0 0 0];
defaultVignetting = [0 0 0];
defaultIsPhotoscan = 1;
defaultSaltProb = 0;
defaultPepperProb = 0;
defaultGaussianNoise = [0 0];
defaultGaussianBlur = 0;

% Check Handles
checkSensorName = @(x) ischar(x);
checkFileformat = @(x) ischar(x);
checkFocalLength = @(x) isnumeric(x);
checkWidth = @(x) isnumeric(x) && x>0;
checkResolution = @(x) all(isnumeric(x) & x>0);
checkPrincipalPoint = @(x) all(isnumeric(x) & x>0);
checkCompression = @(x) isnumeric(x) & x>0;
checkPercentage = @(x) isnumeric(x) & x>0;
checkAntiAliasing = @(x) x==0 || x==1;
checkSeed = @(x) isnumeric(x) & x>0;
checkDistortion = @(x) all(isnumeric(x));
checkVignetting = @(x) all(isnumeric(x));
checkIsPhotoscan = @(x) x==0 || x==1;
checkSaltProb = @(x) isnumeric(x) && x>0;
checkPepperProb = @(x) isnumeric(x) && x>0;
checkGaussianNoise = @(x) isnumeric(x);
checkGaussianBlur = @(x) isnumeric(x) && x>0;

% Parse
p = inputParser;

addParameter(p,'sensorname'      ,defaultSensorName     ,checkSensorName);
addParameter(p,'fileformat'      ,defaultFileformat     ,checkFileformat);
addParameter(p,'focallength'     ,defaultfocallength    ,checkFocalLength);
addParameter(p,'sensorwidth'     ,defaultWidth          ,checkWidth);
addParameter(p,'resolution'      ,defaultResolution     ,checkResolution);
addParameter(p,'principalpoint'  ,defaultPrincipalPoint ,checkPrincipalPoint);
addParameter(p,'compression'     ,defaultCompression    ,checkCompression);
addParameter(p,'percentage'      ,defaultPercentage     ,checkPercentage);
addParameter(p,'antialiasing'    ,defaultAntiAliasing   ,checkAntiAliasing);
addParameter(p,'seed'            ,defaultSeed           ,checkSeed);
addParameter(p,'distortion'      ,defaultDistortion     ,checkDistortion);
addParameter(p,'vignetting'      ,defaultVignetting     ,checkVignetting);
addParameter(p,'isphotoscan'     ,defaultIsPhotoscan    ,checkIsPhotoscan);
addParameter(p,'saltprob'        ,defaultSaltProb       ,checkSaltProb);
addParameter(p,'pepperprob'      ,defaultPepperProb     ,checkPepperProb);
addParameter(p,'gaussianNoise'   ,defaultGaussianNoise  ,checkGaussianNoise);
addParameter(p,'gaussianBlur'    ,defaultGaussianBlur   ,checkGaussianBlur);

parse(p,varargin{:});

%% Read in Template
TEMPLATENAME = 'sensor_template.xml';
fidRead = fopen(TEMPLATENAME);
data = fread(fidRead,'*char');
fclose(fidRead);
data = strrep(data','\','\\')';

%% Make New File
fid = fopen(fname,'w');
x = p.Results;
fprintf(fid,data,x.sensorname,x.fileformat,x.focallength,x.sensorwidth,...
    x.resolution,x.principalpoint,x.compression,x.percentage,...
    x.antialiasing,x.seed,x.distortion,x.isphotoscan,x.vignetting,...
    x.saltprob,x.pepperprob,x.gaussianNoise,x.gaussianBlur);
fclose(fid);


end