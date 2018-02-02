% out_pc = downsample_point_cloud(pc, num_points)
%
% Downsamples a point cloud using fastest possible method with no regard
% for oversampling dense areas. 
%
% Inputs:
% pc is [N x M] point cloud matrix, where N is the number of points, and M is the number
%   of attributes per point
% num_points is number of points in the downsampled point cloud. 1 <
%   num_points < N
% 
% Outputs:
% out_pc is [num_points x M] point cloud output  
%
% @author uyw (Uland Wong)
function out_pc = downsample_point_cloud(pc, num_points)
%% old code
% idx = uint32(randperm(length(pc)));
%
% for i = 1:size(pc,2)
%     pc(:,i) = single(pc(idx, i));
% end
% 
% points = pc(1:min(num_points, length(pc)), :);

%% new code 03/03/2013
idx = randsample(size(pc,1), num_points, false);
out_pc = pc(idx, :);
