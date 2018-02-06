# What is this?

This includes my code to perform the Poisson sampling of point clouds, eliminating dense points which are close to each other in a specified radius.
The resulted data is down-sampled, keeping the details in sparse areas.
![](./img/sampled_point_cloud.png)

# Purpose
This is primarily intended to be used for building a 3D mesh model from the raw data of a lava tube provided by CMU.
http://www.frc.ri.cmu.edu/projects/NIAC_Caves/

# Usage
I tested it only on Octave, but it should run on MatLab. For Octave, the packages 'io' and 'statistics' should be installed.
The function to be called is defined in this file.
- f32_to_ply.m

Here is an example of usage. The first parameter is the path to the input file (.f32 file), the second is the one to the output file (.ply file), and the last one is the radius (in meter).
```
f32_to_ply('../IndianTunnel_cave/Full/IndianTunnel_full_10x.f32','IndianTunnel_full_10x_0.1_simple.ply',0.1)
```

This code uses the MatLab code provided by CMU in order to read f32 files.
http://www.frc.ri.cmu.edu/projects/NIAC_Caves/#_Code

The algorithm is (ridiculously) simple compared to the equivalent feature which can be found in the existing point cloud libraries. It repeatedly samples a point from the original data and searches the corresponding cell in a 3D table. If it does not finds neighbors or they are not located in the specified radius from the sample point, it registers the sampled point to both the list and table. Otherwise, the sampled point is discarded. Apparently, the more sophisticated ways employs octree instead of the table.

# To build a meshed model
Here is a python script running on Blender.
https://sourceforge.net/projects/pointcloudskin/

The result looks like this.
![](./img/meshed1.png)
![](./img/meshed2.png)
