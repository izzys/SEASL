classdef SEASLController < handle & matlab.mixin.Copyable

    
    properties
        
        stDim = 1; % state dimension of controller
        nEvents = 1; % num. of controller events
        IC;
        
        % Controller output:
        u = 0;
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
        
    end
    
    methods
        
        % Class constructor:
        function [NC] = SEASLController(varargin)
                    % do nothing
        end
        
        function [NC] = Init(NC)
            
          switch NC.Controller_Type
              
              case 'CPG'


                NC.omega0 = 1/NC.Period;
                NC.phi = [NC.phi_tau,  NC.phi_reflex ] ;
                NC.nEvents = 1+length(NC.phi);
                
                %set initial tourque:
                NC.u = 0;
                if NC.IC>NC.phi_tau(1) && NC.IC<NC.phi_tau(2)
                    NC.u = NC.tau(1);
                end
                if NC.IC>NC.phi_tau(3) && NC.IC<NC.phi_tau(4)
                    NC.u = NC.tau(2);
                end
               
              otherwise
                  
                  return;
           end    

        end

        function [Xdot] = Derivative(NC, t, X)
            
           switch NC.Controller_Type


               case 'CPG'
                   
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
                   
             case 'CPG'
                   
                    phase = X(1);
                    
                   % Event 1: end of periof
                   value(1) = 1-phase;
                   isterminal(1) = 1;
                   direction(1) = -1;
                   

                   % Event i: end of phase
                   for i = 2:NC.nEvents
                       value(i) = NC.phi(i-1)-phase;
                       isterminal(i) = 1;
                       direction(i) = -1;
                   end

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

%                         if NC.ShortenAtPhase
%                              NC.Linear_motor_in = 1;
%                         end

                    NC.u = 0;
             
                case 2  %phi1
                    
                   NC.u = NC.tau(1); 
                    
                case 3 %phi2
                    
                    NC.u = 0;
              
                case 4 %phi3
                    
                   NC.u = NC.tau(2);  
                   
                case 5  %phi4
                    
                    NC.u = 0;
                    
                    
                case 6  % short
                    
                    NC.Linear_motor_in = 1;
                    
                case 7  % extend
                    
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
                   
                   T = 4;%-40*X(1)-1*X(2);
                   
                       
               case 'CPG'
 
                    
                    T =  NC.u;

    
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
        

    end
    
    

end