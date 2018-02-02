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
%
function f32_to_ply(fname_f32, fname_ply, radius_skip, downsize)

printf('loading f32 (it may take a few minutes)...\n');
fflush(stdout);
PC = read_pts_binary_float32(fname_f32);

if exist('downsize','var')
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
    printf('eliminating redundant points...');
    fflush(stdout);

    PC_new = PC(1,:);
    for i = 2:num
        num_new = size(PC_new,1);
        f_insert = true;
        for j = 1:num_new
            if( abs(PC_new(j,1)-PC(i,1)) < radius_skip
              & abs(PC_new(j,2)-PC(i,2)) < radius_skip
              & abs(PC_new(j,3)-PC(i,3)) < radius_skip
              & norm(PC_new(j,:)-PC(i,:))<radius_skip)
                f_insert = false;
            end
        end
        if(f_insert)
            PC_new = [PC_new; PC(i,:)];
        end

        if (mod(i,100) == 0)
            printf('%d out of %d processed, %d points resampled\n',i,num,num_new);
            fflush(stdout);
        end
    end

    PC = PC_new;
    num = size(PC,1);
end

printf('# of points: %d\n',num);

fp = fopen(fname_ply,'w');

if(fp == -1)
    printf('file open error: %s\n',fname_ply);
else
    printf('writing a file...\n');
    fflush(stdout);
    fprintf(fp,'ply\n');
    fprintf(fp,'format ascii 1.0\n');
    fprintf(fp,'element vertex %d\n',num);
    fprintf(fp,'property float x\n');
    fprintf(fp,'property float y\n');
    fprintf(fp,'property float z\n');
    fprintf(fp,'end_header\n');
    for i = 1:num
        fprintf(fp,'%f %f %f\n',PC(i,:));
        
        if(mod(i,100) == 0)
            printf('%d out of %d points written\n',i,num);
            fflush(stdout);
        end
    end
    fclose(fp);
end

