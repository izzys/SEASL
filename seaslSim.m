clc;%clear all;close all;clear classes;
set(0,'DefaultFigureWindowStyle','normal')

Sim = Simulation();
Sim.Graphics = 1;
%1: number of steps, 2: covergance

Sim.EndCond = 2;
Sim = Sim.SetTime(0,0.01,100);

% set terrain:
Sim.Env.DisturbanceMaxHeight = 0.03;
Sim.Env.DisturbanceSign = 1;
Sim.Env.start_x = 2;
Sim.Env.end_x = 4;

% Set up the model:

% <<<<<<< HEAD
% % Init controller:
% Sim.Con = Sim.Con.Set('Period',1.2,'phi',[0.1 0.25 0.4 0.99],'tau',[2 -0.9]); 
% Sim.Con.Controller_Type = 'CPG';%'Const';%
% Sim.Con.IC = 0;%[1;0;Sim.Con.omega0;1;0;];
% Sim.Con.Init();
% 
% % Simulate:
% Sim.Mod.IC = [ -0.601243027678524   1.232622029427107  0   3.205736429418639]'; %for reflex at extend and short
% %Sim.Mod.IC = [ -0.3588  -2.4  0   3.3]'; %for reflex at extend
% =======

Sim.Mod = Sim.Mod.Set('Phase','stance','LinearMotor','out');


% Init controller:                                                                    short             extend
Sim.Con = Sim.Con.Set('Period',1.2,'phi_tau',[0.1 0.25 0.4 0.99],'tau',[2 -3],...
                       'phi_reflex',[ 0.897308852443590  0.558365283467955 ]); %0.897308852443590   0.558365283467955
% Sim.Con = Sim.Con.Set('Period',1.2,'phi_tau',[0.1 0.25 0.4 0.99],'tau',[2 -3],...
%                        'phi_reflex',[ NaN  NaN ]); %0.897308852443590   0.558365283467955
Sim.Con.Controller_Type = 'CPG';


Sim.IClimCyc = [ 0.359391210427835  -3.525464278622958  0   2.970203654740103   0.710126001714929] ;

Sim.Con.IC = Sim.IClimCyc(5); % LC
%Sim.Con.IC = 0.707;
    
Sim.Con.Init();

% note that if IC match the stance phase - only the first two IC count:

Sim.Mod.IC =   Sim.IClimCyc(1:4); % LC

% add disturbance:
Sim.Mod.IC(1) =  Sim.Mod.IC(1);%-2.056; 


Sim = Sim.Init();

% Simulate:
% Sim.VideoWriterObj = VideoWriter('SEASL_simulation.avi');
% open(Sim.VideoWriterObj);

Sim.DebugMode = 0;
Sim = Sim.Run();
% close(Sim.VideoWriterObj);

if Sim.Out.Type == Sim.EndFlag_Converged
Sim.PMeps = 5e-7;
[EigVal,EigVec] = Sim.Poincare();
EigVal
end

plot_out(Sim);


