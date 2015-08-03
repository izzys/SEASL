function [ IC_mapped, out_type  ] = PoincareMapStep( Sim, IC )

tend = 10;
Sim = deepcopy(Sim);
Sim.Graphics = 0;
Sim.EndCond = [1,1];
Sim = Sim.SetTime(0,0.02,tend);


% Set up the model:
Sim.Mod = Sim.Mod.Set('Phase','swing','LinearMotor','in');
%Sim.Mod = Sim.Mod.Set('Phase','swing','LinearMotor','out');

% Init controller:
Sim.Con = Sim.Con.Set('Period',1.2,'phi',[0.1 0.25 0.4 0.99],'tau',[2 -0.9]); 
Sim.Con.Controller_Type = 'CPG';
Sim.Con.IC = 0;%[1;0;Sim.Con.omega0;1;0;];
Sim.Con.Init();

% Set internal parameters (state dimensions, events, etc)
Sim.Mod.IC = IC;
Sim = Sim.Init();

% Simulate
Sim = Sim.Run();
out_type = Sim.Out.Type;
IC_mapped = Sim.ICstore(:,1);
end

