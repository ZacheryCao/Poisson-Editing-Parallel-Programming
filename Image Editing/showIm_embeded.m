function h = showIm_embeded ( D, h, version , Time, filenames )
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
%   version : show figure title based on the editing solvers: 0: Jacobi;
%                                                                                          1: Conjugate Gradient;
%                                                                                           2: Direct Solver (with Sparse Matrix)
%
%   Time:   running time of the method code             [scalar]
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

figure(h)  ;

subplot( 2, 2, 4 )
imshow( uint8( D.embed) ) ;
if version==0
title(['Jacobi (',num2str(Time),' s)']);
elseif version==1
title(['CG (',num2str(Time),' s)']);
elseif version==2
title(['Direct Solver (with Sparse Matrix) (',num2str(Time),' s)']);
end
if nargin > 4                  % save  the images to files
    if version==0
        imwrite( uint8(D.embed), filenames{3} );
        fprintf( '\n   %s : %s saved \n', mfilename, filenames{3} );
    elseif version==1
        imwrite( uint8(D.embed), filenames{4} );
        fprintf( '\n   %s : %s saved \n', mfilename, filenames{3} );
    elseif version==2
        imwrite( uint8(D.embed), filenames{5} );
        fprintf( '\n   %s : %s saved \n', mfilename, filenames{3} );
    end
end

end

%% Programmer
%
% % Original by Xiaobai SUn
% % New version by Yuan Fang