function Mod = Load_Hip_params(Mod)


% Gear ratio:
Mod.Hip_params.Nr =86;

% Electrical:
Mod.Hip_params.R = 0.334; %[Ohm]
Mod.Hip_params.km =  0.0194; %[Nm/A]
Mod.Hip_params.kb = (2*pi*491/60)^(-1);
Mod.Hip_params.Kv = 0.05098039215686;

% Motor inertia:
Mod.Hip_params.I_motor  =0.07;

% Stifness:
Mod.Hip_params.k_SEA = 3.55;

% Friction:
Mod.Hip_params.c1 = 0;
Mod.Hip_params.c2 = 0.08;
Mod.Hip_params.c_SEA = 0;

Mod.Hip_params.c_total = 0.08;
