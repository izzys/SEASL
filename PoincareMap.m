clc;clear all;close all;clear classes;

Sim = Simulation();
Sim.Con = Sim.Con.Set('Period',1.2,'phi',[0.1 0.25 0.4 0.99],'tau',[2 -0.9]); 
Sim.Con.Controller_Type = 'CPG';
Sim.Mod.ShortenReflexOn = 1;
Sim.Mod.ExtendReflexOn = 1;

Sim.IClimCyc = [-0.454644171863700 , -2.585322871436600  , 0 , 3.677134034074900 , 0];

% range should be an even number
Nrange = 6;
x_range = linspace (-pi/2 , pi/2 , Nrange)+Sim.IClimCyc(1);
y_range = linspace (-2*pi , 2*pi , Nrange)+Sim.IClimCyc(2);
z_range = linspace (-1 , 100 , Nrange)+Sim.IClimCyc(4);

f = @(dIC)( PoincareMapStep(Sim,dIC) );
tic
CM = CellMap(Sim,x_range,y_range,z_range,f);
toc
PoincareMapPlot(Sim,x_range,y_range,z_range,CM)
