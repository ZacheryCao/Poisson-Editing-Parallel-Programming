function [img_direct] = poisson_solver_function(gx,gy,boundary_image)
%
% PoissonEditing - Possion editing in RGB space using FFT and GPU
% 
% SYNTAX 
%          [IMG_DIRECT] = POISSON_SOLVER_FUNCTION(GX,GY,BOUNDARY_IMAGE)
% 
% INPUT 
%
%    GX AND GY                         GRADIENTS
%    BOUNDARY_IMAGE                    BOUNDARY IMAGE INTENSITIES
% 
% OUTPUT 
%
%    NEW IMAGE
%
% CALLEE
%    dst
%    idst
%


 [H,W] = size(boundary_image);
 gxx = zeros(H,W,'gpuArray'); 
 gyy = zeros(H,W,'gpuArray');
 f = zeros(H,W,'gpuArray'); 
 
 j = 1:H-1; 
 k = 1:W-1;
 
 % ... Laplacian
 gyy(j+1,k) = gy(j+1,k) - gy(j,k); 
 gxx(j,k+1) = gx(j,k+1) - gx(j,k);
 f = gxx + gyy; 
 
 clear j k gxx gyy gyyd gxxd

 % ... boundary image contains image intensities at boundaries
 
 boundary_image(2:end-1,2:end-1) = 0;
 
 %disp('Solving Poisson Equation Using DST'); 
 
%  tic
 j = 2:H-1; 
 k = 2:W-1; 
 f_bp = zeros(H,W,'gpuArray');
 
 f_bp(j,k) = -4*boundary_image(j,k) + boundary_image(j,k+1)+...
             boundary_image(j,k-1) + boundary_image(j-1,k) + boundary_image(j+1,k);
 
 clear j k
 
 f1 = f - reshape(f_bp,H,W);       % subtract boundary points contribution

 clear f_bp f
 
% ... DST Sine Transform algo starts here

 f2 = f1(2:end-1,2:end-1); 
 clear f1
 
% ... compute sine transform

 tt = dst(f2); 
 f2sin = dst(tt')'; 
 clear f2
 
% ... compute Eigenvalues

[x,y] = meshgrid(1:W-2,1:H-2); 
denom = (2*cos(pi*x/(W-1))-2) + (2*cos(pi*y/(H-1)) - 2) ;

% ... divide

f3 = f2sin./denom; 
clear f2sin x y

% ... compute Inverse Sine Transform

tt = idst(f3); 
clear f3; 
img_tt = idst(tt')'; 
clear tt

% time_used = toc; 

% disp(sprintf('Time for Poisson Reconstruction = %f secs',time_used));

% ... put solution in inner points, outer points obtained from boundary image

img_direct = boundary_image;
img_direct(2:end-1,2:end-1) = 0;
img_direct(2:end-1,2:end-1) = img_tt; 

return

%% Programmer(s) 
% Original code by Prof. Ramesh Raskar at MIT
% 
% 2nd Revision by Fang Liu, Yue Zhang
% 04/21/2016
%
% 3rd Revision by Zekun Cao, Qiwei Han 
% 04/03/2017