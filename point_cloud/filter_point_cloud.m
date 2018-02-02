% [pts, ids] = filter_point_cloud(pts, x_range, y_range, z_range)
%
% Leave out points outside the given x,y,z limits. Ranges are specified as
%   [min, max].
% 
% Assumes that x,y,z correspond to first 3 columns of pts, but otherwise
% more than 3 columns of pts can be specified. All columns will be trimmed.
%
% @author uyw
function [pts, ids] = filter_point_cloud(pts, x_range, y_range, z_range)

idx = pts(:,1) >= x_range(1) & pts(:,1) <= x_range(2); 
idy = pts(:,2) >= y_range(1) & pts(:,2) <= y_range(2);
idz = pts(:,3) >= z_range(1) & pts(:,3) <= z_range(2);

ids = idx & idy & idz; 
pts = pts(ids, :);