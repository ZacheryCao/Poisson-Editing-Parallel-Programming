%% script demo_Poisson_Editing.m
%
%
% demo cases
% ==========
% Iodine clock reaction as foreground (FG) and billiards as background (BG)
%
% data source
% ============
% http://cs.brown.edu/courses/csci1950-g/results/proj2/pdoran/
% https://www.youtube.com/watch?v=CgMOMbfUf4A
%
% Callee functions
% =================
% videoConverting
% writeVideo_embeded
% PoisssonEditing_new
% poissonEditingJacobi

clear variables
close all
clc

fprintf( '\n\n   %s BEGIN ... \n\n', mfilename );

%% embedding Iodine clock reaction into a terrain image

fprintf( '\n   load data set ... \n' ) ;
tic
setA1 = videoConverting('Source_Video/source_video.avi');
setA = load( 'DATAsets/source.mat' );
% delete(gcp('nocreate'))
% parpool
toc

Anames{1} = 'Output/FG_video.avi' ;
Anames{2} = 'Output/BG_billiards.png'  ;
Anames{3} = 'Output/EMB_Iodineclock_on_billiards_DS.avi' ;
Anames{4} = 'Output/EMB_Iodineclock_on_billiards_FFTGPU.avi' ;

corB=[1, 33];

%% ------------  Debug Jacobi with GPU, Biconjugate gradients stabilized method (BG) (with Sparse Matrix and GPU) codes ------------------        
        version=input('----- Want Direct solver (DS)(input 0) or FFT+GPU (FFTGPU) (input 1): ');
%         version=1;
        switch version
            case 0
                time1=clock;
                    stream = writeVideo_embeded(setA,setA1,0,corB,Anames);
                time2=clock;
                disp([' DS spends ',num2str(etime(time2,time1)),' s; ']);
                v = VideoWriter(Anames{3},'Uncompressed AVI'); % Create a VideoWriter object 
                                                          % for a new uncompressed AVI file 
                                                          % for RGB24 video.
                v.FrameRate = 45;
                open(v);
                writeVideo(v,stream);
                close(v);
                fprintf( '... FINISHED ...\n\n' );
                outVideo=VideoReader(Anames{3});
            case 1
                %conver=input('The convergence threshold you want (default is 1e-4) = ');
%                 setA.tar=gpuArray(setA.tar);
%                 setA.mskR=gpuArray(setA.mskR);
                spmd
        gpuDevice(1+mod(labindex-1,gpuDeviceCount))
    end
                time1=clock;
                    stream=writeVideo_embeded(setA,setA1,1,corB,Anames);
                time2=clock;
                disp([' FFTGPU spends ',num2str(etime(time2,time1)),' s; ']);
                v = VideoWriter(Anames{4},'Uncompressed AVI'); % Create a VideoWriter object 
                                                          % for a new uncompressed AVI file 
                                                          % for RGB24 video.
                v.FrameRate = 45;
                open(v);
                writeVideo(v,stream);
                close(v);
                fprintf( ' ... FINISHED ...\n\n' );
                outVideo=VideoReader(Anames{4});
            otherwise
                error( 'unknown method version' );
                
        end
        TIME=etime(time2,time1);        

        fprintf('\n --------- Output Video: ----------- \n');
        fprintf('\n framerate = %.0f FPS, framecount = %.0f, duration = %6.2f s \n',outVideo.FrameRate, outVideo.NumberOfFrames,outVideo.Duration);



%% Programmer(s)
%   Alexandros-Stavros Iliopoulos       ailiop@cs.duke.edu
%   Xiaobai Sun                         xiaobai@cs.duke.edu
%   Tiancheng Liu
%
% REVISIONS
%
%   0.3 (Spring 2017) - Alexandros
%   0.2 (Spring 2016) - Xiaobai
%   0.1 (Spring 2015) - Tiancheng
%
% New version by Zekun Cao, Qiwei Han
% Spring 2017