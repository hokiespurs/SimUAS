function writeprocsettings(fname,varargin)

%% Input Parser
% defaults
defaultprojectname       = 'simUASprocessing';
defaultrootname          = '';
defaultimagestouse       = '';
defaultsensorname        = '';
defaultsensorlock        = false;
defaulttrajectory        = '';
defaultcontrol           = '';

defaultcamposacc         = 10;
defaultcamrotacc         = 2;
defaultmarkeracc         = 0.005;
defaultscalebaracc       = 0.001;
defaultimagemarkeracc    = 0.1;
defaultimagetiepointacc  = 2;
defaultgroundalt         = [];

defaultoptimize          = true;
defaultoptimizefits      = '11100111011000';

defaultsparseacc         = 'medium';
defaultgenericpre        = true;
defaultreferencepre      = true;
defaultkeypointlim       = 40000;
defaulttiepointlim       = 4000;
defaultadaptivecam       = true;

defaultdensequality      = 'medium';
defaultdepthfilt         = 'aggressive';

defaultlogfile           = 'photoscanlog.log';
defaultreportname        = 'report.pdf';
defaultsparseoutname     = 'sparse.las';
defaultdenseoutname      = 'dense.las';
defaultcamcaloutname     = 'sensorcalib.xml';
defaulttrajectoryoutname = 'trajectory.xml';
defaultmarkeroutname     = '';
defaultmatchesoutname    = '';

defaultreprocmvsfolder   = 'las';
defaultreprocmvsqual     = '00000';
defaultreptocmvsfilt     = '0000';

% checks (Lazy so haven't input them)
checkprojectname       = @(x) true;
checkrootname          = @(x) true;
checkimagefoldername   = @(x) true;
checkimagestouse       = @(x) true;
checksensorname        = @(x) true;
checksensorlock        = @(x) true;
checktrajectory        = @(x) true;
checkcontrol           = @(x) true;
checkcamposacc         = @(x) true;
checkcamrotacc         = @(x) true;
checkmarkeracc         = @(x) true;
checkscalebaracc       = @(x) true;
checkimagemarkeracc    = @(x) true;
checkimagetiepointacc  = @(x) true;
checkgroundalt         = @(x) true;
checkoptimize          = @(x) true;
checkoptimizefits      = @(x) true;
checksparseacc         = @(x) true;
checkgenericpre        = @(x) true;
checkreferencepre      = @(x) true;
checkkeypointlim       = @(x) true;
checktiepointlim       = @(x) true;
checkadaptivecam       = @(x) true;
checkdensequality      = @(x) true;
checkdepthfilt         = @(x) true;
checkoutputroot        = @(x) true;
checklogfile           = @(x) true;
checkreportname        = @(x) true;
checksparseoutname     = @(x) true;
checkdenseoutname      = @(x) true;
checkcamcaloutname     = @(x) true;
checktrajectoryoutname = @(x) true;
checkmarkeroutname     = @(x) true;
checkmatchesoutname    = @(x) true;
checkreprocmvsfolder   = @(x) true;
checkreprocmvsqual     = @(x) true;
checkreprocmvsfilt     = @(x) true;
% Parser
% addRequired(p,strname,checkfun)
% addParameter(p,strname,defaultval,checkfun)
p = inputParser;
addParameter(p,'projectname'       ,defaultprojectname       ,checkprojectname       )
addParameter(p,'rootname'          ,defaultrootname          ,checkrootname          )
addParameter(p,'imagefoldername'   ,[]                       ,checkimagefoldername   )
addParameter(p,'imagestouse'       ,defaultimagestouse       ,checkimagestouse       )
addParameter(p,'sensorname'        ,defaultsensorname        ,checksensorname        )
addParameter(p,'sensorlock'        ,defaultsensorlock        ,checksensorlock        )
addParameter(p,'trajectory'        ,defaulttrajectory        ,checktrajectory        )
addParameter(p,'control'           ,defaultcontrol           ,checkcontrol           )
addParameter(p,'camposacc'         ,defaultcamposacc         ,checkcamposacc         )
addParameter(p,'camrotacc'         ,defaultcamrotacc         ,checkcamrotacc         )
addParameter(p,'markeracc'         ,defaultmarkeracc         ,checkmarkeracc         )
addParameter(p,'scalebaracc'       ,defaultscalebaracc       ,checkscalebaracc       )
addParameter(p,'imagemarkeracc'    ,defaultimagemarkeracc    ,checkimagemarkeracc    )
addParameter(p,'imagetiepointacc'  ,defaultimagetiepointacc  ,checkimagetiepointacc  )
addParameter(p,'groundalt'         ,defaultgroundalt         ,checkgroundalt         )
addParameter(p,'optimize'          ,defaultoptimize          ,checkoptimize          )
addParameter(p,'optimizefits'      ,defaultoptimizefits      ,checkoptimizefits      )
addParameter(p,'sparseacc'         ,defaultsparseacc         ,checksparseacc         )
addParameter(p,'genericpre'        ,defaultgenericpre        ,checkgenericpre        )
addParameter(p,'referencepre'      ,defaultreferencepre      ,checkreferencepre      )
addParameter(p,'keypointlim'       ,defaultkeypointlim       ,checkkeypointlim       )
addParameter(p,'tiepointlim'       ,defaulttiepointlim       ,checktiepointlim       )
addParameter(p,'adaptivecam'       ,defaultadaptivecam       ,checkadaptivecam       )
addParameter(p,'densequality'      ,defaultdensequality      ,checkdensequality      )
addParameter(p,'depthfilt'         ,defaultdepthfilt         ,checkdepthfilt         )
addParameter(p,'outputroot'        ,[]                       ,checkoutputroot        )
addParameter(p,'logfile'           ,defaultlogfile           ,checklogfile           )
addParameter(p,'reportname'        ,defaultreportname        ,checkreportname        )
addParameter(p,'sparseoutname'     ,defaultsparseoutname     ,checksparseoutname     )
addParameter(p,'denseoutname'      ,defaultdenseoutname      ,checkdenseoutname      )
addParameter(p,'camcaloutname'     ,defaultcamcaloutname     ,checkcamcaloutname     )
addParameter(p,'trajectoryoutname' ,defaulttrajectoryoutname ,checktrajectoryoutname )
addParameter(p,'markeroutname'     ,defaultmarkeroutname     ,checkmarkeroutname     )
addParameter(p,'matchesoutname'    ,defaultmatchesoutname    ,checkmatchesoutname    )
addParameter(p,'reprocmvsfolder'   ,defaultreprocmvsfolder   ,checkreprocmvsfolder   )
addParameter(p,'reprocmvsqual'     ,defaultreprocmvsqual     ,checkreprocmvsqual     )
addParameter(p,'reprocmvsfilt'     ,defaultreptocmvsfilt     ,checkreprocmvsfilt     )

% parse
parse(p,varargin{:});

%% Read in Template
TEMPLATENAME = 'procsetting_template.xml';
fidRead = fopen(TEMPLATENAME);
data = fread(fidRead,'*char');
fclose(fidRead);
data = strrep(data','\','\\')';

%% Make New File
fid = fopen(fname,'w');
x = p.Results;
fprintf(fid,data,...
    x.projectname,...
	x.rootname,...
	x.imagefoldername,...
	sprintf('%i',x.imagestouse),...
	x.sensorname,...
	x.sensorlock,...
	x.trajectory,...
	x.control,...
	x.camposacc,...
	x.camrotacc,...
	x.markeracc,...
	x.scalebaracc,...
	x.imagemarkeracc,...
	x.imagetiepointacc,...
	x.groundalt,...
	x.optimize,...
	x.optimizefits,...
	x.sparseacc,...
	x.genericpre,...
	x.referencepre,...
	x.keypointlim,...
	x.tiepointlim,...
	x.adaptivecam,...
	x.densequality,...
	x.depthfilt,...
	x.outputroot,...
	x.logfile,...
	x.reportname,...
	x.sparseoutname,...
	x.denseoutname,...
	x.camcaloutname,...
	x.trajectoryoutname,...
	x.markeroutname,...
	x.matchesoutname,...
    x.reprocmvsfolder,...
    x.reprocmvsqual,...
    x.reprocmvsfilt);
fclose(fid);
end