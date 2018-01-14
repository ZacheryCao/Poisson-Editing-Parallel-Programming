function [newImg] = PoissonEditing_direct_Divide(bImg, pImg, mskR, corB)
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
%
% OUTPUT
%
%   NEWIMG      New Image                                     [M-by-N-by-3]
%
% DESCRIPTION
%
%   [NEWIMG] = POISSONEDITING (BIMG, PIMG, MSKR, CORB) returns the result
%   of poisson mixing of the source image sImg in a given region
%   represented by a binary mask mskRegion, where the region to be edited
%   labeled 1 and others labeled 0.
%
%

%% ... DEFAULT setting for the last three parameters

if nargin < 5
    error('insufficient number of input parameters');
else
    maxIter = 5000;
end

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

maskB1=maskB(:,:,1);
maskavg = imfilter(maskB1, nK, 'replicate');

%% ... the initial gradient map for new image

vertG_emb = vertG_b;
vertG_emb(find(maskB == 1)) = vertG_p(find(mskR == 1));

horzG_emb = horzG_b;
horzG_emb(find(maskB == 1)) = horzG_p(find(mskR == 1));


b =   circshift(horzG_emb, [0 1]) - horzG_emb ...
    + circshift(vertG_emb, [1 0]) - vertG_emb ;


%% ----------------- Calculate sparse matrix A and vector b ----------------------------------
tic
% ref: http://www.cs.berkeley.edu/~demmel/cs267/lecture24/lecture24.html
% solve the Poisson Equation
% ... the initial for the new image (overlay)

newImg = bImg;
newImg(find(maskB == 1)) = pImg(find(mskR == 1));

% intermediate result - restore the result of last iteration

iterImg = newImg;

fprintf('\n    Start optimized method ... \n');

x=reshape(newImg,[lb*wb 3]);        %   reorganize for right-vector b, but the vector b here is not the right-hand vector b
x0=x;
b1=reshape(b,[lb*wb 3]);

%% -------------- find the index of the right-hand b and left-hand A (Ax=b) ------------
maskB1=reshape(maskB,[lb*wb 3]);   % priority: column direction arrangement
% rearrange the mask into n*1 array
findB=find(maskB1(:,1)==1); % find the index of the mask==1 element
siz=size(findB); %

findB1=findB-lb;findB2=findB-1; % left, above, under, right
findB3=findB+1;findB4=findB+lb;

findBc=[findB1 findB2 findB3 findB4];
findBc1=reshape(findBc,[4*length(findB) 1]);
findBc2=unique(findBc1); % eliminate repeated elements

pfindBc(findBc2(1:length(findBc2)),1)=(1:length(findBc2));

maskB2=maskB1(findBc2);  % only include mask==1 and its boundary
sizBc=length(maskB2);
findBB=find(maskB2==1);  % find index for mask==1

%% ----------------- Build sparse matrix A ------------------------
ix=[1:sizBc]; iy=[1:sizBc]; iz=ones(1,sizBc);
A=sparse(ix,iy,iz,sizBc,sizBc); % initiate sparse matrix A with all diagonal element euqal to 1
Iden=A;
ix=[findBB findBB findBB findBB findBB];  % all row indexes of A
iy=[pfindBc(findB-lb) findBB-1 findBB findBB+1 pfindBc(findB+lb)];  % all column indexes of A
iz=[-1*ones(siz) -1*ones(siz) 3*ones(siz) -1*ones(siz) -1*ones(siz)];
A0=sparse(ix,iy,iz,sizBc,sizBc);
A=A+A0;

if mode==1
    thres=4e-4;         %    the true threshold in MATLAB
    %   built-in pcg code is
    %   the (Input Threshold)*norm(b).
    %   Since norm(b) here is too
    %   large, we fix the
    %   threshold number
    %   (here is 6e-4).
end
%% ------------ Using CG/ Direct Solver (with Sparse Matrix) to solve min||Ax-b|| --------------------
switch version
    
    case 1
        for i=1:3
            x0=x(:,i);      % background image value
            b2=b1(:,i);
            x01=x0(findBc2);  % find all pixel inside (mask==1 and mask boundary)
            b0=x01;
            b0(findBB)=b2(findB);  % find all b inside (mask==1), the rest in b0 is background image x0
            
            %             xnew0(:,i)=pcg(A,b0,thres,maxIter,Iden,Iden,x01);
            xnew0(:,i)=bicgstab(A,b0,thres,maxIter,Iden,Iden,x01);
        end
        
    case 2
        b00(:,:)=x(findBc2,:);
        b00(findBB,:)=b1(findB,:);
        
        xnew0(:,:)=A\b00;
end
%% ---------------- Construct embed image ----------------
xnew=x;
xnew(findBc2(1:length(findBc2)),:)=xnew0(1:length(findBc2),:);
newImg=reshape(xnew,[lb wb 3]);

newImg=reshape(xnew,[lb wb 3]);


toc

fprintf( '\n\n   %s FINISHED ...\n\n', mfilename );

return

%% Programmer(s)
%
% Original by Xiaobai Sun
%
% 2nd Revision by Dezhi Wang, Yuan Fang, Qiwei Han
% Spring 2016
%
% New version:
% Zekun Cao, Qiwei Han
% 04/03/2017
