% write_pts_binary_float32(filename, pts, colors)
% 
% This function writes binary-packed point clouds with color data. 
% 
% input:
% filename - path string to a binary point cloud for writing
% pts - [nx3] matrix of [x,y,z] cartesian points in meter units
% colors - [nx3] matrix of RGB color data in the range [0,1]
%
% output:
% nothing 
%
% @author uyw (Uland Wong)
function write_pts_binary_float32(filename, pts, colors)
fid = fopen(filename, 'wb');

if(fid == -1)
    error('Error opening file.');
end

if size(colors,2) == 3
    pts(:,5:7) = colors*255;
elseif size(colors,2) == 4%hidden feature to store reflectance values in 4-color channel
    pts(:,4) = colors(:,1);
    pts(:,5:7) = colors(:,2:4)*255; 
else
    error('Number of color attributes not supported');
end

fwrite(fid, pts', 'float32', 'ieee-le');

fclose(fid);
