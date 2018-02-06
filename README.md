# What is this?

This includes my code to perform the Poisson sampling of point clouds, eliminating dense points which are close to each other in a specified radius.
The resulted data is down-sampled, keeping the details in sparse areas, and intended to be used for skinning/meshing.

My contribution is development of the following code:
- f32_to_ply.m

This is based on the MatLab code provided by CMU.
[http://www.frc.ri.cmu.edu/projects/NIAC_Caves/#_Code](http://www.frc.ri.cmu.edu/projects/NIAC_Caves/#_Code)
