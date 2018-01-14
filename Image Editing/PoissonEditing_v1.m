function [newImg,conver] = PoissonEditing_v1 (bImg, pImg, mskR, corB, maxIter, thres)
%
% PoissonEditing - Possion editing in RGB space using Jacobi Iteration
%   
% SYNTAX
%
%   [NEWIMG] = POISSIONEDITING (BIMG, PIMG, EREGION, MAXITER, THRES)
%
% INPUT
%
%   BIMG        Background Image                              [M-by-N-by-3]
%   PIMG        Patch Image                                   [P-by-Q-by-3]
%   MSKR        binary mask on Patch Image to specify         [R-by-S]
%               the region of patch 
%   CORB        Coordinate to apply the binary mask on        [1-by-2]
%               (The coordinate in background image)
%   MAXITER     number of max iteration                       [Scalar]
%   THRES       threshold to stop iteration                   [Scalar]
%
% OUTPUT
%
%   NEWIMG      New Image                                     [M-by-N-by-3]
%   conver          Convergence value when code ends      [Scalar]
%
% DESCRIPTION
%
%   [NEWIMG] = POISSONEDITING (BIMG, PIMG, MSKR, CORB) returns the result 
%   of poisson mixing of the source image sImg in a given region 
%   represented by a binary mask mskRegion, where the region to be edited 
%   labeled 1 and others labeled 0.
%
%   [NEWIMG] = POISSONEDITING (BIMG, PIMG, MSKR, CORB, MAXITER, THRES) also
%   specify the max iteration time and threshold to stop.
% 
% see also version_2 which displays the formation of the embedding system 
% 

fprintf( '\n\n   %s BEGAN ...\n', mfilename );

%% ... DEFAULT setting for the last three parameters 

if nargin < 4
    error('insufficient number of input parameters');
elseif nargin < 5
    maxIter = 5000;
    thres = 1e-6;
elseif nargin < 6
    thres = 1e-6;
end

% ... debug/demo  mode

debugFlag = true;

%%  ... set up the sytems of equations for Poisson Editing 

% ... off-diagonal of the Laplace stencil, i.e., the kernel operator for Poisson Editing 

nK = [0 1 0 ; ...
      1 0 1 ; ...
      0 1 0 ];
  
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

maskB = zeros(size(bImg));
maskB(corB(1): bottom, corB(2): right, :) = ... 
                        mskR(1: bottom-corB(1)+1, 1: right-corB(2)+1, :);

%% ... the initial gradient map for new image 

vertG_emb = vertG_b;
vertG_emb(find(maskB == 1)) = vertG_p(find(mskR == 1));

horzG_emb = horzG_b;
horzG_emb(find(maskB == 1)) = horzG_p(find(mskR == 1));


  
% ... "b(i,j)"

b =   circshift(horzG_emb, [0 1]) - horzG_emb ... 
    + circshift(vertG_emb, [1 0]) - vertG_emb ;


%     for x=corB(1):right

%% ----------------- Jacobi Iteration ----------------------------------

% ref: http://www.cs.berkeley.edu/~demmel/cs267/lecture24/lecture24.html
% solve the Poisson Equation

% ... initialize the difference of the last iteration to Numerically Large 

iterdiff = 1e40;

% ... the initial for the new image (overlay) 

newImg = bImg;
newImg(find(maskB == 1)) = pImg(find(mskR == 1));

% intermediate result - restore the result of last iteration

iterImg = newImg;

% ... begin jacobi iteration
fprintf('\n    Jacobi iteration started ... \n');
    
for i = 1: maxIter

    % ... apply the Laplace kernel 
    wAvg = imfilter(newImg, nK, 'replicate');
    
    % ... go to next step
    newImg(find(maskB == 1)) = ... 
             (wAvg(find(maskB == 1)) + b(find(maskB == 1))) / 4;                %%% Ax4*newImg-wAvg=Dx_n-Sx_n
    
    % ... calculate the difference between new value and old value
    diffImg = abs(newImg - iterImg);
    maxdiff = sqrt( sum(diffImg(:).^2) );
    conver=(iterdiff - maxdiff)/iterdiff;
    % termination condition -- converge
    if ( (iterdiff - maxdiff)/iterdiff < thres)
        break;
    end
    
    % renew the restored values
    iterdiff = maxdiff;
    iterImg  = newImg;
    if debugFlag && mod(i,500) == 0
        fprintf('   -- at iteration %d \n', i);
    end
end

fprintf( '\n\n   %s FINISHED ...\n\n', mfilename ); 

return

%% Programmer(s) 
% 
% Revision by Xiaobai SUn 
% Spring 2016 
% 
