% [pts, colors] = read_pts_binary_float32(filename, num_attribs)
% 
% This function reads binary-packed point clouds with color data. 
% NOTE: there is no leading integer that gives the total number of lines/points
% in this format. 
% 
% Inputs:
% filename - path string to a binary point cloud
% num_attribs (optional) - number of attribs per point (xyz, rgb, i, etc)
%   default is 7 for XYZ+IRGB channels
%
% Outputs:
% pts - [nx3] matrix of [x,y,z] cartesian points in meter units
% colors - [nx3] matrix of RGB color data in the range [0,1]
% 
% @author uyw (Uland Wong)
function [pts, colors] = read_pts_binary_float32(filename, num_attribs)
if ~exist('num_attribs', 'var')
    num_attribs = 7;
end

fid = fopen(filename);

if(fid == -1)
    error('Error opening file.');
end

a = fread(fid, [num_attribs inf], 'float32=>single', 'ieee-le');
a = a';

pts = a(:,1:3);
colors = a(:, end-2:end)/255;

fclose(fid);
