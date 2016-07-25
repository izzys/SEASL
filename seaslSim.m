clc;clear all;close all;clear classes;
set(0,'DefaultFigureWindowStyle','normal')

Sim = Simulation();
Sim.Graphics = 1;
%1: number of steps, 2: covergance

Sim.EndCond = 2;
Sim = Sim.SetTime(0,0.05,100);

% set terrain:
Sim.Env.DisturbanceMaxHeight = 0.00;
Sim.Env.DisturbanceSign = -1;
Sim.Env.start_x = 5;
Sim.Env.end_x = 7;

% Set up the model:
Sim.Mod = Sim.Mod.Set('Phase','stance','LinearMotor','out');

%Init controller:   
% FOR SLOW SPEED:                                           
%Sim.Con = Sim.Con.Set('Period',1.8,'phi_tau',[0.1 0.2 0.5 0.9],'tau',[0.7 -1.8],'phi_reflex',[NaN NaN]); 

% FOR MEDIUM SPEED:
%Sim.Con = Sim.Con.Set('Period',1.56,'phi_tau',[0.1 0.25 0.45 0.9],'tau',[1.5 -2.5], 'phi_reflex',[ NaN NaN]); 
 
% FOR HiGH SPEED:                                         
Sim.Con = Sim.Con.Set('Period',1.35,'phi_tau',[0.1 0.25 0.4 0.99],'tau',[2 -3],'phi_reflex',[ NaN NaN ]);  %[0.828683558027553  0.532101234474471]


Sim.Con.Controller_Type = 'CPG';%'sin';%
Sim.Con.PhaseReset = 1;
Sim.Con.PhaseShift = 0;
%SLOW SPEED:
%Sim.IClimCyc =  [ 0.359391210428067  -2.149789227697044  11.182825327442158   1.811197424334760   0.382433325486581];

%MEDIUM SPEED:
%Sim.IClimCyc =   [0.359391210427608  -3.259474919495358  18.333707847945433   2.746107619675315   0.445934785354229];
 
%HiGH SPEED:
Sim.IClimCyc = [   0.359391210428066  -5.158800156004810  85.095951771105874   4.346289131434057   0.717706102024171];



Sim.Con.IC = Sim.IClimCyc(5); % LC

%Sim.Con.Set('tau',3,'phi0',Sim.IClimCyc(5) );  %just for fun

x = Sim.IClimCyc(2);
y = Sim.IClimCyc(5);

%uiopen
[x,y] = ginput(1);

%Sim.Con.IC = y;
%Sim.Con.IC = Sim.Con.phi0; %just for fun
%Sim.Con.IC =   0.711409136544720;
Sim.Con.Init();

% note that if IC match the stance phase - only the first two IC count:

Sim.Mod.IC =   Sim.IClimCyc(1:4); % LC

% add disturbance:
%Sim.Mod.IC(1) = Sim.Mod.IC(1);
Sim.Mod.IC(2) = x;
%Sim.Mod.IC(2) = -3.533734303786451;
Sim = Sim.Init();

% Simulate:
% Sim.VideoWriterObj = VideoWriter('SEASL_simulation.avi');
% open(Sim.VideoWriterObj);

Sim.DebugMode = 0;
Sim.IgnoreErrors = 0;
Sim = Sim.Run();
% close(Sim.VideoWriterObj);

if Sim.Out.Type == Sim.EndFlag_Converged
Sim.PMeps = 5e-7;
   Sim.Period(1) = 1;%%%CAREFULLLL
[EigVal,EigVec] = Sim.Poincare();
EigVal
end

plot_out(Sim);
