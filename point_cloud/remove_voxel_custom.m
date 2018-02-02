% out_pc = remove_voxel_custom(pc, vox_dim, cust_fn)
% 
% This function first creates a voxel grid from a point cloud. Then, all points 
% associated with voxels that do not pass a custom filter function are 
% removed from the grid. Importantly, this function does not resample point
% cloud density. For example, if the custom function is @(x) false, it will
% return the original point cloud, regardless of voxel grid size. This
% mechanic is useful for removing "blobs" from a point cloud in an
% automated manner, where the size of the blobs are naively greater than the 
% voxel size. This function is very fast because it operates on cube voxels, but
% suffers in quality compared to cloud filtering methods like spherical
% neighborhood.
%
% usage: 
%   filter_test = remove_voxel_custom([]);
%   out_pc = remove_voxel_custom(d, 0.25, filter_test);
%
%   Creates a voxel grid that is 0.25 units cube, and removes points 
%   with high average brightness using the test filter function. 
% 
% Inputs:
% pc is an [NxM] point cloud matrix, N points by M attributes. First three
%   attributes must be (X,Y,Z) cartesian coordinates.
%
% vox_dim is a scalar in the range (0, inf) representing the dimension of a
%   voxel in the same units as the point cloud. Voxels are cubes.
%
% cust_fn is a function handle which takes a single point (of M attributes),
%   calculates some values and outputs true if the point is to be removed
%   or false if the point remains in the cloud. See the sub function
%   @filter_test below.
%
%   Note: filter_test = remove_voxel_custom([]) will grab the function
%   handle of filter test for debug purposes.
%
% Outputs: 
% out_pc is the [N'xM] output point cloud 
%
% @author uyw (Uland Wong)
function out_pc = remove_voxel_custom(pc, vox_dim, cust_fn)
% hack to get the function handle for the filter_test sub function
if isempty(pc) 
    out_pc = @filter_test;
    return;
end

%create a voxel grid on the point cloud
[vox_centroids, v_idx, v_size, occ] = downsample_pc_voxel(pc, vox_dim, @mean);

%dummy function to emulate arrayfun on 'rows' of the point cloud
%subs = ndgrid(1:size(vox_centroids, 1));
%subs = repmat(subs, [1 size(vox_centroids,2)]);
%fail = accumarray(subs(:), vox_centroids(:), [size(vox_centroids,1) 1], cust_fn); %return the indices of voxels that are to be removed
C = mat2cell(vox_centroids, ones(size(vox_centroids,1),1), 7);
fail = cellfun(cust_fn, C);

% find the voxels to "keep"
%indices for occupied voxels that pass the test are kept
occ = occ(find(~fail)); 

%generate an logical map for 1:numel(voxels)
map = false(prod(v_size),1);
map(occ) = true; %voxels to keep are marked as true in the logical map

%use the voxel assignment map to determine whether each individual point 
%is kept or removed  
w = map(v_idx);

%filter the point cloud
out_pc = pc(logical(w), :);

end

% Test function for debuging custom filter function
% This function removes very bright and unnaturally colored voxels. Useful
% for removing artificial objects from natural terrain scans. 
%
% if return = true, then this voxel will be cut
function val = filter_test(attrib)
    %fprintf(1, '%g\n', length(attrib))

    %did accumarray pass the correct number of attributes?
    if length(attrib) == 7  
        thr1 = 3;
        thr2 = 140;
        
        %reference the color attributes for the voxel
        r = attrib(5);
        g = attrib(6);
        b = attrib(7);
        
        %transform to LAB space
        L = max([r g b]);
        
        %filter: is this voxel's color unnaturally bright or yellow/red?
        val = ((g+b)/(2*r) > thr1  | 2*b/(r+g) > thr1) | L > thr2;
      
    else
        val = false;
    end
end
