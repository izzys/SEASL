%clc;clear all;close all;clear classes;

Sim = Simulation();
Sim.Con = Sim.Con.Set('Period',1.2,'phi',[0.1 0.25 0.4 0.99],'tau',[2 -0.9]); 
Sim.Con.Controller_Type = 'CPG';

Sim.IClimCyc = [-0.454644171863700 , -2.585322871436600  , 0 , 3.677134034074900 , 0];

% range should be an even number
x_range = linspace (-pi/2 , pi/2 , 4);
y_range = linspace (-2*pi , 2*pi , 4);
z_range = linspace (-10 , 10 , 4);

f = @(dIC)( PoincareMapStep(Sim,dIC) );
CM = CellMap(x_range,y_range,z_range,f);

PoincareMapPlot(x_range,y_range,z_range,CM)