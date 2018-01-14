function h = showIm_preEditing ( D, filenames  ) 
% 
%   h = showIm_preEditing ( D, filenames )  ;
% 
%  Input 
%  ====
%  D : a structure for editing material 
%            D.mskR     % binary mask 
%            D.src      % foregrond image 
%            D.tar      % background image 
%            D.embed    % embed the foreground into the background image 
% 
%  filenames : if provided, they are used as the filenames to 
%              store the images in data D 
%              filenames{1} for foreground image  
%              filenames{2} for background image 
%              filenames{3} for embeded image 
% 
% Output 
% ======
% h : a handler for the figure displaying the images in data set A 
% 
% see showIm_embeded 


h = figure ;

subplot( 2, 2, 1 ) 
imshow( uint8( D.src ) ) ; 

subplot( 2, 2, 3 ) 
imshow( D.mskR ) ; 

subplot( 2, 2, 2 ) 
imshow( uint8( D.tar ) ); 

if nargin > 1                   % save  the images to files 
  imwrite( uint8(D.src), filenames{1} ); 
  fprintf( '\n   %s : %s saved \n', mfilename, filenames{1} ); 
  imwrite( uint8(D.tar), filenames{2} ); 
  fprintf( '\n   %s : %s saved \n\n', mfilename, filenames{2} );
end

end

%% Programmer 
% 
%   Xiaobai Sun 
%   Duke CS 
