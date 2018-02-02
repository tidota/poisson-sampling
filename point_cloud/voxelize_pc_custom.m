% [uids, varargout, trimmed_pts, idx] = voxelize_pc_custom(pts, usr_fn, dims, ...
%    xlims, ylims, zlims, ...
%    xstep, ystep, zstep)
%
% This function voxelizes a point cloud and applies a custom function to
% all of the points in that voxel, the outputs are the filled voxels given by the
% unique id array, followed by sparse array accumulator grids for each specified 
% dimensions of the point cloud: 
%
% ex. [~, gridx, gridy, gridz, ~] = voxelize_pc_custom(pts, @(x) mean(x), [1 2 3] ...) 
% outputs voxels with the centroid values of the points in that voxel. The
% type of gridx, gridy, gridRed, etc is an ndSparse (Xbins x Ybins x Zbins) object. 
%
% Download the ndSparse class from Mark Jacobson at: 
% http://www.mathworks.com/matlabcentral/fileexchange/29832-n-dimensional-sparse-arrays
%
% Inputs:
% pts is an [Nx3+] point cloud, the first 3 columns must be the cartesian
% coordinates of the points, but you can append optional color or other
% values for column 4 onward
%
% usr_fn is a function handle of type [double array] -> double, it controls 
% what happens to all the points that map to the same voxel. It is applied once for
% each attribute (x,y,z,r,g,b,etc) of the data specified. For example @mean
% will calculate the mean from a 1-dimensional array containing all x coordinates
% in a voxel, then all y coordinates, and so on. Simple matlab functions of
% interest include: @mean, @median, @std, @range, @min.
%
% dims is an index array into size(pts,2) specifying which dimensions to 
% output, e.g. [1 2 3] for x,y,z
%
% xlims, ylims and zlims = [min, max] tuples of ranges in same units as the
% point cloud, zlims can be infinite if zstep is infinite (single bin)
%
% xstep, ystep, zstep are scalars for voxel dimension in the same units 
% as the point cloud
%
% Outputs:
% uids: a unique id for each occupied voxel (a matlab subscript index for a
%   3D matrix). 1 < uids < numel(voxels)
% 
% gridx, gridr, etc: ndsparse type 3d sparse matrices representing the
%   voxelized centroid value for each attribute. So, if the total voxel grid
%   is 100x100x100 dimension, the output will be a 100x100x100 sparse array
%   where gridx will be the x values at each voxel. 
%
% trimmed_pts: points used after trimming ( others were filtered out because 
%   they were beyond the voxel limits). size(trimmed_pts,1) < N. 
%
% idx: a mapping from each original point to the voxel ID that it belongs
%   to. length(idx) = size(trimmed_pts,1)
%
% @author uyw (Uland Wong)
function [uids, varargout] = voxelize_pc_custom(pts, usr_fn, dims, ...
    xlims, ylims, zlims, ...
    xstep, ystep, zstep)

%chop off points outside the limit
pts_f = filter_point_cloud(pts, xlims, ylims, zlims);
clear pts;

%find number of bins and quantize points into bins
%use of epsilon prevents points on an edge from creating another bin
if ~isinf(xstep) && ~isinf(xlims(1)) && ~isinf(xlims(2))
    xbins = ceil(range(xlims) / xstep);
    cx = (pts_f(:,1) - xlims(1)) / range(xlims) * (xbins-eps(xbins)) +0.5;
else
    xbins = 1;
    cx = ones([size(pts_f,1) 1], 'single');
end
if ~isinf(ystep)&& ~isinf(ylims(1)) && ~isinf(ylims(2))
    ybins = ceil(range(ylims) / ystep);
    cy = (pts_f(:,2) - ylims(1)) / range(ylims) * (ybins-eps(ybins)) +0.5;
else
    ybins = 1;
    cy = ones([size(pts_f,1) 1], 'single');
end
if ~isinf(zstep) && ~isinf(zlims(1)) && ~isinf(zlims(2))
    zbins = ceil(range(zlims) / zstep);
    cz = (pts_f(:,3) - zlims(1)) / range(zlims) * (zbins-eps(zbins)) +0.5;
else
    zbins = 1;
    cz = ones([size(pts_f,1) 1], 'single');
end

cx = round(cx);
cy = round(cy);
cz = round(cz);

%find the location in the occupancy grid as a unique index
idx = sub2ind([xbins ybins zbins], cx, cy, cz);
uids = unique(idx);
clear cy cy cz;

%loop through all the attribute dimensions of the points
for i = 1:length(dims)
    %run the custom function on member points of each of the voxels, output to
    %a sparse rectangular array 
    occ = accumarray(int32(idx), double(pts_f(:,dims(i))), ...
        double([xbins*ybins*zbins 1]), usr_fn, 0, true);
    
    if ~isempty(occ)
        %convert from regular matlab sparse to ndsparse class because
        %matlab can only handle 2d sparse (aka no 3d voxels)
        varargout{i} = ndSparse(occ, [xbins ybins zbins]);
    else
        %there was an error, like no points were contained in the voxels
        %specified
        varargout{i} = NaN; 
    end
end

%return the voxel mapping for each point
varargout{end+1} = pts_f;
varargout{end+1} = idx;
