function str = addSceneObject(objname,name,varargin)
% ADDSCENEOBJECT Method to add object to a scene xml file
%   Detailed explanation goes here
%
% Required Inputs: (default)
%	- objname              : *description* 
%	- name                 : *description* 
% Optional Inputs: (default)
%	- 'isControl'          : (0) *description* 
%	- 'isFiducial'         : (0) *description* 
%	- 'tt'                 : (0) *description* 
%	- 'tx'                 : (0) *description* 
%	- 'ty'                 : (0) *description* 
%	- 'tz'                 : (0) *description* 
%	- 'tr'                 : (0) *description* 
%	- 'rx'                 : (0) *description* 
%	- 'ry'                 : (0) *description* 
%	- 'rz'                 : (0) *description* 
%	- 'ts'                 : (0) *description* 
%	- 'sx'                 : (1) *description* 
%	- 'sy'                 : (1) *description* 
%	- 'sz'                 : (1) *description* 
%	- 'diffuseColor'       : ([]) *description* 
%	- 'diffuseIntensity'   : ([]) *description* 
%	- 'specularColor'      : ([]) *description* 
%	- 'specularIntensity'  : ([]) *description* 
%	- 'ambientIntensity'   : ([]) *description* 
%	- 'Shadeless'          : ([]) *description* 
%	- 'receiveshadow'      : ([]) *description* 
%	- 'castshadow'         : ([]) *description* 
%	- 'alphatransparency'  : ([]) *description* 
%	- 'alphaior'           : ([]) *description* 
%	- 'texture'            : ([]) *description* 
%	- 'textureinterpolate' : ([]) *description* 
%	- 'textureRepX'        : ([]) *description* 
%	- 'textureRepY'        : ([]) *description* 
%	- 'textureInfColor'    : ([]) *description* 

% Outputs:
%   - str : string to be printed into the scene xml file
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
[objname,name,isControl,isFiducial,tt,tx,ty,tz,tr,rx,ry,rz,ts,sx,sy,sz,...
    diffuseColor,diffuseIntensity,specularColor,specularIntensity,...
    ambientIntensity,Shadeless,receiveshadow,castshadow,...
    alphatransparency,alphaior,texture,textureinterpolate,textureRepX,...
    textureRepY,textureInfColor] = parseInputs(objname,name,varargin{:});

%% Print OBJ XML
str = [];
str = [str sprintf('<object objname="%s" name = "%s" isControl = "%i" isFiducial = "%i">\n',...
    objname,name,isControl,isFiducial)];

%% Print Object XML <position>
str = [str '\t<position>\n'];

% translation
for i=1:numel(tx)
    str = [str sprintf('\t\t<translation x="%g" y="%g" z="%g" t="%g"/>\n',...
        tx(i),ty(i),tz(i),tt(i))];
end

% rotation
for i=1:numel(rx)
    str = [str sprintf('\t\t<rotation x="%g" y="%g" z="%g" t="%g"/>\n',...
        rx(i),ry(i),rz(i),tr(i))];
end

% scale
for i=1:numel(sx)
    str = [str sprintf('\t\t<scale x="%g" y="%g" z="%g" t="%g"/>\n',...
        sx(i),sy(i),sz(i),ts(i))];
end

str = [str '\t</position>\n'];

%% Print Object XML <material>
if ~(isempty(diffuseColor) && isempty(specularColor) && isempty(ambientIntensity) && ...
        isempty(Shadeless) && isempty(alphatransparency))
    str = [str '\t<material>\n'];
    
    if ~isempty(diffuseColor)
        str = [str sprintf('\t\t<diffuse red="%g" green="%g" blue="%g" intensity="%g"/>\n',...
            diffuseColor,diffuseIntensity)];
    end
    
    if ~isempty(specularColor)
        str = [str sprintf('\t\t<specular red="%g" green="%g" blue="%g" intensity="%g"/>\n',...
            specularColor,specularIntensity)];
    end
    
    if ~isempty(ambientIntensity)
        str = [str sprintf('\t\t<ambient intensity="%g"/>\n',ambientIntensity)];
    end
    
    if ~isempty(Shadeless)
        str = [str sprintf('\t\t<shading shadeless="%g" receiveshadow="%g" castshadow="%g"/>\n',...
            Shadeless,receiveshadow,castshadow)];
    end
    
    if ~isempty(alphatransparency)
        str = [str sprintf('\t\t<transparency alpha="%g" ior="%g"/>\n',...
            alphatransparency,alphaior)];
    end
    
    str = [str '\t</material>\n'];
end
%% Print Object XML <texture>
if ~isempty(texture)
    str = [str '\t<texture>\n'];
    
    for i=1:numel(texture)
        str = [str sprintf('\t\t<slot interpolate="%g" filename="%s" repeatx="%g" repeaty="%g" infcolor="%g"/>\n',...
            textureinterpolate(i),texture{i},textureRepX(i),textureRepY(i),textureInfColor(i))];
    end
        
    str = [str '\t</texture>\n'];
end

%% End Object
str = [str '</object>\n'];

end

function [objname,name,isControl,isFiducial,tt,tx,ty,tz,tr,rx,ry,rz,ts,sx,sy,sz,diffuseColor,diffuseIntensity,specularColor,specularIntensity,ambientIntensity,Shadeless,receiveshadow,castshadow,alphatransparency,alphaior,texture,textureinterpolate,textureRepX,textureRepY,textureInfColor] = parseInputs(objname,name,varargin)
%%	 Call this function to parse the inputs

% Default Values
default_isControl           = 0;
default_isFiducial          = 0;
default_tt                  = 0;
default_tx                  = 0;
default_ty                  = 0;
default_tz                  = 0;
default_tr                  = 0;
default_rx                  = 0;
default_ry                  = 0;
default_rz                  = 0;
default_ts                  = 0;
default_sx                  = 1;
default_sy                  = 1;
default_sz                  = 1;
default_diffuseColor        = [];
default_diffuseIntensity    = [];
default_specularColor       = [];
default_specularIntensity   = [];
default_ambientIntensity    = [];
default_Shadeless           = [];
default_receiveshadow       = [];
default_castshadow          = [];
default_alphatransparency   = [];
default_alphaior            = [];
default_texture             = [];
default_textureinterpolate  = [];
default_textureRepX         = [];
default_textureRepY         = [];
default_textureInfColor     = [];

% Check Values
check_objname             = @(x) true;
check_name                = @(x) true;
check_isControl           = @(x) true;
check_isFiducial          = @(x) true;
check_tt                  = @(x) true;
check_tx                  = @(x) true;
check_ty                  = @(x) true;
check_tz                  = @(x) true;
check_tr                  = @(x) true;
check_rx                  = @(x) true;
check_ry                  = @(x) true;
check_rz                  = @(x) true;
check_ts                  = @(x) true;
check_sx                  = @(x) true;
check_sy                  = @(x) true;
check_sz                  = @(x) true;
check_diffuseColor        = @(x) true;
check_diffuseIntensity    = @(x) true;
check_specularColor       = @(x) true;
check_specularIntensity   = @(x) true;
check_ambientIntensity    = @(x) true;
check_Shadeless           = @(x) true;
check_receiveshadow       = @(x) true;
check_castshadow          = @(x) true;
check_alphatransparency   = @(x) true;
check_alphaior            = @(x) true;
check_texture             = @(x) true;
check_textureinterpolate  = @(x) true;
check_textureRepX         = @(x) true;
check_textureRepY         = @(x) true;
check_textureInfColor     = @(x) true;

% Parser Values
p = inputParser;
% Required Arguments:
addRequired(p, 'objname' , check_objname );
addRequired(p, 'name'    , check_name    );
% Parameter Arguments
addParameter(p, 'isControl'          , default_isControl         , check_isControl          );
addParameter(p, 'isFiducial'         , default_isFiducial        , check_isFiducial         );
addParameter(p, 'tt'                 , default_tt                , check_tt                 );
addParameter(p, 'tx'                 , default_tx                , check_tx                 );
addParameter(p, 'ty'                 , default_ty                , check_ty                 );
addParameter(p, 'tz'                 , default_tz                , check_tz                 );
addParameter(p, 'tr'                 , default_tr                , check_tr                 );
addParameter(p, 'rx'                 , default_rx                , check_rx                 );
addParameter(p, 'ry'                 , default_ry                , check_ry                 );
addParameter(p, 'rz'                 , default_rz                , check_rz                 );
addParameter(p, 'ts'                 , default_ts                , check_ts                 );
addParameter(p, 'sx'                 , default_sx                , check_sx                 );
addParameter(p, 'sy'                 , default_sy                , check_sy                 );
addParameter(p, 'sz'                 , default_sz                , check_sz                 );
addParameter(p, 'diffuseColor'       , default_diffuseColor      , check_diffuseColor       );
addParameter(p, 'diffuseIntensity'   , default_diffuseIntensity  , check_diffuseIntensity   );
addParameter(p, 'specularColor'      , default_specularColor     , check_specularColor      );
addParameter(p, 'specularIntensity'  , default_specularIntensity , check_specularIntensity  );
addParameter(p, 'ambientIntensity'   , default_ambientIntensity  , check_ambientIntensity   );
addParameter(p, 'Shadeless'          , default_Shadeless         , check_Shadeless          );
addParameter(p, 'receiveshadow'      , default_receiveshadow     , check_receiveshadow      );
addParameter(p, 'castshadow'         , default_castshadow        , check_castshadow         );
addParameter(p, 'alphatransparency'  , default_alphatransparency , check_alphatransparency  );
addParameter(p, 'alphaior'           , default_alphaior          , check_alphaior           );
addParameter(p, 'texture'            , default_texture           , check_texture            );
addParameter(p, 'textureinterpolate' , default_textureinterpolate, check_textureinterpolate );
addParameter(p, 'textureRepX'        , default_textureRepX       , check_textureRepX        );
addParameter(p, 'textureRepY'        , default_textureRepY       , check_textureRepY        );
addParameter(p, 'textureInfColor'    , default_textureInfColor   , check_textureInfColor    );
% Parse
parse(p,objname,name,varargin{:});
% Convert to variables
objname            = p.Results.('objname');
name               = p.Results.('name');
isControl          = p.Results.('isControl');
isFiducial         = p.Results.('isFiducial');
tt                 = p.Results.('tt');
tx                 = p.Results.('tx');
ty                 = p.Results.('ty');
tz                 = p.Results.('tz');
tr                 = p.Results.('tr');
rx                 = p.Results.('rx');
ry                 = p.Results.('ry');
rz                 = p.Results.('rz');
ts                 = p.Results.('ts');
sx                 = p.Results.('sx');
sy                 = p.Results.('sy');
sz                 = p.Results.('sz');
diffuseColor       = p.Results.('diffuseColor');
diffuseIntensity   = p.Results.('diffuseIntensity');
specularColor      = p.Results.('specularColor');
specularIntensity  = p.Results.('specularIntensity');
ambientIntensity   = p.Results.('ambientIntensity');
Shadeless          = p.Results.('Shadeless');
receiveshadow      = p.Results.('receiveshadow');
castshadow         = p.Results.('castshadow');
alphatransparency  = p.Results.('alphatransparency');
alphaior           = p.Results.('alphaior');
texture            = p.Results.('texture');
textureinterpolate = p.Results.('textureinterpolate');
textureRepX        = p.Results.('textureRepX');
textureRepY        = p.Results.('textureRepY');
textureInfColor    = p.Results.('textureInfColor');
end
 
function makethisfunction
%%
params = {
    'objname'            ,1 , [];
    'name'               ,1 , [];
    'isControl'          ,3 , 0; 
    'isFiducial'         ,3 , 0;
    'tt'                 ,3 , 0;
    'tx'                 ,3 , 0;
    'ty'                 ,3 , 0;
    'tz'                 ,3 , 0;
    'tr'                 ,3 , 0;
    'rx'                 ,3 , 0;
    'ry'                 ,3 , 0;
    'rz'                 ,3 , 0;
    'ts'                 ,3 , 0;
    'sx'                 ,3 , 1;
    'sy'                 ,3 , 1;
    'sz'                 ,3 , 1;
    'diffuseColor'       ,3 , [];
    'diffuseIntensity'   ,3 , [];
    'specularColor'      ,3 , [];
    'specularIntensity'  ,3 , [];
    'ambientIntensity'   ,3 , [];
    'Shadeless'          ,3 , [];
    'receiveshadow'      ,3 , [];
    'castshadow'         ,3 , [];
    'alphatransparency'  ,3 , [];
    'alphaior'           ,3 , [];
    'texture'            ,3 , [];
    'textureinterpolate' ,3 , [];
    'textureRepX'        ,3 , [];
    'textureRepY'        ,3 , [];
    'textureInfColor'    ,3 , [];
    };
    
    args = params(:,1);
    flag = cell2mat(params(:,2));
    defaultvals = params(flag==3,3);
    
    inputParserTemplate(args,flag,defaultvals);
end
