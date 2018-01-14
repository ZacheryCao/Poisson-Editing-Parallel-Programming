function [SVIDEO]=videoConverting(Vsrc)
%
% VIDEOCONVERTING - extract a part of source video and convert it into struct
%
% INPUT
%   
%   VSRC     file path of source video                [.avi, .mp4, .rmvb]
%
% OUTPUT
%
%   SVDIEO   struct of source video      [Mt-by-Nt-by-C-by-Fn] 
%
% DESCRIPTION
%
%   SVIDEO=VIDEOCONVERTING(VSRC)
%   employs default function VideoReader and VideoWriter to convert
%   original videostreams into a struct of matrix, whose fields are
%   framedata of original video. The framerate of Svideo is 60 FPS. 
%
% see also videoreader, videowriter



%% Input the video
fprintf('##############################################');
vObj = VideoReader(Vsrc);
nFrames = vObj.NumberOfFrames; %% get the number of frames 
fprintf('\n --------- Input Video: ----------- \n');
fprintf('\n framerate = %.0f FPS, framecount = %.0f, duration = %6.2f s \n',vObj.FrameRate,vObj.NumberOfFrames,vObj.Duration);

% Store the video into myMovie 
myMovie = read(vObj,[1 nFrames]); % Chose frames from 1 to nFrames

%% Video writing
% Initialization
myVideo = VideoWriter('preprocess.avi', 'Uncompressed AVI'); %% initialize videowriter, output to proprocess.avi without compression
myVideo.FrameRate = 45; %% set the framerate at 60 FPS

% Start writing
open(myVideo);
writeVideo(myVideo, myMovie);
fprintf('\n --------- Video after Preprocessing: -----------\n');
fprintf('\n framerate = 45 FPS, framecount = %d, duration = %6.2f s\n',myVideo.FrameCount,myVideo.Duration);
close(myVideo);

% Input preprocess.avi to Svideo for further editing in next step
SVIDEO=importdata('preprocess.avi');

%% Programmer(s)
%
% Original by Zekun Cao
% Spring 2017
%
