clc;%clear all;close all;clear classes;

Sim = Simulation();

% Init controller:                                                                    
Sim.Con = Sim.Con.Set('Period',1.35,'phi_tau',[0.1 0.25 0.4 0.99],'tau',[2 -3],'phi_reflex',[ NaN NaN ]); 

Sim.Con.Controller_Type = 'CPG';

Sim.IClimCyc = [   0.359391210428066  -5.158800156004810  85.095951771105874   4.346289131434057   0.717706102024171];

Sim.Graphics = 0;
Sim.Con.PhaseReset = 1;
Sim.EndCond = [1,1];%make sure to set: [1,1] (path )  2  (full)!!!
Sim = Sim.SetTime(0,0.05,100);
Sim.minDiff = 1e-4; % Min. difference for LC convergence
Sim.stepsReq=5;% Steps of minDiff required for convergence


Sim.IgnoreErrors = 0;


% range should be an even number
Nrange = 1000;
x_range = linspace (-8 , 8, Nrange)+Sim.IClimCyc(2);
%y_range = linspace (-0.25 , 0.25 , Nrange)+Sim.IClimCyc(5);

f = @(dIC)( PoincareMapStep(Sim,dIC) );
tic
PM = MatrixMap1D(Sim,x_range,f); %make sure to fix end_condition flag to 1 (path ) or 2  (full)!!!
toc
PM.LC = Sim.IClimCyc;

%roa_est = [];
PoincareMapPlot1D(Sim,x_range,PM)
