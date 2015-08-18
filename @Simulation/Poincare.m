function [EigVal,EigVec] = Poincare( sim )
% Calculates the Linearized Poincare eigenvalues
% Version 0.1 - 10/05/2014
% 
% if sim.PMFull == 1
%     Ncoord = sim.stDim;
% else
%     Ncoord = length(sim.ModCo);
% end

Coords = [ 2 5];
Ncoord = length(Coords);

% Limit cycle initial conditions
IC = repmat(sim.IClimCyc(Coords), Ncoord, 1);

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
    PMSim.Graphics = 1;
    PMSim.Mod = PMSim.Mod.Set('Phase','stance','LinearMotor','out');

    % Init controller:
    PMSim.Con.IC = dIC(d,2);
    PMSim.Con.Init();
    
    PMSim.Mod.IC(1) = sim.IClimCyc(1);  
    PMSim.Mod.IC(2) = dIC(d,1);
    PMSim.Mod.IC([3 4])=[NaN NaN];
    PMSim = PMSim.Init();

    PMSim = PMSim.Run();

%     if PMSim.Out.Type ~= Sim.EndFlag_Converged
%         % Robot didn't complete the step
%         EigVal = 2*ones(Ncoord,1);
%         EigVec = eye(Ncoord);
%         return;
%     end
    dICp(d,:) = PMSim.ICstore(1,Coords);
end

% Calculate deviation
DP = 1/sim.PMeps*(dICp - IC);
[EigVec,EigVal] = eig(DP,'nobalance');
EigVal = diag(EigVal);
end