clc;clear all;close all;clear classes;

plot_trajectory = 1;
desired_speed = 2.5; %[m/s]

[ SYS ] = InitEnvironmentSEASL(desired_speed);

% phi = [0.05 0.45 0.55 0.9];
% tau = [15 , -15];
% T = 1.1;

phi = [0.0971    0.4313    0.4853    0.9600];
tau = [16.0767  -17.0128 ];
T = 1.2018;

theta = [ phi , tau , T];%
sigma = [ 0, 0, 0 ,0 ,0, 0, 0];
gamma = 1;

%     angle  angle/sec    x      x/sec   phase
IC =  [ 0.35  -3.5        0       2.97   0.71] ;
tic
[ xp , r , dtheta , J] = GetTrajectorySEASL(SYS , IC,theta , sigma ,gamma , plot_trajectory);
toc