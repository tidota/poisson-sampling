% f32_to_ply
%
% This function loads point cloud data from a f32 file
% and saves it as a ply file.
%
% It works by use of functions provided by CMU.
% The file must be placed under the directory "CAVES_code"
%
% Parameters:
% - fname_f32: the file name of the f32 file
% - fname_ply: the file name of the ply file
% - downsize(optional): if given, the size of data is downsized to this number
%
function f32_to_ply(fname_f32, fname_ply, downsize)

pkg load statistics

printf('loading f32...\n');
fflush(stdout);
PC = read_pts_binary_float32(fname_f32);

if exist('downsize','var')
    cd 'point_cloud'
    printf('downsizing...\n');
    fflush(stdout);
    PC = downsample_point_cloud(PC,downsize);
    cd ..
end

num = size(PC,1);
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

