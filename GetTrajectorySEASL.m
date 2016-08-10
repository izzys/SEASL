function [   xp , rew , dtheta , J ] = GetTrajectorySEASL( SYS  ,IC, theta , sigma ,gamma , plot_trajectory )

% Set up the model:
SYS.Mod = SYS.Mod.Set('Phase','stance','LinearMotor','out');
SYS.Graphics = plot_trajectory;
SYS.gamma = gamma;

% Init controller:                                                                
k_sea = 17.337556665*1000*2*(15e-3)^2*pi/180;  
 
 
 phi = theta(1:4);
 tau = theta(5:6);
 Period = theta(7);
 
 phi_var = sigma(1:4); 
 tau_var = sigma(5:6);
 Period_var = sigma(7);
 
SYS.Con = SYS.Con.Set('Period',Period,'phi_tau',phi,'tau',tau*k_sea,...
                       'phi_reflex',[ NaN  NaN ],'Period_var',Period_var,'phi_var',phi_var,'tau_var',tau_var);      
SYS.Con.Controller_Type = 'CPG';

SYS.IClimCyc = IC ;

SYS.Con.IC = SYS.IClimCyc(5); % LC
    
SYS.Con.Init();

% note that if IC match the stance phase - only the first two IC count:
SYS.Mod.IC =   SYS.IClimCyc(1:4); % LC

SYS = SYS.Init();
SYS = SYS.Run();

dtheta= SYS.Out.dTheta;
rew = SYS.Out.Reward;
J = SYS.Out.J;


xp = SYS.Out.PoincareSection;

if plot_trajectory
    plot_out(SYS)
end

end

