function videoStream=writeVideo_embeded ( D, pVid, version, corB, filenames  )
%
%  SYNTAX
%
%  SHOWVIDEO_EMBEDED ( D, PVID, VERSION, CORB, FILENAMES  );
%
%  INPUT
%  ====
%  D : a structure for editing material
%            D.mskR     % binary mask                           [R-by-S]
%            D.tar      % background image                      [M-by-N-by-3]
%
%  PVID : foreground video                                      [P-by-Q-by-3-by-FrameCount]
%
%  VERSION : show figure title based on the editing solvers:    0: Solve ||Ax-b|| directly;
%                                                               1: Biconjugate Gradient;
%
%
%  CORB :      Coordinate to apply the binary mask on           [1-by-2]
%              (The coordinate in background image)
%
%  FILENAMES : if provided, they are used as the filenames to
%              store the background image, source video and embeded video
%              filenames{1} for foreground video
%              filenames{2} for background image
%              filenames{3} for embeded video by Jacobi method
%              filenames{4} for embeded video by Biconjugate Gradient method
%
% OUTPUT
% ======
% VIDEOSTREAM : a new embeded video stream with background image and source video
%

fprintf( '\n\n   %s BEGAN ...\n', mfilename );

if nargin < 5
    error('insufficient number of input parameters');
end

if nargin > 4                  % save the images and videos to files
    if version==0
        fprintf('\n    Start sparse optimized method ... \n');
        %v = VideoWriter(filenames{3},'Uncompressed AVI'); % Create a VideoWriter object 
                                                          % for a new uncompressed AVI file 
                                                          % for RGB24 video.
        %v.FrameRate = 45;
%         open(v);
        newFrames.cdata=[];
        newFrames.colormap=[];
%         gpuDev = gpuDevice(1); 
%         newFrames(1).colormap=[];                          % Create a struct to store images
        parfor i=1:length(pVid)                           % Start writing newFrame in parallel way
%             open(v);
            fprintf("Total frames: %d. Handle NO.%d.\n", length(pVid),i);
            a=PoissonEditing_new_directDiv(D.tar, im2double(pVid(i).cdata), D.mskR, corB);
            a=im2uint8(a);
            newFrames(i).cdata=a;
%             writeVideo(v, a);
%             wait(gpuDev);
        end
        %open(v);
        %writeVideo(v,newFrames);
        %close(v);
        %fprintf( '\n   %s : %s saved \n', mfilename, filenames{3}); 
        videoStream=newFrames;
        
        
%         fprintf('\n    Start Sparse matrix optimized method  ... \n');
%         stepEchoProgress = 500;                           % iteration steps for progress echo
%         nMaxIter    = 5000;                               % max number of Jacobi solver iterations
%         tauDiffL2   = 1e-6;                               % threshold for insignificant iterate difference
%         v = VideoWriter(filenames{3},'Uncompressed AVI'); % Create a VideoWriter object 
%                                                           % for a new uncompressed AVI file 
%                                                           % for RGB24 video.
%         v.FrameRate = 60;
%         open(v);
%         for i=1:length(pVid)   % Start writing the new video. For loop in a parallel way
%             b=im2double(pVid(i).cdata);
%             a = poissonEditingJacobi(D.tar, b, logical(D.mskR), corB, nMaxIter, tauDiffL2,...
%             'stepecho', stepEchoProgress);
%             writeVideo(v,im2uint8(a));
%         end
%         close(v);
%         fprintf( '\n   %s : %s saved \n', mfilename, filenames{3}); 
    elseif version==1
        fprintf('\n    Start FFT+GPU optimized method ... \n');
%         v = VideoWriter(filenames{4},'Uncompressed AVI'); % Create a VideoWriter object 
                                                          % for a new uncompressed AVI file 
                                                          % for RGB24 video.
%         v.FrameRate = 45;
        newFrames.cdata=[];
        newFrames.colormap=[];
%         gpuDev = gpuDevice(1); 
%         newFrames(1).colormap=[];                          % Create a struct to store images
%     spmd
%         gpuDevice(1+mod(labindex-1,gpuDeviceCount))
%     end
       parfor i=1:length(pVid)                           % Start writing newFrame in parallel way
%             open(v);
            fprintf("Total frames: %d. Handle NO.%d.\n", length(pVid),i);
            a=FFT_editing(gpuArray(D.tar), gpuArray(im2double(pVid(i).cdata)), gpuArray(D.mskR), corB);
            a=im2uint8(a);
            newFrames(i).cdata=gather(a);
%             writeVideo(v, a);
%             wait(gpuDev);
        end
%         open(v);
        %newFrames=gather(newFrames);
%         writeVideo(v,newFrames);
%         close(v);
%         fprintf( '\n   %s : %s saved \n', mfilename, filenames{4}); 
        videoStream=newFrames;
    end
        
end



%% Programmer
% Zekun Cao
% Spring 2017