 clc;
dT = 0.001;

sigma = [ 0.1, 0.1, 0.1 ,0.1 ,1, 1, 0.05];

%% theta:
%Theta initial:  

phi_i = [0.05 0.45 0.55 0.9];
tau_i = [15 , -15];
T_i = 1.1;
Theta_initial = [phi_i,tau_i,T_i];

%Theta final:
phi_f = [0.0971    0.4313    0.4853    0.9600];
tau_f = [16.0767  -17.0128 ];
T_f = 1.2018;
Theta_final = [phi_i,tau_i,T_i];

phii = 0:0.001:1;
phif = phii;
ti = phii;
tf = phii;

u_i =  tau_i(1)*logisticFcn(phii-phi_i(1))- tau_i(1)*logisticFcn(phii-phi_i(2)) + tau_i(2)*logisticFcn(phii-phi_i(3))- tau_i(2)*logisticFcn(phii-phi_i(4));
u_f =  tau_f(1)*logisticFcn(phif-phi_f(1))- tau_f(1)*logisticFcn(phif-phi_f(2)) + tau_f(2)*logisticFcn(phif-phi_f(3))- tau_f(2)*logisticFcn(phif-phi_f(4));

Ei = abs( ( phi_i(2)-phi_i(1) )*tau_i(1) ) + abs( ( phi_i(4)-phi_i(3) )*tau_i(2) ) 
Ef = abs( ( phi_f(2)-phi_f(1) )*tau_f(1) ) + abs( ( phi_f(4)-phi_f(3) )*tau_f(2) ) 

figure
plot(ti,u_i,tf,u_f,'LineWidth',2)
xlabel phase
ylabel tau
title CPG
legend('initial','learned')

%% velocity:
initial_v = NaN % did  not walk!
final_v = 2.6050;
