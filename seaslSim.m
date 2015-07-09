clc;clear all;close all;clear classes;
set(0,'DefaultFigureWindowStyle','normal')

Sim = Simulation();
Sim.Graphics = 1;
%1: number of steps, 2: covergance
Sim.EndCond = 2;
Sim = Sim.SetTime(0,0.02,100);

% Set up the model:
Sim.Mod = Sim.Mod.Set('Phase','swing','LinearMotor','in');
%Sim.Mod = Sim.Mod.Set('Phase','swing','LinearMotor','out');

% Init controller:
Sim.Con = Sim.Con.Set('Period',1.3,'phi',[0.1   0.4   0.6   0.9],'tau',[2 -2]); 
Sim.Con.Controller_Type = 'CPG';
Sim.Con.IC = 0;%[1;0;Sim.Con.omega0;1;0;];
Sim.Con.Init();

% Simulate:
Sim.Mod.IC = [-0.358 0 0 3 ]'; 

Sim = Sim.Init();

% Sim.VideoWriterObj = VideoWriter('SEASL_simulation.avi');
% open(Sim.VideoWriterObj);
Sim = Sim.Run();
% close(Sim.VideoWriterObj);

if Sim.Out.Type == Sim.EndFlag_Converged
Sim.PMeps = 1e-7;
[EigVal,EigVec] = Sim.Poincare();
EigVal
end

plot_out;
