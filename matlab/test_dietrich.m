%% test dietrich
DNAME = ['P:\Slocum\USVI_project\01_DATA\20180319_USVI_UAS_BATHY\02_PROCDATA\06_PROCIMAGES\' ... 
    '0325_BUCK_SOLO_1525_402ft\' ...
    '06_QUICKPROC\quickproc\'];

[~,DNAMES] = dirname('*',0,'P:\Slocum\USVI_project\01_DATA\20180319_USVI_UAS_BATHY\02_PROCDATA\06_PROCIMAGES\');
FULLNAMES = cellfun(@(x) [x '\06_QUICKPROC\quickproc4\'],DNAMES,'UniformOutput',false);

for i=1:numel(FULLNAMES)
    DNAME = FULLNAMES{i};
    lasname = [DNAME 'dense.las'];
    waterlevel = -41;
    trajname = [DNAME 'trajectory.txt'];
    sensorname = [DNAME 'sensorcalib.xml'];
    
    if exist(trajname,'file')
        try
        [~,JUSTNAME]=fileparts(fileparts(fileparts(fileparts(FULLNAMES{i}))));
        
        dietrich_depth(lasname,waterlevel,trajname,sensorname);
        f = figure(100);
%         set(f,'units','normalized','position',[0.05 0.05 0.85 0.85]);
        bigtitle(fixfigstring(JUSTNAME),0.5,0.95,'interpreter','latex','fontsize',26);
        saveas(f,['A' JUSTNAME '.png']);
        f2 = figure(101);
%         set(f2,'units','normalized','position',[0.05 0.05 0.85 0.85]);
        bigtitle(fixfigstring(JUSTNAME),0.5,0.95,'interpreter','latex','fontsize',26);
        saveas(f2,['B' JUSTNAME '.png']);
        catch
           fprintf('ERROR:%s\n',DNAME); 
        end
    end
end