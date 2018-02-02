% [out_pc, v_idx, v_size, occ] = downsample_pc_voxel(pc, step, cust_fn)
% 
% Downsamples a point cloud using voxel method to avoid overweighting dense
% areas. Points in the voxel are represented by the centroid as defined by the 
% the @mean (default) function  
%
% Inputs:
% pc is an [NxM] input point cloud, where M 
%
% step is the voxel dimension, in the same units as the pc. Voxels are
%   cubes.
%
% (optional) cust_fn is a voxel centroid function handle to override the 
%   default @mean behavior, such as @max, or @median.
%
% Outputs:
% out_pc is an [N'xM] output point cloud of the voxel filter. 1 < N' < N. 
%
% v_idx is the voxel mapping array. It specifies the membership of each point as
%   belonging to a voxel. length(v_idx) = size(pc,1)
%
% v_size is the dimension of the voxel grid as [Xbins, Ybins, Zbins].
%   Number of bins are always integer values. 
%   Numel(voxels) = Xbins * Ybins * Zbins
%
% occ is an array of N' elements which are the indices of the occupied voxels,  
%   1 < range(occ) < numel(vox grid)
%
% @author uyw (Uland Wong)
function [out_pc, v_idx, v_size, occ] = downsample_pc_voxel(pc, step, cust_fn)
if size(pc,1) < size(pc,2)
    pc = pc';
end

if ~exist('cust_fn', 'var');
    cust_fn = @mean;
end

%establish the bounding box of the point cloud
xlims = [min(pc(:,1)) max(pc(:,1))];
ylims = [min(pc(:,2)) max(pc(:,2))];
zlims = [min(pc(:,3)) max(pc(:,3))];

%find the mean point in each voxel and the mean attributes (e.g color)
chan_array = 1:size(pc,2);  %include all attributes in voxel calculation

[~, chan_data{1:size(pc,2)}, ~, v_idx] = voxelize_pc_custom(pc, cust_fn, chan_array, ...
    xlims, ylims, zlims, ...
    step, step, step);

%convert sparse matrices to shortened full point array
%start with the cartesian coordinates, so we know what to filter
x = sparse(chan_data{1});
y = sparse(chan_data{2});
z = sparse(chan_data{3});

v_size = size(chan_data{1});

occ = find(x~=0 | y~=0 | z~=0);

out_pc = zeros([length(occ) size(pc,2)], 'single');

for i = 1:size(pc,2)
    out_pc(:,i) = single(full(chan_data{i}(occ)));
end
