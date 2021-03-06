classdef SEASL < handle & matlab.mixin.Copyable

    
    properties
        
        % theta: leg tilt relative to vertical
        % x_cart: cart location (center)
        %
        % q1 = theta, q2 = theta dot , q3 = x_cart , q4 = x_cart dot
        
        stDim = 4; % state dimension
        
        nEvents = 3; % num. of simulation events
        IC;
        x0;
        
        % System parameters:
        Env_params = [];
        Leg_params = [];
        Hip_params = [];
        Ankle_params = [];  
        Cart_params = [];
        
        Phase = 'stance'; %options: 'stance' , 'stance_hit_track' , 'swing'

        % Control:
        Hip_Torque = 0;
        Ankle_Torque = 0;
        LinearMotor = 'out'
        
        % reflexes:
        ExtendReflexOn;
        ShortenReflexOn;
        
        % Render parameters:
        hip_radius = 0.03;
        hip_color = [0.2,0.6,0.8];
        
        ankle_radius = 0.0125;
        ankle_color = [0.2,0.6,0.8];
        
        leg_length = []; % setting depends on swing/stance phase. set this at 'Sim.Init' function
        leg_width=0.05;
        leg_color=[0.1, 0.3, 0.8];
        Initial_leg_length;
        
        foot_length=0.3;
        foot_width=0.025;
        foot_color=[0.1, 0.3, 0.8];
        
        cart_length = 1;
        cart_height = 0.8;
        cart_width = 0.05;
        cart_wheel_radius = 0.04;
        cart_track_length = 0.05;
        cart_track_width = 0.04;        
        cart_color =[0.7, 0.7, 0.8];
        cart_wheel_color = [0.9 0.9 0.9];
        cart_track_color = [0.4 0.9 0.9];
        
        RenderObj;
        
        CircRes=24;
        LinkRes=10;
        LineWidth=1;
        
        slope = 0;
                     
    end
    
    methods
        
        %  Class constructor:
        function Mod = SEASL(varargin)
            
            Mod = Mod.Load_Env_params();
            Mod = Mod.Load_Cart_params();   
            Mod = Mod.Load_Leg_params();
            Mod = Mod.Load_Hip_params();
            Mod = Mod.Load_Ankle_params(); 
            
        end

        
        %  Get position:
        function [ x, y ] = GetPos(Mod, q, which)
            
            if strcmp(which,'hip')
                
                x = q(3);
                theta = q(1);
                
                switch Mod.Phase
                    case 'swing'      
                        y = 2*Mod.cart_wheel_radius+Mod.cart_height-Mod.cart_width/2;
                    case { 'stance' ,  'stance_hit_track'}
                        y = Mod.Leg_params.stance_length*cos(theta)+Mod.ankle_radius;
                    otherwise
                        error('Error: stance/swing not defined')
                end

                return;
            end
            
            if strcmp(which,'ankle')
                
                x_cart = q(3);
                theta = q(1);

                switch Mod.LinearMotor
                    
                    case 'in' 
                       
                        x = x_cart + Mod.Leg_params.swing_length*sin(theta);
                        
                        H = Mod.cart_height;
                        W = Mod.cart_width;
                        r = Mod.cart_wheel_radius;
                        y = H+2*r-W/2-Mod.Leg_params.swing_length*cos(theta); 
                        
                    case 'out'
                        
                        switch Mod.Phase
                            
                            case 'swing' 

                                x = x_cart + Mod.Leg_params.stance_length*sin(theta);

                                H = Mod.cart_height;
                                W = Mod.cart_width;
                                r = Mod.cart_wheel_radius;
                                y = H+2*r-W/2-Mod.Leg_params.stance_length*cos(theta) ;

                            case  'stance' 

                                x = Mod.x0;
                                y = Mod.ankle_radius;
            
                            case 'stance_hit_track'
                                
                               x = x_cart + Mod.Leg_params.stance_length*sin(theta);
                               y = Mod.ankle_radius;
                                        
                            otherwise
                                error('Error: stance/swing phase not defined')
                        end 
                          
                    otherwise
                        error('Error: LinearMotor in/out not defined')
                end                        
                

                return;
            end
            
            if strcmp(which,'cart')
                x = q(3);
                y = NaN;
                return;
            end

            if strcmp(which,'COM')

                x = q(3);
                y = Mod.cart_height/2;
                
            end
        end
        
        % Get velocity:
%         function [ xdot, ydot ] = GetVel(Mod, X, which)
%         end
        
        % Derivative:
        function [dq] = Derivative(Mod, t, q) %#ok<INUSL>
             
            switch Mod.Phase
                
                case 'swing'
                    
                    
                    % parameters:
                    g  =  Mod.Env_params.g;    
                    m_leg   =  Mod.Leg_params.m;
                    I_leg =  Mod.Leg_params.swing_I;
                    l_cg = Mod.Leg_params.swing_cg;                
                    m_cart = Mod.Leg_params.m+Mod.Cart_params.m;
                    c_floor = Mod.Cart_params.c_floor;
                    c_hip = Mod.Hip_params.c_total;

                    dx = q(4);
                    theta = q(1);
                    dtheta = q(2);
                    T_hip = Mod.Hip_Torque;
                  
                    % Equations:
                    
                    M = [ m_leg*l_cg*cos(theta)    m_cart+m_leg  ;  I_leg+m_leg*l_cg^2   m_leg*l_cg*cos(theta)];
                    G = [c_floor*dx-m_leg*l_cg*sin(theta)*dtheta^2 ; m_leg*g*l_cg*sin(theta)+c_hip*dtheta ];
                    F = [ 0 ; T_hip];
                    
                    dq(1) = q(2);
                    dq(3) = q(4);
                    
                    dh = inv(M)*(F-G);
                    
                    dq(2) = dh(1);
                    dq(4) = dh(2);
                    
                case 'stance'
                    
                    
                    % Parameaters:
                    g  =  Mod.Env_params.g;    
                    m_leg   =  Mod.Leg_params.m;
                    I_leg =  Mod.Leg_params.stance_I;
                    l_cg = Mod.Leg_params.stance_cg;                
                    m_cart = Mod.Cart_params.m;
                    c_floor = Mod.Cart_params.c_floor;
                    c_hip = Mod.Hip_params.c_total;             
                    c_ankle = Mod.Ankle_params.c_total;  
                    c_track = Mod.Cart_params.c_track;
                    l = Mod.Leg_params.stance_length;
                    
                    theta = q(1);
                    dtheta = q(2);
        
                    T_hip = Mod.Hip_Torque;
                    T_ankle = Mod.Ankle_Torque;
                    
                    % Equations:
                    M  = I_leg+m_cart*l^2*cos(theta)^2;
                    G1 = sin(2*theta)*dtheta^2*m_cart*l^2;
                    G2 = m_cart*l^2*dtheta^2*cos(theta)*sin(theta);
                    G3 = m_leg*g*l_cg*sin(theta);
                    G4 = (c_hip+c_ankle+c_floor*l^2*cos(theta)^2+c_track*l^2*sin(theta)^2)*dtheta;
                    tau = T_hip+T_ankle;
                    

                    dq(1) = q(2);
                    dq(2) = 1/M*(G1-G2+G3-G4+tau);
                    
                    dq(3) = -l*cos(theta)*dtheta; 
                    dq(4) = l*sin(theta)*dtheta^2-l*cos(theta)*dtheta;   
                    
                case 'stance_hit_track'
                    
                    
                    c_sole = Mod.Leg_params.c_sole;
                    c_floor = Mod.Cart_params.c_floor;
                    m_leg   =  Mod.Leg_params.m;
                    m_cart = Mod.Cart_params.m;
                    
                   % if q(4)<0.2
                 %   c_sole=c_sole*100;
                  %  end
                    
                    dq(1) = 0;
                    dq(2) = 0;    
                    dq(3) = q(4); 
                    dq(4) = -(c_floor+c_sole)/(m_leg+m_cart)*q(4); 

                otherwise
                    error('Error: phase not defined')
            
            end
            
            dq = dq';
        end
        

        
        % Events:
        function [value, isterminal, direction] = Events(Mod, t,X, Floor)
            
            value = ones(Mod.nEvents,1);
            isterminal = zeros(Mod.nEvents,1);
            direction = ones(Mod.nEvents,1);
            
            % Event #1 - foot hits floor:
            if strcmp(Mod.Phase,'swing') 
                [~,y_ankle] = Mod.GetPos(X,'ankle');
                value(1) = y_ankle-Mod.ankle_radius;
                isterminal(1) = 1;
                direction(1) = -1;   
            end
            
            % Event #2 - hip hits track limit at stance phase:
            if strcmp(Mod.Phase,'stance')
                [~,y_hip] = Mod.GetPos(X,'hip');
                value(2) = y_hip+1e-8-2*Mod.cart_wheel_radius - Mod.cart_height+Mod.cart_width/2;
                isterminal(2) = 1;
                direction(2) = -1;                                 
            end  

            % Event #3 - max height to open leg:
             if strcmp(Mod.Phase,'swing')

                value(3) = X(2);
                isterminal(3) = 1;
                direction(3) = -1;                                 
            end            
            
            
        end
        
        % Handle Events:
        function [Mod,Xa] = HandleEvent(Mod, evID, Xb, t)
            
            Xa = Xb;
            
            
            switch evID
                
                case 1 % Event #1 - foot hits floor:
                               
                    e = Mod.Leg_params.e;
                    l = Mod.Leg_params.stance_length;
                    m_cart = Mod.Cart_params.m;
                    I=  Mod.Leg_params.stance_I;
                
                    theta = Xb(1);
                    dtheta_b = Xb(2);
                    dx_b = Xb(4);


                    dtheta_a = e*(I*dtheta_b-m_cart*l*cos(theta)*dx_b)/(I+m_cart*l^2*cos(theta)^2);

                    dx_a = -l*cos(theta)*dtheta_a; 

                    Xa(2) = dtheta_a;
                    Xa(4) = dx_a;
                    
                    Mod.Phase = 'stance';
                    Mod.x0 = Xb(3)+l*sin(theta);
                    

                case 2 % Event #2 - hip hits track limit at stance phase:
                    
                    if Mod.ShortenReflexOn
                        
                        Mod.leg_length = Mod.Leg_params.swing_length;
                        Mod.Phase = 'swing';
                        Mod.LinearMotor = 'in';
                        
                    else
                        
                        Xa(2) = 0;
                        Mod.Phase = 'stance_hit_track'; 
                        
                    end


                    
                case 3 % Event #3 - max height to open leg:
                    
                  if Mod.ExtendReflexOn 
                      
                    Mod.LinearMotor = 'out';
                      
                  end
       
%                          Mod.Phase = 'stance';
%                          theta = Xb(1);
%                          l = Mod.Leg_params.stance_length;
%                          Mod.x0 = Xb(3)+l*sin(theta);
%                          Xa(4) = 0;

            end

        end
        

    end % end methods
end