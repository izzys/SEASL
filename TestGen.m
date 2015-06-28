function [Sim] = TestGen()
clc;clear all;close all;clear classes

Sim = Simulation();
Sim.Graphics = 1;
Sim.EndCond = 2; % Run until converge
tend = 60;

% Set up the model:
Sim.Mod = Sim.Mod.Set('Phase','swing','LinearMotor','in');
%Sim.Mod = Sim.Mod.Set('Phase','swing','LinearMotor','out');

% Init controller:
Sim.Con = Sim.Con.Set('Period',1.2,'phi',[0.1 0.25 0.4 0.99],'tau',[0.7 -0.9]); 
Sim.Con.Controller_Type = 'CPG';
Sim.Con.IC = 0;%[1;0;Sim.Con.omega0;1;0;];
Sim.Con.Init();

Sim.Mod.IC = [ -0.3588  -2.4  0   3.3]'; 

KeyLength = [];

Keys = {'T' ,    'phi'     ,'tau';...
         1,  [0 0.25 0.5 1],   [0.5,1]};
Range = {0.5, [0, 0, 0 , 0], [-10, 10]; % Min
           2, [1, 1,1 ,1]  , [-10, 10]}; % Max

Sim.PMFull = 1;

Gen = Genome(Keys, Range);
KeyLength = Gen.KeyLength;


if ~isempty(KeyLength)
    Gen = Genome(Keys, KeyLength, Range);
else
    Gen = Genome(Keys, Range);
end
Sim = Gen.Decode(Sim, Sequence);

% Simulation parameters
Sim = Sim.SetTime(0,0.15,tend);

% Set internal parameters (state dimensions, events, etc)
Sim = Sim.Init();

% Simulate
Sim = Sim.Run();

MOOGA.NrgEffFit(Sim);

% Calculate eigenvalues
if Sim.Out.Type == Sim.EndFlag_Converged
    [EigVal,EigVec] = Sim.Poincare();
    % Do some plots
    disp(EigVal);
else
    EigVal = 2*ones(4,1);
    disp(Sim.Out.Text);
end

% Display steady state initial conditions
disp(Sim.ICstore(:,1));
end