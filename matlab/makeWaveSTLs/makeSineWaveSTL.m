function makeSineWaveSTL(fname, amp, wavelength, xyscale, resolution)
%%
fname = 'sinwave.stl';
amp = 1;
wavelength = 1;
xyscale = 500;
resolution = 0.05;

%%
xi = -xyscale:resolution:xyscale;
yi = linspace(-xyscale,xyscale,3);

[xg,yg]=meshgrid(xi,yi);

zg = amp.* sin(xg*2*pi/wavelength);

%% Save The Wave
stlwrite(fname, xg, yg, zg);

end