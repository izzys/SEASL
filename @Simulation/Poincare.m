function [EigVal,EigVec] = Poincare( sim )
% Calculates the Linearized Poincare eigenvalues
% Version 0.1 - 10/05/2014

% if sim.PMFull == 1
%     Ncoord = sim.stDim;
% else
%     Ncoord = length(sim.ModCo);
% end
Ncoord = 3;
Coords = [1 2 4 ];

% Limit cycle initial conditions
IC = repmat(sim.IClimCyc(Coords), 1, Ncoord);

% Disturbed initial conditions
dIC = IC;
dICp = IC;
for d = 1:Ncoord
    dIC(d,d) = dIC(d,d) + sim.PMeps;
end

% Run the simulations
PMSim = copy(sim);
PMSim.EndCond = [1,sim.Period(1)];
%Slope = PMSim.Env.SurfSlope(PMSim.Mod.xS);
for d = 1:Ncoord
    PMSim.Graphics = 0;
    PMSim.Mod = PMSim.Mod.Set('Phase','swing','LinearMotor','in');
    %Sim.Mod = Sim.Mod.Set('Phase','swing','LinearMotor','out');

    % Init controller:
    %PMSim.Con = PMSim.Con.Set('Period',1.3,'phi',[0.1 0.25 0.5 0.8],'tau',[0.8 -0.4]); 
    PMSim.Con.Controller_Type = 'CPG';
    PMSim.Con.IC = 0;
    PMSim.Con.Init();
    
    PMSim.Mod.IC([1 2 4]) = dIC([1 2 3],d);
    PMSim.Mod.IC(3)=0;
    PMSim = PMSim.Init();
%     PMSim.Con = PMSim.Con.Reset(PMSim.IC(PMSim.ConCo));
%     PMSim.Con = PMSim.Con.HandleExtFB(PMSim.IC(PMSim.ModCo),...
%         PMSim.IC(PMSim.ConCo),Slope);
    PMSim = PMSim.Run();

    if PMSim.Out.Type ~= Sim.EndFlag_Converged
        % Robot didn't complete the step
        EigVal = 2*ones(Ncoord,1);
        EigVec = eye(Ncoord);
        return;
    end
    dICp(:,d) = PMSim.ICstore(Coords,1);
end

% Calculate deviation
DP = 1/sim.PMeps*(dICp - IC);
[EigVec,EigVal] = eig(DP,'nobalance');
EigVal = diag(EigVal);
end