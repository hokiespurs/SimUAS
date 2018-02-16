function str = addSceneEnvironment(varargin)
% ADDSCENEENVIRONMENT Short summary of this function goes here
%   Detailed explanation goes here
%
% Optional Inputs: (default)
%	- 'envlight'     : ([]) *description* 
%	- 'envlighttime' : ([]) *description* 
%   - 'envcolor'     : ('sky') *description*
%	- 'horizonRGB'   : ([]) *description* 
%	- 'horizontime'  : ([]) *description* 
%	- 'zenithRGB'    : ([]) *description* 
%	- 'zenithtime'   : ([]) *description* 
%
% Outputs:
%   - str: string output for environment in scene xml
% 
% Examples:
%   - n/a
% 
% Dependencies:
%   - n/a
% 
% Toolboxes Required:
%   - n/a
% 
% Author        : Richie Slocum
% Email         : richie@cormorantanalytics.com
% Date Created  : 31-Jan-2018
% Date Modified : 31-Jan-2018
% Github        :


%% Function Call
[envlight,envlighttime,envcolor,horizonRGB,horizontime,zenithRGB,zenithtime] = parseInputs(varargin{:});

%% Add parameters to str
str = [];
if ~isempty(envlight) && ~isempty(horizonRGB) && ~isempty(zenithRGB)
    str = [str '<environment>\n'];
    if ~isempty(envlight)
        for i=1:numel(envlight)
            str = [str sprintf('\t<light environmentlight="%g" color = "%s" t="%g"/>\n',...
                envlight(i),envcolor,envlighttime(i))];
        end
    end
    
    if ~isempty(horizonRGB)
        for i=1:numel(horizontime)
           str = [str sprintf('\t<horizon red="%g" green="%g" blue="%g" t="%g"/>\n',...
               horizonRGB(i,1),horizonRGB(i,2),horizonRGB(i,3),horizontime(i))];
        end
    end
    
    if ~isempty(zenithRGB)
        for i=1:numel(zenithtime)
           str = [str sprintf('\t<zenith red="%g" green="%g" blue="%g" t="%g"/>\n',...
               zenithRGB(i,1),zenithRGB(i,2),zenithRGB(i,3),zenithtime(i))];
        end
    end
    
    str = [str '</environment>\n'];
end

end

function [envlight,envlighttime,envcolor,horizonRGB,horizontime,zenithRGB,zenithtime] = parseInputs(varargin)
%%	 Call this function to parse the inputs

% Default Values
default_envlight      = [];
default_envlighttime  = [];
default_envcolor      = 'sky';
default_horizonRGB    = [];
default_horizontime   = [];
default_zenithRGB     = [];
default_zenithtime    = [];

% Check Values
check_envlight      = @(x) true;
check_envlighttime  = @(x) true;
check_envcolor      = @(x) true;
check_horizonRGB    = @(x) true;
check_horizontime   = @(x) true;
check_zenithRGB     = @(x) true;
check_zenithtime    = @(x) true;

% Parser Values
p = inputParser;
% Parameter Arguments
addParameter(p, 'envlight'     , default_envlight    , check_envlight     );
addParameter(p, 'envlighttime' , default_envlighttime, check_envlighttime );
addParameter(p, 'envcolor'     , default_envcolor    , check_envcolor );
addParameter(p, 'horizonRGB'   , default_horizonRGB  , check_horizonRGB   );
addParameter(p, 'horizontime'  , default_horizontime , check_horizontime  );
addParameter(p, 'zenithRGB'    , default_zenithRGB   , check_zenithRGB    );
addParameter(p, 'zenithtime'   , default_zenithtime  , check_zenithtime   );
% Parse
parse(p,varargin{:});
% Convert to variables
envlight     = p.Results.('envlight');
envcolor     = p.Results.('envcolor');
envlighttime = p.Results.('envlighttime');
horizonRGB   = p.Results.('horizonRGB');
horizontime  = p.Results.('horizontime');
zenithRGB    = p.Results.('zenithRGB');
zenithtime   = p.Results.('zenithtime');
end

function makethisfunction
%% 
args = {'envlight','envlighttime','envcolor','horizonRGB','horizontime','zenithRGB','zenithtime'};
flag = [3 3 3 3 3 3 3];
defaultvals = {[],[],[],[],[],[],[]};

inputParserTemplate(args,flag,defaultvals)
end