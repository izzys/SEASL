classdef SEASLController < handle & matlab.mixin.Copyable

    
    properties
        
        stDim = 1; % state dimension of controller
        nEvents = 1; % num. of controller events
        IC;
        
        % Controller output:
    %    u = 0;
        Linear_motor_in = 0;
        Linear_motor_out = 0;
        
        % flag to shorten leg at end of period:

        ExtendAtPhase;
        ShortenAtPhase;

        
        % Controller type:
        Controller_Type; 
        
        %PID parametrers:
        P_Gain = 1 ;
        D_Gain = 0.1;
        I_Gain = 0;
        
        % Oscillator's frequency:
        omega0;
                    
        % reflex parameters:
        ReflexOn = 0;

        % CPG parameters:
        Period;
        tau;
        phi_tau;
        phi_reflex;
        phi;
        
        Period_var; 
        phi_var;
        tau_var;
        
        Period_diff = 0; 
        phi_diff = [0 0 0 0 ];
        tau_diff= [ 0 0];   
        
        % logistic function time constant:
        TC = 100;
        
    end
    
    methods
        
        % Class constructor:
        function [NC] = SEASLController(varargin)
                    % do nothing
        end
        
        function [NC] = Init(NC)
            
          switch NC.Controller_Type
              
              case 'CPG'

                NC.omega0 = 1/(NC.Period+NC.Period_diff) ;
                NC.phi = [NC.phi_tau,  NC.phi_reflex ] ;
                NC.nEvents = 1+length(NC.phi_reflex);
                
                %set initial tourque:
              %  NC.u = 0;
%                 if NC.IC>NC.phi_tau(1) && NC.IC<NC.phi_tau(2)
%                     NC.u = NC.tau(1);
%                 end
%                 if NC.IC>NC.phi_tau(3) && NC.IC<NC.phi_tau(4)
%                     NC.u = NC.tau(2);
%                 end

              case 'CPG_with_feedback'     
              
                NC.omega0 = 1/(NC.Period+NC.Period_diff) ;
                NC.phi = [NC.phi_tau,  NC.phi_reflex ] ;
                NC.nEvents = 1+length(NC.phi_reflex);
            %    NC.u = 0;
                
              otherwise
                  
                  return;
           end    

        end

        function [Xdot] = Derivative(NC, t, X)
            
           switch NC.Controller_Type


               case {'CPG','CPG_with_feedback'}
                   
                  Xdot = NC.omega0;
                                    
              otherwise
                  
                  Xdot = 0;
           end    
   
        end
     
        function [value, isterminal, direction] = Events(NC,t, X) %#ok<INUSL>
            
            value = ones(NC.nEvents,1);
            isterminal = ones(NC.nEvents,1);
            direction = ones(NC.nEvents,1);
            
            switch NC.Controller_Type
                   
             case {'CPG','CPG_with_feedback'}
                   
                    phase = X(1);
                    
                   % Event 1: end of periof
                   value(1) = 1-phase;
                   isterminal(1) = 1;
                   direction(1) = -1;
                   

                   % Event i: end of phase
%                    for i = 2:NC.nEvents
%                        value(i) = NC.phi(i-1)-phase;
%                        isterminal(i) = 1;
%                        direction(i) = -1;
%                    end
                   
               otherwise
                  
                    return;
                   
             end
            
            
        end
        
        % Handle Events:
        function [NC,Xafter] = HandleEvent(NC, evID, Xbefore, t) %#ok<INUSD>

            Xafter = Xbefore;
            switch evID
                
                case 1 % end of periof
                  
                    Xafter = 0;
          
                case 2  % short
                    
                    NC.Linear_motor_in = 1;
                    
                case 3  % extend
                    
                    NC.Linear_motor_out = 1;
            end
            
        end
        
        function [NC,Xafter] = HandleExtEvent(NC, Ext_evID, Xbefore, t)

            Xafter = Xbefore(end-NC.stDim+1:end);
            
            switch Ext_evID
                
                case 1 

                    % ???
                            
                case 2
                    
                    % ???
                    
            end
            
        end
        
        function [T] = Get_Hip_Torque(NC,X,t)
            
           switch NC.Controller_Type
               
               case 'off' 
                  
                   T = 0;   
                   
               case 'Const'
                   
                   T = 1;%-40*X(1)-1*X(2);
                   
                       
               case {'CPG','CPG_with_feedback'}
                    
                   
                   phi1 = NC.phi_tau(1) + NC.phi_diff(1);
                   phi2 = NC.phi_tau(2) + NC.phi_diff(2); 
                   phi3 = NC.phi_tau(3) + NC.phi_diff(3);
                   phi4 = NC.phi_tau(4) + NC.phi_diff(4);
                   
                   tau1 = NC.tau(1) + NC.tau_diff(1);
                   tau2 = NC.tau(2) + NC.tau_diff(2);
                   
                    T =  tau1*NC.logisticFcn(X(end)-phi1) ...
                       - tau1*NC.logisticFcn(X(end)-phi2) ...
                       + tau2*NC.logisticFcn(X(end)-phi3) ...
                       - tau2*NC.logisticFcn(X(end)-phi4);

 
               otherwise
                   
                       T = 0;
                   
           end
           
        end
        
       function [T] = Get_Ankle_Torque(NC,X,t)
            
           switch NC.Controller_Type
               
               case 'off' 
                  
                   T = 0;  
                   
               case 'Const'
                   
                   T = 0;
                   
               otherwise
                   
                   T = 0;
           end
           
       end
       
       function [ h ] = logisticFcn( NC, x )


                h = 1./(1+exp(-NC.TC*x));

       end
       
       
       function [dTheta] = ApplyVar(NC)
           

            NC.phi_diff(1) = (2*rand-1)*NC.phi_var(1);
            NC.phi_diff(2) = (2*rand-1)*NC.phi_var(2); 
            NC.phi_diff(3) = (2*rand-1)*NC.phi_var(3);
            NC.phi_diff(4) = (2*rand-1)*NC.phi_var(4);
                   
            NC.tau_diff(1) = (2*rand-1)*NC.tau_var(1);
            NC.tau_diff(2) = (2*rand-1)*NC.tau_var(1);
                   
            NC.Period_diff = (2*rand-1)*NC.Period_var(1);     
            
            NC.omega0 = 1/(NC.Period+NC.Period_diff);
            
            dTheta = [NC.phi_diff  NC.tau_diff   NC.Period_diff];
           
       end
    
    end

end