function [ IC_mapped, out_type  ] = PoincareMapStep( Sim, dIC )

tend = 10;

Simh = deepcopy(Sim);
Simh.Graphics = 0;
Simh.EndCond = [1,1];
Simh = Simh.SetTime(0,0.05,tend);

% Set up the model:
Simh.Mod = Simh.Mod.Set('Phase','swing','LinearMotor','in');

% Init controller:
Simh.Con.IC = 0;
Simh.Con.Init();

% Set IC and init
Simh.Mod.IC = [dIC(1) , dIC(2) , 0 , dIC(3)]';
try
Simh = Simh.Init();
catch init_err
    disp(init_err)
    IC_mapped = [ 999 999 999]';
    return
end
% Simulate
try
Simh = Simh.Run();
catch sim_err
    disp(sim_err)
    IC_mapped = [ 999 999 999]';
    return
end
out_type = Simh.Out.Type;
IC_mapped = Simh.ICstore([1 2 4]',1);

    if out_type ~= 1
            IC_mapped = [ 999 999 999]';
    end

end