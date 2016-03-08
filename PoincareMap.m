clc;%clear all;close all;clear classes;

Sim = Simulation();

% set terrain:
Sim.Env.DisturbanceMaxHeight = 0;
Sim.Env.DisturbanceSign = 1;
Sim.Env.start_x = 0;
Sim.Env.end_x = 0;

%Init controller:
Sim.Con.Controller_Type = 'CPG';
Sim.Con.PhaseReset = 0;

% Init controller:                                                           
Sim.Con = Sim.Con.Set('Period',1.35,'phi_tau',[0.1 0.25 0.4 0.99],'tau',[2 -3],'phi_reflex',[ 0.828683558027553 NaN ]);  %[0.828683558027553  0.532101234474471]
Sim.Graphics = 0;
Sim.EndCond = [1,1];%make sure to set: [1,1] (path )  2  (full)!!!
Sim = Sim.SetTime(0,0.05,100);
% Sim.minDiff = 1e-4; % Min. difference for LC convergence
% Sim.stepsReq=5;% Steps of minDiff required for convergence

Sim.IClimCyc = [   0.359391210428066  -5.158800156004810  85.095951771105874   4.346289131434057   0.717706102024171];

Nrange = 96;% range should be an even number

x_range = linspace (-6.5 ,6.5 , Nrange)+Sim.IClimCyc(2);
y_range = linspace (-0.75 , 0.75 , Nrange)+Sim.IClimCyc(5);

f = @(dIC)( PoincareMapStep(Sim,dIC) );
tic
CM = CellMap2D(Sim,x_range,y_range,f); %make sure to fix end_condition flag to 1 (path ) or 2  (full)!!!
toc
roa_est = [];
PoincareMapPlot2D(Sim,x_range,y_range,CM,roa_est)
