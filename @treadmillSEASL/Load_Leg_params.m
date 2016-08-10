function Mod = Load_Leg_params(Mod)


%Leg length:
Mod.Leg_params.swing_length = 0.8;
Mod.Leg_params.stance_length = 0.9;
Mod.Leg_params.swing_cg = 0.32;
Mod.Leg_params.stance_cg = 0.58;

% Leg inertia:
Mod.Leg_params.swing_I =0.15;
Mod.Leg_params.stance_I =0.2;

% Leg mass:
Mod.Leg_params.m = 2.860;

% Hrizontal friction with ground :
Mod.Leg_params.c_sole = 50;

% Impact restitution coefficient:
Mod.Leg_params.e = 1;