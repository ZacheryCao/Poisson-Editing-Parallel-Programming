function [newImg] = FFT_editing (bImg2, pImg, mskR, corB)
%
% function 
%
% PoissonEditing: Possion editing in RGB space using fast Fourier transform
%   
% SYNTAX
%
%   [newImg] = SOR_editing (bImg, pImg, mskR, corB, maxIter, thres)
%
% INPUT
%
%   BIMG        Background Image                              [M-by-N-by-3]
%   PIMG        Patch Image                                   [P-by-Q-by-3]
%   MSKR        Binary mask on Patch Image to specify         [R-by-S]
%               the region of patch 
%   CORB        Coordinate to apply the binary mask on        [1-by-2]
%               (The coordinate in background image)
%
%
% OUTPUT
%
%   NEWIMG      New Image                                     [M-by-N-by-3]
%
% DESCRIPTION
%
%   [NEWIMG] = POISSONEDITING (BIMG, PIMG, MSKR, CORB) 
%   returns the result of poisson mixing of the source image in a given region 
%   represented by a binary mask mskRegion, where the region to be edited 
%   labeled 1 and others labeled 0. 
%
%   It also specify the max number of iteration and threshold to stop.
%

%% ... DEFAULT setting for the last three parameters 

if nargin < 4
    error('insufficient number of input parameters');
end

    
%%  ... set up the sytems of equations for Poisson Editing 

% ... add an extra border to target image

[lb, wb, ~] = size(bImg2);

bImg=zeros(lb+2,wb+2,3,'gpuArray');
bImg(2:lb+1,2:wb+1,:)=bImg2(1:end,1:end,:);


% ... set up the right hand side 
%     find the gradientmap for both images 

%     vertical components 

vertK = [-1; 1];         % derivative filter  
vertG_b = imfilter( bImg, vertK, 'replicate');
vertG_p = imfilter( pImg, vertK, 'replicate');

%     horizontal components 

horzK = [-1, 1];
horzG_b = imfilter( bImg, horzK, 'replicate');
horzG_p = imfilter( pImg, horzK, 'replicate');


% ... find the size of the embedding/editing region

[lr, wr, ~] = size(pImg);
[lb, wb, ~] = size(bImg);

bottom = min( lb, lr + corB(1) -1 ) ; 
right  = min( wb, wr + corB(2) -1 ) ; 

%%  ... create maskB for background image

maskB = zeros(size(bImg,1),size(bImg,2),3,'gpuArray');
maskB(corB(1): bottom, corB(2): right, :) = ... 
                        mskR(1: bottom-corB(1)+1, 1: right-corB(2)+1, :);

%% ... the initial gradient map for new image 

vertG_emb = vertG_b;
vertG_emb(find(maskB == 1)) = vertG_p(find(mskR == 1));

horzG_emb = horzG_b;
horzG_emb(find(maskB == 1)) = horzG_p(find(mskR == 1));

 
%% ... fft

gx=horzG_emb;
gy=vertG_emb;
[newImg] = poisson_solver_function(gx,gy,bImg);
newImg = newImg(2:end-1,2:end-1,:);
% newImg = gather(newImg);



return

%% Programmer(s) 
% Initial code by Xiaobai Sun
%
% 2nd Revision by Fang Liu, Yue Zhang
% 04/21/2016
%
% 3rd Revision by Zekun Cao, Qiwei Han 
% 04/03/2017