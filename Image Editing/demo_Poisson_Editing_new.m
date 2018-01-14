%% script demo_Poisson_Editing.m
%
% demo cases
% ==========
% case 1 : airplane as foreground (FG) and terrain as background (BG)
% case 2 : handwrting charaters (FG) and canvas (BG)
%
% data source
% ============
% http://cs.brown.edu/courses/csci1950-g/results/proj2/pdoran/
%
% Callee functions
% =================
% showIm_preEditting
% shiwIm_embeded
% PoisssonEditing
%

clear variables
close all
clc

fprintf( '\n\n   %s BEGAN ... \n\n', mfilename );

%% case 1 : embedding an airplane object into a terrain image

fprintf( '\n   load data set for case 1 ... \n' ) ;

setA = load( 'DATAsets/airplane_terrain.mat' );

Anames{1} = 'Output/FG_airplane.png' ;
Anames{2} = 'Output/BG_terrain.png'  ;
Anames{3} = 'Output/EMB_airplane_on_terrain_Jacobi.png' ;
Anames{4} = 'Output/EMB_airplane_on_terrain_CG.png' ;
Anames{5} = 'Output/EMB_airplane_on_terrain_SparseLU.png' ;
corB=[60, 100];
h1 = showIm_preEditing( setA, Anames ) ;
mode=input('------ Want show results (input 1) or debug (input 2): ');

switch mode
%% ------------  Showing results between original Jacobi, CG, Direct Solver (with Sparse Matrix) ------------------
    case 1
        time0=clock;
        [setA.embed1,conver] = ...
            PoissonEditing_v1( setA.tar, setA.src, setA.mskR, corB);        %% Jacobi
        time1=clock;

        time1=clock;
        setA.embed2 = ...
            PoissonEditing_new( setA.tar, setA.src, setA.mskR, corB,mode,1,conver);         %% Conjugate Gradient
        time2=clock;
        
        time2=clock;
        setA.embed3 = ...
            PoissonEditing_new( setA.tar, setA.src, setA.mskR, corB,mode,2,conver);         %% Direct Solver (with Sparse Matrix)
        time3=clock;
        
        disp([' Jacobi spends ',num2str(etime(time1,time0)),' s and converge at ', num2str(conver)]);
        disp([' Conjugate Gradient spends ',num2str(etime(time2,time1)),' s']);
        disp([' Direct Solver (with Sparse Matrix) spends ',num2str(etime(time3,time2)),' s;']);
        
        h1 = showIm_embeded1( setA, h1, [etime(time1,time0),etime(time2,time1),etime(time3,time2)],Anames );
    case 2
%% ------------  Debug original Jacobi, CG, Direct Solver (with Sparse Matrix) codes ------------------        
        version=input('----- Want Jacobi (input 0) or CG (input 1) or Direct Solver (with Sparse Matrix) (input 2): ');
        switch version
            case 0
                time1=clock;
                [setA.embed,conver] = ...
                    PoissonEditing_v1( setA.tar, setA.src, setA.mskR, corB);
                time2=clock;
                
                disp([' Jacobi spends ',num2str(etime(time2,time1)),' s; ']);
                %       matlabpool close;
            case 1
                 conver=input('The convergence threshold you want (default is 4e-4) = ');
                time1=clock;
                setA.embed = ...
                    PoissonEditing_new( setA.tar, setA.src, setA.mskR, corB,mode,version,conver);
                time2=clock;
                disp([' CG spends ',num2str(etime(time2,time1)),' s; ']);
            case 2
                conver=1;
                time1=clock;
                setA.embed = ...
                    PoissonEditing_new( setA.tar, setA.src, setA.mskR, corB,mode,version,conver);
                time2=clock;
                disp([' Direct Solver (with Sparse Matrix) spends ',num2str(etime(time2,time1)),' s; ']);
            otherwise
                error( 'unknown method version' );
                
        end
        TIME=etime(time2,time1);        
        h1 = showIm_embeded( setA, h1, version, TIME, Anames );
    otherwise
        error( 'unknown mode' );
end



%% ----------------

%%
fprintf( '\n   press a key for the next case \n\n' );
pause


%%  case 2 : embedding a set of characters

fprintf( '\n   load data set for case 2 ... \n' ) ;
setB = load('DATAsets/characters_canvas.mat');

Bnames{1} = 'Output/FG_handwriting.png' ;
Bnames{2} = 'Output/BG_canvas.png'  ;
Bnames{3} = 'Output/EMB_handwriting_on_canvas_Jacobi.png' ;
Bnames{4} = 'Output/EMB_handwriting_on_canvas_CG.png' ;
Bnames{5} = 'Output/EMB_handwriting_on_canvas_SparseLU.png' ;

h2 = showIm_preEditing( setB, Bnames ) ;
corB=[20, 20];
mode=input('------ Want show results (input 1) or debug (input 2): ');

switch mode
%% ------------  Showing results between original Jacobi, CG, Direct Solver (with Sparse Matrix) ------------------
    case 1
        time0=clock;
        [setB.embed1,conver] = ...
            PoissonEditing_v1( setB.tar, setB.src, setB.mskR, corB);        %% Jacobi
        time1=clock;

        time1=clock;
        setB.embed2 = ...
            PoissonEditing_new( setB.tar, setB.src, setB.mskR, corB,mode,1,conver);         %% Conjugate Gradient
        time2=clock;
        
        time2=clock;
        setB.embed3 = ...
            PoissonEditing_new( setB.tar, setB.src, setB.mskR, corB,mode,2,conver);         %% Direct Solver (with Sparse Matrix)
        time3=clock;
        
        disp([' Jacobi spends ',num2str(etime(time1,time0)),' s and converge at ', num2str(conver)]);
        disp([' Conjugate Gradient spends ',num2str(etime(time2,time1)),' s']);
        disp([' Direct Solver (with Sparse Matrix) spends ',num2str(etime(time3,time2)),' s;']);
        
        h2 = showIm_embeded1( setB, h2, [etime(time1,time0),etime(time2,time1),etime(time3,time2)], Bnames );
    case 2
%% ------------  Debug original Jacobi, CG, Direct Solver (with Sparse Matrix) codes ------------------        
        version=input('----- Want Jacobi (input 0) or CG (input 1) or Direct Solver (with Sparse Matrix) (input 2): ');
        switch version
            case 0
                time1=clock;
                [setB.embed,conver] = ...
                    PoissonEditing_v1( setB.tar, setB.src, setB.mskR, corB);
                time2=clock;
                
                disp([' Jacobi spends ',num2str(etime(time2,time1)),' s; ']);
                %       matlabpool close;
            case 1
                 conver=input('The convergence threshold you want (default is 4e-4)= ');
                time1=clock;
                setB.embed = ...
                    PoissonEditing_new( setB.tar, setB.src, setB.mskR, corB,mode,version,conver);
                time2=clock;
                disp([' CG spends ',num2str(etime(time2,time1)),' s; ']);
            case 2
                conver=1;
                time1=clock;
                setB.embed = ...
                    PoissonEditing_new( setB.tar, setB.src, setB.mskR, corB,mode,version,conver);
                time2=clock;
                disp([' Direct Solver (with Sparse Matrix) spends ',num2str(etime(time2,time1)),' s; ']);
            otherwise
                error( 'unknown method version' );
                
        end
        TIME=etime(time2,time1);
        h2 = showIm_embeded( setB, h2, version, TIME, Bnames );
    otherwise
        error( 'unknown mode' );
end
%
% %% Programmers
% % Initial draft : Tiancheng Liu
% %                 Spring 2015
% % Revision : Xiaobai Sun
% %            Spring 2016
% % Original by Xiaobai SUn
% % New version by Yuan Fang