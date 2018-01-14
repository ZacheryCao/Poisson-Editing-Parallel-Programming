function h = showIm_embeded1 ( D, h, Time, filenames  ) 
%   
%  h = showIm_embeded ( D, h, filenames  ); 
% 
%  Input 
%  ====
%  D : a structure for editing material 
%            D.mskR     % binary mask 
%            D.src      % foregrond image 
%            D.tar      % background image 
%            D.embed    % embed the foreground into the background image 
% 
%  h : handler for figure window 
% 
%   Time: Running time of three methods                 [1*3 array]
%  filenames : if provided, they are used as the filenames to 
%              store the images in data D 
%              filenames{1} for foreground image  
%              filenames{2} for background image 
%              filenames{3} for embeded image by Jacobi method
%              filenames{4} for embeded image by CG method
%              filenames{5} for embeded image by Direct Solver (with Sparse Matrix) method
% 
% Output 
% ======
% h : a handler for the figure displaying the images in data set A 
% 
% see showIm_preEditing 
% 

figure  ;

subplot( 2, 2, 1 ) 
imshow( uint8( D.embed1) ) ; 
title(['Jacobi (',num2str(Time(1)),' s)']);
subplot( 2, 2, 2 ) 
imshow( uint8( D.embed2) ) ; 
title(['CG (',num2str(Time(2)),' s)']);
subplot( 2, 2, 3 ) 
imshow( uint8( D.embed3) ) ; 
title(['Direct Solver (with Sparse Matrix) (',num2str(Time(3)),' s)']);

if nargin > 3                   % save  the images to files 
  imwrite( uint8(D.embed1), filenames{3} ); 
  fprintf( '\n   %s : %s saved \n', mfilename, filenames{3} ); 
    imwrite( uint8(D.embed2), filenames{4} ); 
  fprintf( '\n   %s : %s saved \n', mfilename, filenames{4} ); 
    imwrite( uint8(D.embed3), filenames{5} ); 
  fprintf( '\n   %s : %s saved \n', mfilename, filenames{5} ); 
end

end

%% Programmer 

% % Original by Xiaobai SUn
% % New version by Yuan Fang