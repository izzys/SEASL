function [  ] = GAflat(  )
% Run MOOGA to further fine tune the sequences found in stages

GA = MOOGA(20,2000);
GA.FileIn = 'TestGA_flat_06_30_12_59.mat';
% GA.FileOut = GA.FileIn;
GA.FileOut = ['TestGA_flat_',datestr(now,'mm_dd_hh_MM'),'.mat'];
GA.Graphics = 0;

% GA.ReDo = 1;

% Set up the genome
% Controller with push-off, swing pulse + limited ankle pulse
% and feedback
Keys = {'omega0','P_LegE','ExtPulses','Pulses','Pulses';
               1,       1,      [1,1],   [1,1],   [1,2]};
Range = {0.5, 0.55, [-30, 0.005], [-2, 0, 0.01], [-20, 0, 0.01]; % Min
           2, 0.85, [30, 0.005], [2, 0.99, 0.99], [20, 0.99, 0.99]}; % Max

GA.Gen = Genome(Keys, Range);

% Set up the simulations
GA.Sim = Simulation();
GA.Sim.Graphics = GA.Graphics;
GA.Sim.EndCond = 2; % Run until converge (or fall)
GA.Sim = GA.Sim.Init();
GA.Sim.stepsReq = 10; % Take less steps until convergence
GA.Sim.PMFull = 1; % Run poincare map on all 5 coords

% Set up the compass biped model
GA.Sim.Mod = GA.Sim.Mod.Set('damp',0,'I',0);

% Set up the terrain
start_slope = 0;
GA.Sim.Env = GA.Sim.Env.Set('Type','inc','start_slope',start_slope);

% Initialize the controller
GA.Sim.Con = GA.Sim.Con.ClearTorques();
GA.Sim.Con.FBType = 0;
GA.Sim.IC = [start_slope, start_slope, 0, 0, 0];

% Simulation parameters
GA.Sim = GA.Sim.SetTime(0,0.15,40);

% Some more simulation initialization
GA.Sim.Mod.LegShift = GA.Sim.Mod.Clearance;
% Sim.Con = Sim.Con.HandleEvent(1, Sim.IC(Sim.ConCo));
GA.Sim.Con = GA.Sim.Con.HandleExtFB(GA.Sim.IC(GA.Sim.ModCo),...
                                          GA.Sim.IC(GA.Sim.ConCo));
                                
% Fitness functions
GA.NFit = 3;
GA.FitFcn = {@GA.VelFit;
             @GA.NrgEffFit;
             @GA.EigenFit};

GA = GA.InitGen();
% Add the best guesses from previous runs
GA.Seqs(1:10,1:10,1) = ...
    [1.32491,0.66107,-0.01570,0.005,-1.98446,0.01223,0.76611,7.56098,0.06446,0.10987;
     1.32491,0.72147,-0.01570,0.005,-1.98446,0.01223,0.76611,7.56098,0.06446,0.10987;
     1.32491,0.72147,-0.01570,0.005,-1.98446,0.01223,0.76611,7.75285,0.06446,0.10987;
     1.33672,0.74226,-0.28342,0.005,-1.78457,0.12747,0.76611,7.19713,0.09427,0.10806;
     1.34743,0.65412,-0.01570,0.005,-1.75601,0.07494,0.72612,5.71611,0.00186,0.11990;
     1.33672,0.74226,-0.28342,0.005,-1.78457,0.08475,0.76611,7.80237,0.07867,0.10806;
     1.34743,0.68067,-0.01570,0.005,-1.75601,0.03990,0.72612,4.72148,0.00186,0.15320;
     1.33078,0.69347,-0.01570,0.005,-1.98446,0.01223,0.76611,4.72148,0.00186,0.15552;
     1.32491,0.63032,-0.01570,0.005,-1.87480,0.04302,0.78613,10.25600,0.06447,0.06590;
     1.31369,0.72147,-0.01570,0.005,-1.98446,0.01727,0.81724,6.20295,0.11312,0.10987];

GA = GA.Run();
GA.Plot('Fit');

end
