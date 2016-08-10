function Mod = Load_Ankle_params(Mod)

% Gear ratio:
Mod.Ankle_params.Nr =411;

% Electrical:
Mod.Ankle_params.R = 0.334; %[Ohm]
Mod.Ankle_params.km =  0.0194; %[Nm/A]
Mod.Ankle_params.kb = (2*pi*491/60)^(-1);
Mod.Ankle_params.Kv = 0.05098039215686;

% Motor inertia:
Mod.Ankle_params.I_motor  =0.07;

% Stifness:
Mod.Ankle_params.k_SEA = 3.55;

% Friction:
Mod.Ankle_params.c1 = 0;
Mod.Ankle_params.c2 = 0.08;
Mod.Ankle_params.c_SEA = 0.08;

Mod.Ankle_params.c_total = 0.08;
