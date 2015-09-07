function [ IC_mapped, out_type  ] = PoincareMapStep( Sim, dIC )

Simh = deepcopy(Sim);


% Set up the model:
Simh.Mod = Simh.Mod.Set('Phase','stance','LinearMotor','out');

% Init controller:
Simh.Con.IC = dIC(2);
Simh.Con.Init();

% Set IC and init 
Simh.Mod.IC = [Sim.IClimCyc(1)  dIC(1)  Sim.IClimCyc(3)   Sim.IClimCyc(4) ];
try
Simh = Simh.Init();
catch init_err
    disp(init_err)
    IC_mapped = [NaN NaN];
    out_type = NaN;
    return
end
% Simulate
try
Simh = Simh.Run();
catch sim_err
    disp(sim_err)
    IC_mapped = [NaN NaN];
    out_type = NaN;
    return
end
out_type = Simh.Out.Type;
IC_mapped = Simh.ICstore(1,[ 2 5]);

    if out_type ~= 1 %make sure to fix end_condition flag to 1 (path ) or 2  (full)!!!
            IC_mapped = [NaN NaN];
    end

end