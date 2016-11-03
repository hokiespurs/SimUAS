function Cal = readsensor(outsensor, insensor)
    indata = xml2struct(insensor);
    outdata = xml2struct(outsensor);
    oc = outdata.calibration;
    isp = indata.sensor.postprocessing;
    
    Cal.width = str2double(oc.width.Text);
    Cal.height = str2double(oc.height.Text);
    Cal.fx = str2double(oc.f.Text);
    Cal.fy = str2double(oc.f.Text);
    Cal.cx = str2double(oc.cx.Text);
    Cal.cy = str2double(oc.cy.Text);
    Cal.k = [str2double(oc.k1.Text),...
                     str2double(oc.k2.Text),...
                     str2double(oc.k3.Text),...
                     str2double(oc.k4.Text)];
    Cal.p = [str2double(oc.p1.Text),...
                     str2double(oc.p2.Text)];
    
    Cal.postproc.vignetting = [str2double(isp.vignetting.Attributes.v1),...
                             str2double(isp.vignetting.Attributes.v2),...
                             str2double(isp.vignetting.Attributes.v3)];
    Cal.postproc.saltnoise = str2double(isp.saltnoise.Attributes.prob);
    Cal.postproc.peppernoise = str2double(isp.peppernoise.Attributes.prob);
    Cal.postproc.gaussnoise.mean = ...
        str2double(isp.gaussiannoise.Attributes.mean);
    Cal.postproc.gaussnoise.var = ...
        str2double(isp.gaussiannoise.Attributes.variance);
    Cal.postproc.gaussblur = str2double(isp.gaussianblur.Attributes.sigma); 
    Cal.seed = str2double(isp.Attributes.seed);
end
