function [ SYS ] = InitEnvironmentSEASL(desired_speed )


SYS = Simulation();
SYS.Graphics = 0;

%1: number of steps, 2: covergance
SYS.EndCond = [1,50];
SYS = SYS.SetTime(0,0.05,100);

% set terrain:
SYS.Env.DisturbanceMaxHeight = 0.00;
SYS.Env.DisturbanceSign = 1;
SYS.Env.start_x = 2;
SYS.Env.end_x = 4;

SYS.desired_speed = desired_speed;

end

