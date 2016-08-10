function [ r ] = GetReward( Sim )

if ~Sim.StopSim %good step

phi1 = Sim.Con.phi_tau(1) + Sim.Con.phi_diff(1);
phi2 = Sim.Con.phi_tau(2) + Sim.Con.phi_diff(2); 
phi3 = Sim.Con.phi_tau(3) + Sim.Con.phi_diff(3);
phi4 = Sim.Con.phi_tau(4) + Sim.Con.phi_diff(4);

tau1 = Sim.Con.tau(1) + Sim.Con.tau_diff(1);
tau2 = Sim.Con.tau(2) + Sim.Con.tau_diff(2);

dx = Sim.GetAvgVel();
    
u = abs( tau1*(phi2-phi1) )  + abs( tau2*(phi4-phi3) );
dx_error = dx - Sim.desired_speed;
step_reward = 10;

r = -0.1*u^2-10*dx_error^2 + step_reward;

else %bad step
 r = -50;
end
    

end

