clc;close all; %clear all;clear classes

GA = MOOGA(50,25);

GA.FileOut = ['TestGA_',datestr(now,'dd_mm_yy_hh_MM'),'.mat'];

GA = GA.SetFittest(20,20,0.5);
GA.JOAT = 1; GA.Quant = 0.6;


GA.FileOut = ['GA_',datestr(now,'mm_dd_hh_MM'),'.mat'];
GA.Graphics = 1;

% GA.ReDo = 1;

% Set up the genome
Keys =  {'Period' ,             'phi'                        ,     'tau'         ;...
             1    ,   [1     ,    1      ,   1    ,  1    ]  ,  [  1   ,   1 ]  };
Range = {   0.5   ,   [0     ,    0.25   ,   0.5  ,  0.75 ]  ,  [ -10  ,  -10]   ; % Min
             2    ,   [0.25  ,    0.5    ,   0.75 ,  1    ]  ,  [  10  ,   10]  }; % Max

GA.Gen = Genome(Keys, Range);

% Set up the simulations
GA.Sim = Simulation();
GA.Sim.Graphics = GA.Graphics;
GA.Sim.EndCond = 2; % Run until converge (or fall)

% Set up the compass biped model
GA.Sim.Mod = GA.Sim.Mod.Set('Phase','swing','LinearMotor','in');
 

% Initialize the controller
GA.Sim.Con = GA.Sim.Con.Set('Period',1.2,'phi',[0.1 0.25 0.4 0.99],'tau',[0.7 -0.9]);
GA.Sim.Con.Controller_Type = 'CPG';
GA.Sim.Con.IC = 0;
GA.Sim.Con.Init();

GA.Sim = GA.Sim.SetTime(0,0.15,40);
GA.Sim.Mod.IC = [ -0.3588  0  0   0]';

% Fitness functions
GA.FitFcn = {1, @MOOGA.VelFit;
             2, @MOOGA.EigenFit};

GA.FitIDs = [1,2];
GA.NFit = size(GA.FitFcn,1);
GA.Sim.PMFull = 0; % Run poincare map on 3 coords

GA = GA.InitGen();

MutDelta0 = 0.1;
MutDelta1 = 0.01;

% Update MOOGA parameters after each generation
% j = GA.Progress/GA.Generations;
% GA.Gen.MutDelta = (1-j)*MutDelta0 + MutDelta1*j;
% GA.GenerationFcn = @GenFcn;

GA = GA.Run();
