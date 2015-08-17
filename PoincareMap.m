clc;clear all;close all;clear classes;

Sim = Simulation();
Sim.Con = Sim.Con.Set('Period',1.2,'phi',[0.1 0.25 0.4 0.99],'tau',[2 -0.9]); 

Sim.Graphics = 0;
Sim.EndCond = [1,1];%make sure to set: [1,1] (path )  2  (full)!!!
Sim = Sim.SetTime(0,0.05,100);
Sim.minDiff = 1e-2; % Min. difference for LC convergence
Sim.stepsReq=5;% Steps of minDiff required for convergence

Sim.Con.Controller_Type = 'CPG';
Sim.Mod.ShortenReflexOn = 1;
Sim.Mod.ExtendReflexOn = 1;

Sim.IClimCyc = [-0.454644171863700 , -2.585322871436600  , 0 , 3.677134034074900 , 0];

Nrange = 20;% range should be an even number
x_range = linspace (-pi/2 , pi/2 , Nrange)+Sim.IClimCyc(1);
y_range = linspace (-2*pi , 2*pi , Nrange)+Sim.IClimCyc(2);
z_range = linspace (-5 , 5 , Nrange)+Sim.IClimCyc(4);

f = @(dIC)( PoincareMapStep(Sim,dIC) );
tic
CM = CellMap(Sim,x_range,y_range,z_range,f); %make sure to fix end_condition flag to 1 (path ) or 2  (full)!!!
toc
PoincareMapPlot(Sim,x_range,y_range,z_range,CM)
