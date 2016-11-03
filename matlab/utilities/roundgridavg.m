function [ng,numpts,ng2]=roundgridavg(varargin)
% Grids data using a rounding algorithm and leave holes in the data as nans
% Performs 1D,2D, or 3D gridding.
%
% Inputs;
% - x: (1,N): vector of ungridded x data
% - y(optional): (1,M): vector of ungridded y data 
% - z(optional): (1,P): vector of ungridded z data
% - I(optional): (1,Q): vector of ungridded intensity data
% - xg: (N,M,P,Q): x values to grid to
% - yg(optional): (N,M,P,Q): y values to grid to
% - zg(optional): (N,M,P,Q): z values to grid to
% - 'gridmethod': 
%     - 'min': calculates the value as the minimum in each bin
%     - 'max': calculates the value as the maximum in each bin
%     - 'mean': calculates the value as the average in each bin (Def)
%     - 'sum': calculates the value as sum in each bin
%     - 'std': calculates mean first, then residuals for std (2x as long)
% - 'chunk': N : Number of elements to use in each chunk (Def = 100000)
% - 'loopmethod':
%     - 'sparse': calculates the value in each bin using a while loop (Def)
%     - 'dense': calculates the value in each bin using a for loop
%
% *dense is better for data with multiple values in each bin
% *sparse is better for data with few values in each bin
%
% Outputs:
% - ng: size(xg): the gridded values y,z, or I values depending on input
% - numpts: size(xg): the number of points in each bin
% 
% Examples
%
%  [yg,numpts]=roundgridavg(x,y,xg);
%
%  [zg,numpts]=roundgridavg(x,y,z,xg,yg);
%
%  [Ig,numpts]=roundgridavg(x,y,z,I,xg,yg,zg);
%
%  [yg,numpts]=roundgridavg(x,y,xg,'gridmethod','min');
%
%  [zg,numpts]=roundgridavg(x,y,z,xg,yg,'chunk',100000,'loopmethod','sparse');
%

%logic to calculate number of dimensions and optionalparams

if sum(nargin==[3,5,7,9,11,13])~=1
    error('wrong number of inputs');
end

p=inputParser;

defaultGridMethod='mean';
validGridMethod={'min','max','mean','sum','std'};
checkGridMethod= @(x) any(validatestring(x,validGridMethod));

defaultLoopMethod='sparse';
validLoopMethod={'sparse','dense'};
checkLoopMethod= @(x) any(validatestring(x,validLoopMethod));

addParameter(p,'gridmethod',defaultGridMethod,checkGridMethod)
addParameter(p,'chunk',100000,@isnumeric)
addParameter(p,'loopmethod',defaultLoopMethod,checkLoopMethod)


%% Calculate the number of dimensions
%find last index before optional inputs
ind=find(cellfun(@isstr,varargin),1,'first')-1;

%if no optional inputs
if isempty(ind)
    ind=nargin;
end

if ind==3
    numDimensions=1;
elseif ind==5
    numDimensions=2;
elseif ind==7
    numDimensions=3;
end
%% Fill in values if 1D or 2D case
% so if only xg is input, set yg and zg to ones the size of xg so
% roundgrid3d can be used
switch numDimensions
    case 1
        x=varargin{1}(:);
        y=ones(size(x));
        z=ones(size(x));
        xg=varargin{3}(:);
        yg=ones(size(xg));
        I=varargin{2}(:); %always map variable to I
        zg=ones(size(xg));
        optionalin=varargin;
        optionalin(1:3)=[];
    case 2
        x=varargin{1}(:);
        y=varargin{2}(:);
        z=ones(size(x));
        I=varargin{3}(:);
        xg=varargin{4};
        yg=varargin{5};
        zg=ones(size(xg));
        optionalin=varargin;
        optionalin(1:5)=[];
    case 3
        x=varargin{1}(:);
        y=varargin{2}(:);
        z=varargin{3}(:);
        I=varargin{4}(:);
        xg=varargin{5};
        yg=varargin{6};
        zg=varargin{7};
        optionalin=varargin;
        optionalin(1:7)=[];
end
%% Parse Inputs
parse(p,optionalin{:})
chunkval=p.Results.chunk;
gridmethod=p.Results.gridmethod;
loopmethod=p.Results.loopmethod;

if strcmp(gridmethod,'std')
    [ng2,~]=roundgridavg3D(x,y,z,I,xg,yg,zg,'mean',chunkval,loopmethod,[]);
    [ng,numpts]=roundgridavg3D(x,y,z,I,xg,yg,zg,'std',chunkval,loopmethod,ng2);
else
    [ng,numpts]=roundgridavg3D(x,y,z,I,xg,yg,zg,gridmethod,chunkval,loopmethod,[]);
    ng2=[];
end
ng(numpts==0)=nan;

end

function [ng,numpts]=roundgridavg3D(x,y,z,I,xg,yg,zg,gridmethod,chunkval,loopmethod,meanvals)
%filter data and check data
[x,y,z,I]=filterRawVariables(x,y,z,I);
checkRawVariables(x,y,z,I);
checkGridVariables(xg,yg,zg);
%% - chunk data if that is a user input
if numel(x)>chunkval
    numChunks=ceil(numel(x)/chunkval);
    if strcmp(gridmethod,'min')
        ng=ones(size(xg))*inf;
    elseif strcmp(gridmethod,'max')
        ng=ones(size(xg))*-inf;
    else
        ng=zeros(size(xg));
    end
    numpts=zeros(size(xg));
    for iChunkNum=1:numChunks
        indToProcess=iChunkNum:numChunks:numel(x);
        [ing,inumpts]=roundgrid(x(indToProcess),y(indToProcess),z(indToProcess),I(indToProcess),xg,yg,zg,gridmethod,loopmethod,meanvals);
        if strcmp(gridmethod,'min')
            ng(ing<ng)=ing(ing<ng);
            numpts=numpts+inumpts;
        elseif strcmp(gridmethod,'max')
            ng(ing>ng)=ing(ing>ng);
            numpts=numpts+inumpts;
        elseif strcmp(gridmethod,'mean')
            ng=(ng.*numpts+ing.*inumpts)./(numpts+inumpts);
            numpts=numpts+inumpts;
            ng(numpts==0)=0;
        elseif strcmp(gridmethod,'sum')
            ng=ng+ing;
            numpts=numpts+inumpts;
        elseif strcmp(gridmethod,'std') %sum of residuals
            ng=ng+ing;
            numpts=numpts+inumpts;
        end

    end
else
    [ng,numpts]=roundgrid(x,y,z,I,xg,yg,zg,gridmethod,loopmethod,meanvals);
end
if strcmp(gridmethod,'std')
    ng = sqrt(ng./(numpts-1));
end
end

function [ng,numpts]=roundgrid(x,y,z,I,xg,yg,zg,gridmethod,loopmethod,meanvals)
%% Calculate index values for each dimension
[xind,dxDim]=calcInd(x,xg);
[yind,dyDim]=calcInd(y,yg);
[zind,dzDim]=calcInd(z,zg);
%% Remove data outside of the grid
badind=isnan(xind) | isnan(yind) | isnan(zind);
xind(badind)=[];
yind(badind)=[];
zind(badind)=[];
I(badind)=[];
%% Convert xind,yind,zind to a 1d index
ind=calcSub2Ind(xg,xind,dxDim,yind,dyDim,zind,dzDim);

%% Sort Index and I by index number
sortedInd=sortrows([ind(:) I(:)],1);
ind=sortedInd(:,1);
I=sortedInd(:,2);
%% Calculate the difference in the index number
% Diff of 0 means its the same index
di=[1; diff(ind)];
%% Preallocate
if strcmp(gridmethod,'avg') || strcmp(gridmethod,'mean') || strcmp(gridmethod,'sum') || strcmp(gridmethod,'std')
    ng=zeros(size(xg));
elseif strcmp(gridmethod,'max')
    ng=ones(size(xg))*-inf;
elseif strcmp(gridmethod,'min')
    ng=ones(size(xg))*inf;
end
numpts=zeros(size(xg));

if strcmp(loopmethod,'dense')%do a for loop
    %% For loop is faster if theres really dense data
    for i=unique(ind)'
        Ivals=I(ind==i);
        if strcmp(gridmethod,'min')
            ng(i)=min(Ivals);
        elseif strcmp(gridmethod,'max')
            ng(i)=max(Ivals);
        elseif strcmp(gridmethod,'mean')
            ng(i)=mean(Ivals);
        elseif strcmp(gridmethod,'sum')
            ng(i)=sum(Ivals);
        elseif strcmp(gridmethod,'std') %sum of residuals squared
            ng(i)=sum((Ivals-meanvals(i)).^2);
        end        
        numpts(i)=numel(Ivals);
    end
else %do a while loop
    %% While loop is normall faster, especially for sparse data
    while(~isempty(I))
        indWhenIndJumps=di~=0; %if it's not 0, process it
        indValAtJumps=ind(indWhenIndJumps(:));%index number of those values
        indValAtJumps=indValAtJumps(:);
        numpts(indValAtJumps)=numpts(indValAtJumps)+1;%each index is going to have one more point included in the mean
        
        Ivals=I(indWhenIndJumps);
        ngVals=ng(indValAtJumps);
        numptVals=numpts(indValAtJumps);
        
        if strcmp(gridmethod,'min')
            ng(indValAtJumps)=min([Ivals ngVals],[],2);
        elseif strcmp(gridmethod,'max')
            ng(indValAtJumps)=max([Ivals ngVals],[],2);
        elseif strcmp(gridmethod,'mean')
            ng(indValAtJumps)=Ivals.*(1./numptVals)+ngVals.*((numptVals-1)./numptVals);%calculate running mean
        elseif strcmp(gridmethod,'sum')
            ng(indValAtJumps)=ngVals+Ivals;
        elseif strcmp(gridmethod,'std') %sum of residuals squared
            ng(indValAtJumps)=ngVals+(Ivals-meanvals(indValAtJumps)).^2;
        end
        
        I=I(~indWhenIndJumps);%get rid of points that were just processed
        ind=ind(~indWhenIndJumps);%get rid of their index too
        
        di=[1; diff(ind)];%calculate the difference again
    end
end
end

function ind=calcSub2Ind(xg,xind,numdx,yind,numdy,zind,numdz)

[m,n,p]=size(xg);
if numdx==1 %if first dimension has same number of elements as numdx
        ind1=xind;
    if numdy==2
        ind2=yind;
        ind3=zind;
    else
        ind2=zind;
        ind3=yind;
    end
elseif numdy==1 %if first dimension has same number of elements as numdy
    ind1=yind;
    if numdx==2
        ind2=xind;
        ind3=zind;
    else
        ind2=zind;
        ind3=xind;
    end
elseif numdz==1 %if first dimension has same number of elements as numdz
    ind1=zind;
    if numdx==2
        ind2=xind;
        ind3=yind;
    else
        ind2=yind;
        ind3=xind;
    end
end

ind=sub2ind([m,n,p],ind1,ind2,ind3);

end

function varargout = filterRawVariables(varargin)
%removes nans from the raw input data
ind=zeros(size(varargin{1}));

for i=1:numel(varargin)
    ind = ind | isnan(varargin{i});
end

for i=1:numel(varargin)
    varargout{i}=varargin{i}(~ind);
end
end

function checkRawVariables(varargin)
%checks to make sure input variables are the same size
n=numel(varargin{1});
for i=2:numel(varargin)
    ni=numel(varargin{i});
    if n~=ni
        error('input vectors must have the same number of elements');
    end
end
end

function checkGridVariables(varargin)
%check to make sure grids are the same size, and have a constant dx
for i=1:numel(varargin)
    dx=diff(varargin{i}(:,1,1),[],1);
    stddx=std(dx(:));
    dy=diff(varargin{i}(1,:,1),[],2);
    stddy=std(dy(:));
    dz=diff(varargin{i}(1,1,:),[],3);
    stddz=std(dz(:));
    basicallyZero=1e-8;
    if stddx>=basicallyZero || stddy>=basicallyZero || stddz>=basicallyZero
        error('Grid must be equadistant in each dimension');
    end
end
[m,n,p]=size(varargin{1});
for i=2:numel(varargin)
    [m2,n2,p2]=size(varargin{i});
    if m2~=m || n2~=n || p2~=p
        error('Input Grids must be the same size');
    end
end
end

function [Xind,dxDim] = calcInd(x,xg)
% Calculates the indicies of x in xg when rounding
minX=min(xg(:));
maxX=max(xg(:));

d1=mean(diff(xg(:,1,1),[],1));
d2=mean(diff(xg(1,:,1),[],2));
d3=mean(diff(xg(1,1,:),[],3));

[incr, dxDim]=max([d1 d2 d3]);

dimLength = size(xg,dxDim);

if incr==0
   dxDim=nan; 
end

if incr==0
    Xind=nan(size(x));
    Xind(x==xg(1))=1;
else
   
    Xind=round(x./incr-(minX/incr-1));
    
    badind = Xind <= 0 | Xind > dimLength;
    
    Xind(badind)=nan;
end

end
