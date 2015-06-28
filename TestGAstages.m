function [  ] = TestGAstages(  )
clc;clear all;close all;clear classes
% Run simulation in stages
% First stage: large population to find solutions faster
% Second stage: small population to evolve faster
% Third/Fourth stage: evolving feedback gains for up/downhill
nStages = 3;
GA = cell(nStages,1);
GAstages = [20, 1000;
            25, 5000;
            50, 500];

time_stamp = datestr(now,'mm_dd_hh_MM');
Graphics = 1;
for s = 1:nStages
    GA{s} = MOOGA(GAstages(s,1),GAstages(s,2));
    GA{s}.FileOut = ['TestGA',int2str(s),'_',time_stamp,'.mat'];
    GA{s}.Graphics = Graphics;
end
GA{1}.FileIn = 'TestGA3_07_05_17_54.mat';
GA{2}.FileIn = 'GA_07_04_06_46.mat';
GA{3}.FileIn = 'TestGA3_07_05_17_54.mat';

% GA.ReDo = 1;

% Set up the genome
% CPG controller:
Keys = {'T' ,    'phi'     ,'tau';...
         1,  [0 0.25 0.5 1],   [0.5,1]};
Range = {0.5, [0, 0, 0 , 0], [-10, 10]; % Min
           2, [1, 1,1 ,1]  , [-10, 10]}; % Max
       
GA{1}.Gen = Genome(Keys, Range);
GA{2}.Gen = Genome(Keys, Range);
KeyLength = GA{2}.Gen.KeyLength;
KeyLength.kTorques_u = 3;
KeyLength.kTorques_d = 3;
GA{2}.Gen = Genome(Keys, KeyLength, Range);
GA{3}.Gen = Genome(Keys2, KeyLength, Range2);
% GA{4}.Gen = Genome(Keys3, KeyLength, Range2);

for s = 1:nStages
    % Set up the simulations
    GA{s}.Sim = Simulation();
    GA{s}.Sim.Graphics = GA{s}.Graphics;
    GA{s}.Sim.EndCond = 2; % Run until converge (or fall)
    
    % Set up the compass biped model
    GA{s}.Sim.Mod = GA{s}.Sim.Mod.Set('damp',0,'I',0);
end



% Initialize the controller
for s = 1:nStages
    % Set up the compass biped model
    GA{s}.Sim.Mod = GA{s}.Sim.Mod.Set('Phase','swing','LinearMotor','in');

    % Initialize the controller
    GA{s}.Sim.Con = GA{s}.Sim.Con.Set('Period',1.2,'phi',[0.1 0.25 0.4 0.99],'tau',[0.7 -0.9]); 
    GA{s}.Sim.Con.Controller_Type = 'CPG';
    GA{s}.Sim.Con.IC = 0;

    % Simulation parameters
    GA{s}.Sim = GA{s}.Sim.SetTime(0,0.15,40);

end
                                
% Fitness functions
for s = 1:nStages-1
    ThisGA = GA{s};
    ThisGA.NFit = 5;
    ThisGA.FitFcn = {@ThisGA.VelFit;
                     @ThisGA.EigenFit};
    GA{s} = ThisGA;
end


ThisGA = GA{end};


% Run second stage
disp('Running stage 2');
if isempty(GA{2}.FileIn)
    if exist(GA{1}.FileOut,'file')
        GA{2}.FileIn = GA{1}.FileOut;
    else
        GA{2}.FileIn = GA{1}.FileIn;
    end
end
GA{2} = GA{2}.InitGen();

Fitness = GA{nStages-1}.Fit(:,:,GA{nStages-1}.Progress);
Weights = [0.3; % velocity
           0.2; % energy
           0.5; % stability
           1.0; % uphill
           1.0]; % downhill
WeiFit = [(1:GA{nStages-1}.Population)',Fitness*Weights];
SortedFit = sortrows(WeiFit,-2);
% Select the best genome from SortedFit
BestID = SortedFit(1,1);


GA{3}.BaseGen = GA{nStages-1}.Gen;
GA{3}.BaseSeq = GA{nStages-1}.Seqs(BestID,:,GA{nStages-1}.Progress);

% Run third and fourth stages
disp('Running stage 3');
GA{3} = GA{3}.InitGen();
GA{3} = GA{3}.Run();
GA{3}.Plot('Fit');



