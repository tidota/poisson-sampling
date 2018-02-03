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
    printf('eliminating redundant points...\n');
    fflush(stdout);
    
    tic;

    PC_new = PC(1,:);
    for i = 2:num
        num_new = size(PC_new,1);
        
        x_low = PC(i,1) - radius_skip;
        x_ins = PC(i,1);
        x_hgh = PC(i,1) + radius_skip;
        
        j_low = findIndx2Insrt(PC_new(:,1)',x_low,1,num_new+1);
        j_ins = findIndx2Insrt(PC_new(:,1)',x_ins,1,num_new+1);
        j_hgh = findIndx2Insrt(PC_new(:,1)',x_hgh,1,num_new+1) - 1;
        
        f_insert = true;
        for j = j_low:j_hgh
            if(norm(PC_new(j,:)-PC(i,:))<radius_skip)
                f_insert = false;
            end
        end
        if(f_insert)
            if(j_ins == 1)
                PC_new = [PC(i,:); PC_new];
            elseif(j_ins > size(PC_new,1))
                PC_new = [PC_new; PC(i,:)];
            else
                PC_new = [PC_new(1:j_ins-1,:); PC(i,:); PC_new(j_ins:num_new,:)];
            end
        end

        if (mod(i,1000) == 0)
            t = toc;
            printf('%3d:%02d:%02d | ',floor(t/3600),mod(floor(t/60),60),mod(floor(t),60));
            printf('%d out of %d processed (%2d %%), %d points resampled\n',i,num,floor(i*100/num),num_new);
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

