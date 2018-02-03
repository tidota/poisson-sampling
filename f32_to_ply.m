% f32_to_ply
%
% This function loads point cloud data from a f32 file
% and saves it as a ply file.
%
% It works by use of functions provided by CMU.
% The file must be placed under the directory "CAVES_code"
%
% Parameters:
% - fname_f32:
%     the file name of the f32 file
% - fname_ply:
%     the file name of the ply file
% - radius_skip(optional):
%     if given, eliminates points within this radius of another
% - downsize(optional):
%     if given, the size of data is downsized to this number
% - f_simple(optional):
%     if it is true, a point is stored only if the corresponding cell is empty
%
function f32_to_ply(fname_f32, fname_ply, radius_skip, downsize, f_simple)

printf('loading f32 (it may take a few minutes)...\n');
fflush(stdout);
PC = read_pts_binary_float32(fname_f32);

if exist('downsize','var') && downsize != 0
    pkg load statistics % for octave
    % to use the downsample_point_cloud function on octave,
    % the statistics package is required.
    
    printf('downsizing...\n');
    fflush(stdout);
    cd 'point_cloud'
    PC = downsample_point_cloud(PC,downsize);
    cd ..
end

num = size(PC,1);

if exist('radius_skip','var') & radius_skip > 0
  % Points are temporarily stored in grid cells at an interval of radius_skip
  % A new point is discarded if it is located near the existing ones
  % This results in elimination of redundant points
  
  printf('eliminating redundant points...\n');
  fflush(stdout);
  
  x_min = min(PC(:,1));
  y_min = min(PC(:,2));
  z_min = min(PC(:,3));
  x_max = max(PC(:,1));
  y_max = max(PC(:,2));
  z_max = max(PC(:,3));
  
  i_m = 1 + floor((PC(1,1)-x_min)/radius_skip);
  j_m = 1 + floor((PC(1,2)-y_min)/radius_skip);
  k_m = 1 + floor((PC(1,3)-z_min)/radius_skip);
  
  i_max = 1 + floor((x_max-x_min)/radius_skip);
  j_max = 1 + floor((y_max-y_min)/radius_skip);
  k_max = 1 + floor((z_max-z_min)/radius_skip);  
  table = struct('list', cell(i_max,j_max,k_max));
  num_new = 0;
  PC_new = [];
  
  if ~exist('f_simple','var')
    f_simple = false;
  else
    printf('simple mode enabled\n');
    fflush(stdout)
  end
  
  tic;

  for indx_org = 1:num
    i_m = 1 + floor((PC(indx_org,1)-x_min)/radius_skip);
    j_m = 1 + floor((PC(indx_org,2)-y_min)/radius_skip);
    k_m = 1 + floor((PC(indx_org,3)-z_min)/radius_skip);
    
    f_insert = true;
    
    if f_simple
      if size(table(i_m,j_m,k_m).list,1) > 0
        f_insert = false;
      end
    else
      for i = i_m-1:i_m+1
        for j = j_m-1:j_m+1
          for k = k_m-1:k_m+1
            if 1 <= i && i <= i_max...
            && 1 <= j && j <= j_max...
            && 1 <= k && k <= k_max
              for indx_new = 1:size(table(i,j,k).list,1)
                if(norm(table(i,j,k).list(indx_new,:)-PC(indx_org,:))<radius_skip)
                  f_insert = false;
                end
              end
            end
          end
        end
      end
    end
    
    if(f_insert)
      table(i_m,j_m,k_m).list = [table(i_m,j_m,k_m).list; PC(indx_org,:)];
      PC_new = [PC_new; PC(indx_org,:)];
      num_new = num_new + 1;
    end

    if (mod(indx_org,1000) == 0)
        t = toc;
        printf('%3d:%02d:%02d | ',floor(t/3600),mod(floor(t/60),60),mod(floor(t),60));
        printf('%d out of %d processed (%2d %%), %d points resampled\n',indx_org,num,floor(indx_org*100/num),num_new);
        fflush(stdout);
    end
  end
  
  PC = PC_new;
  num = num_new;
else
  table = [];
end

printf('# of points: %d\n',num);

fp = fopen(fname_ply,'w');

if(fp == -1)
  printf('file open error: %s\n',fname_ply);
else
  printf('writing a file...\n');
  fflush(stdout);
  tic;
  fprintf(fp,'ply\n');
  fprintf(fp,'format ascii 1.0\n');
  fprintf(fp,'element vertex %d\n',num);
  fprintf(fp,'property float x\n');
  fprintf(fp,'property float y\n');
  fprintf(fp,'property float z\n');
  fprintf(fp,'end_header\n');
  for i = 1:num
    fprintf(fp,'%f %f %f\n',PC(i,:));
    
    if(mod(i,10000) == 0)
      t = toc;
      printf('%3d:%02d:%02d | ',floor(t/3600),mod(floor(t/60),60),mod(floor(t),60));
      printf('%d out of %d points written\n',i,num);
      fflush(stdout);
    end
  end
  fclose(fp);
end

