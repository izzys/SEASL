clc;clear all;close all;clear classes;
set(0,'DefaultFigureWindowStyle','normal')

Sim = Simulation();
Sim.Graphics = 1;
%1: number of steps, 2: covergance
Sim.EndCond = 2;
Sim = Sim.SetTime(0,0.02,100);

% Set up the model:
Sim.Mod = Sim.Mod.Set('Phase','stance','LinearMotor','out');

% Init controller:                                                                          short  extend
Sim.Con = Sim.Con.Set('Period',1.2,'phi_tau',[0.1 0.25 0.4 0.99],'tau',[2 -3],'phi_reflex',[ 0.9   NaN  ]); 
Sim.Con.Controller_Type = 'CPG';
Sim.Con.IC =  0.718629453138436; %all reflex LC
Sim.Con.IC =  0.711880736600654; %extend reflex LC

Sim.Con.Init();

% note that if IC match the stance phase - only the first two IC count:
Sim.Mod.IC =  [  0.359391210428054 -3.578743845550021 NaN NaN]; %all reflex LC
Sim.Mod.IC =  [  0.359391210428062 -3.537893670232675 NaN NaN]; %extend reflex LC

Sim = Sim.Init();

% Simulate:
% Sim.VideoWriterObj = VideoWriter('SEASL_simulation.avi');
% open(Sim.VideoWriterObj);

Sim.DebugMode = 0;
Sim = Sim.Run();
% close(Sim.VideoWriterObj);

if Sim.Out.Type == Sim.EndFlag_Converged
Sim.PMeps = 1e-3;
[EigVal,EigVec] = Sim.Poincare();
EigVal
end

plot_out(Sim);
