clc;clear all;close all;clear classes;

Sim = Simulation();

%Init controller:
Sim.Con.Controller_Type = 'CPG';
Sim.Con = Sim.Con.Set('Period',1.2,'phi_tau',[0.1 0.25 0.4 0.99],'tau',[2 -3],'phi_reflex',[ 0.9   NaN  ]); 

Sim.Graphics = 0;
Sim.EndCond = [1,1];%make sure to set: [1,1] (path )  2  (full)!!!
Sim = Sim.SetTime(0,0.05,100);
Sim.minDiff = 1e-4; % Min. difference for LC convergence
Sim.stepsReq=5;% Steps of minDiff required for convergence

%Sim.IClimCyc =  [  0.359391210428062 -3.537893670232675 NaN NaN 0.711880736600654]; %extend reflex LC
Sim.IClimCyc =  [ 0.359391210428054 -3.578743845550021 NaN NaN 0.718629453138436] %all reflex LC;
Nrange = 20;% range should be an even number

x_range = linspace (-2*pi , 2*pi , Nrange)+Sim.IClimCyc(2);
y_range = linspace (-0.25 , 0.25 , Nrange)+Sim.IClimCyc(5);


f = @(dIC)( PoincareMapStep(Sim,dIC) );
tic
CM = CellMap2D(Sim,x_range,y_range,f); %make sure to fix end_condition flag to 1 (path ) or 2  (full)!!!
toc
PoincareMapPlot2D(Sim,x_range,y_range,CM)
