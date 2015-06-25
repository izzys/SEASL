function [  ] = TestGA(  )
clc;%clear all;close all;clear classes
GA = MOOGA(20,1000);
% GA.FileIn = 'TestGA_05_26_01_24.mat';
GA.FileOut = ['TestGA_',datestr(now,'mm_dd_hh_MM'),'.mat'];
GA.Graphics = 0;
% GA.ReDo = 1;


% Set up the genome

        % Pulses controller (only 1 pulse to hip)
        Keys = {'T' ,    'phi'     ,'tau';...
                 1,  [0 0.25 0.5 1],   [0.5,1]};
        Range = {0.5, [0, 0, 0 , 0], [-10, 10]; % Min
                   2, [1, 1,1 ,1]  , [-10, 10]}; % Max

GA.Gen = Genome(Keys, Range);

% Set up the simulation
GA.Sim = Simulation();
GA.Sim.Graphics = GA.Graphics;
GA.Sim.EndCond = 2; % Run until converge

% Set up the compass biped model
GA.Sim.Mod = GA.Sim.Mod.Set('Phase','swing','LinearMotor','in');

% Initialize the controller
GA.Sim.Con = GA.Sim.Con.Set('Period',1.2,'phi',[0.1 0.25 0.4 0.99],'tau',[0.7 -0.9]); 
GA.Sim.Con.Controller_Type = 'CPG';
GA.Sim.Con.IC = 0;
GA.Sim.Con.Init();

% Simulation parameters
GA.Sim = GA.Sim.SetTime(0,0.05,30);
GA.Sim.Mod.IC = [ -0.3588  -2.4  0   3.3]';

                                
% Fitness functions
GA.NFit = 3;
GA.FitFcn = {@GA.HeightFit;
             @GA.VelFit;
             @GA.NrgEffFit};

GA = GA.InitGen();
GA = GA.Run();  
end

