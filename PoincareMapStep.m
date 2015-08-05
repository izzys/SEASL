function [ IC_mapped, out_type  ] = PoincareMapStep( Sim, dIC )

tend = 10;

Simh = deepcopy(Sim);
Simh.Graphics = 1;
Simh.EndCond = [1,1];
Simh = Simh.SetTime(0,0.005,tend);

% Set up the model:
Simh.Mod = Simh.Mod.Set('Phase','swing','LinearMotor','in');

% Init controller:
Simh.Con.IC = 0;
Simh.Con.Init();

% Set IC and init
Simh.Mod.IC = [Simh.IClimCyc(1)+dIC(1) , Simh.IClimCyc(2)+dIC(2) , 0 , Simh.IClimCyc(4)+dIC(3)]';
Simh = Simh.Init();

% Simulate
Simh = Simh.Run();
out_type = Simh.Out.Type;
IC_mapped = Simh.ICstore([1 2 4]',1);

    if out_type ~= 1
            IC_mapped = [ 999 999 999]';
    end

end