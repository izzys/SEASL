clc;clear all;close all;clear classes;

Sim = Simulation();



% Simulate:
IC = [-0.3 0 0 1];

 [ IC_mapped, out_type  ] = PoincareMapStep( Sim, IC )

