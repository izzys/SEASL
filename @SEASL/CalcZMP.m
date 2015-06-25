function [ zmp1 , zmp2 ] = CalcZMP( Mod,X )

q = X(1);
dq = X(2);
x = X(3);

[dX] = Mod.Derivative(0, X);

ddq = dX(2);
dx = dX(3);
ddx = dX(4);


m = Mod.Leg_params.m;
m_cart = Mod.Cart_params.m;
g = Mod.Env_params.g;  
zmp_y = -Mod.ankle_radius;
l_cg = Mod.Leg_params.stance_cg;
l = Mod.Leg_params.stance_length;
Iz = Mod.Leg_params.stance_I;
  
cgx = -l_cg*sin(q);   
dHz = (m*l_cg^2*cos(2*q)*ddq+Iz)*ddq;
dPx = m*l_cg*(sin(q)*dq^2-cos(q)*ddq);

dPy = m*l_cg*(-cos(q)*dq^2-sin(q)*ddq);
lx = -l*sin(q);    
ly = l*cos(q);    
f_track = l*sin(q)*dq*Mod.Cart_params.c_track;
f_cart = -m_cart*ddx-Mod.Cart_params.c_floor*dx;
Mcart =  lx*f_track-ly*f_cart;

tau = Mod.Hip_Torque+Mod.Ankle_Torque;
zc = l_cg;
%  disp zmp:

zmp1 = (dHz+zmp_y*dPx-m*g*cgx-Mcart)/(dPy-m*g);


ddy = -l_cg*(cos(q)*dq^2+sin(q)*ddq);
zmp2 =  -tau/(m*g+ddy);
 



end

