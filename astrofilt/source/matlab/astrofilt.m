function [ lam, trans ] = astrofilt( fname )
%ASTROFILT load a filter curve from the astrofilt collection
% 

datadir = getenv('ASTROFILT_DATADIR');

fpath = strcat(datadir, '/');

fpath = strcat(fpath, fname);

fpath = strcat(fpath, '.dat');

data = importdata(fpath);

curve = data.data(:,1:2);

lam = curve(:,1);
trans = curve(:,2);

end

