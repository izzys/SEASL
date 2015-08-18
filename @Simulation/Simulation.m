classdef Simulation < handle & matlab.mixin.Copyable
     
    properties(Constant)

        % End flags:
        EndFlag_LegHitsGroundDuringExtend = -9;
        EndFlag_MoreThanOneStance = -8;
        EndFlag_HipHitTrack = -7;
        EndFlag_NoSignChange = -6;
        EndFlag_MaxLegAngle = -5;
        EndFlag_WillNotWalk = -4;
        EndFlag_ICpenetrateGround = -3;
        EndFlag_WindowClosed = -2
        EndFlag_StoppedByUser = -1;
        EndFlag_EndOfTime = 0;
        EndFlag_DoneNumberOfSteps = 1;
        EndFlag_Converged = 2;
        EndFlag_TimeEndedBeforeConverge = 3;

    end
    
    properties
        Mod; % Model
        Con; % Controller
        Env; % Environment

        % State params
        stDim; ModCo; ConCo;
        % Event params
        nEvents; ModEv; ConEv;
    
        % Simulation parameters
        IC;
        infTime;
        tstep; tstep_normal; tstep_small = [];
        tstart; tend; tspan;
        max_leg_angle = pi/2;
        
        % Performance tracking / Statistics
        Out; % output holder
        EndCond = 0;
        % Set EndCond to run the Sim until:
        % 0 - the end of time
        % [1,numsteps] - numsteps are taken on end_slope
        % 2 - the system converges to a limit cycle
        
        StepsTaken;
        EventsCounter = 0; 

        ICstore; nICsStored = 5;
        minDiff = 1e-8; % Min. difference for LC convergence

        stepsReq = 5; % Steps of minDiff required for convergence

        stepsSS; % Steps taken since minDiff
        
        
        %check 1 stance phase for each period:
        stance_counter=0;
        
        % Poincare map calculation parameters
        IClimCyc; Period;
        PMeps = 5e-7; PMFull = 1;
        PMeigs; PMeigVs;
        % Check convergence progression
        doGoNoGo = 1; % 0 - OFF, 1 - Extend, 2 - Cut
        GNGThresh = [4,4]; % required steps for go/no-go order
        minMaxDiff = [1,0];
        ConvProgr = [0,0];
        indICtoCheck  = [1 2 5];    
        % Rendering params
        Graphics = 1;
        Fig = 0; Once = 1; StopSim;PauseSim;
        FigWidth; FigHeight; AR;
        StopButtonObj;PauseButtonObj;
        
        % Environment display
        FlMin; FlMax; HeightMin; HeightMax;
        
        % COM transformation
        tCOM; COMx0; COMy0;
        % Time display
        hTime; TimeStr = ['t = %.2f s\nSteps: %s '];
        % Convergence display
        hConv; ConvStr = 'Diff = %.2e\nPeriod = %s';

        Colors = {[1 0 0],[0 0 1],[0 1 0],[0 0 0]};
        
        VideoWriterObj;
        
        DebugMode = 0;
    end
    
    methods
        % Class constructor:
        function Sim = Simulation(varargin)

                    Sim.Mod = SEASL();
                    Sim.Con = SEASLController();
                    Sim.Env = Terrain();
           
        end
        
        % Make a deep copy of a handle object.
        function SimDC = deepcopy(Sim)
            % Instantiate new object of the same class.
            SimDC = copy(Sim);
            SimDC.Mod = copy(Sim.Mod);
            SimDC.Con = copy(Sim.Con);
            SimDC.Env = copy(Sim.Env);
        end
        
        function Sim = SetEndCond(Sim, value)
            L = length(value);
            if L<1
                error('Invalid input for EndCond');
            end
            
            if value(1) == 1
                Error = ['When setting EndCond to 1,',...
                           'a value for num. steps is also needed',...
                           '\nPlease use Sim.EndCond = [1,nsteps]'];
                if L<2
                    error(Error);
                else
                    if ~isnumeric(value(2)) || value(2)<1
                        error(Error);
                    end
                end
            end
            
            Sim.EndCond = value;
        end
        
        function Sim = SetTime(Sim,tstart,tstep,tend)
            if nargin~=4
                error(['Set time expects 3 input arguments',...
                    ' but was provided with ',num2str(nargin)]);
            end
            Sim.tstart = tstart;
            Sim.tstep_normal = tstep;
         %   Sim.tstep_small = tstep/3;
            Sim.tstep = tstep;
            if isnumeric(tend)
                if tend<=tstart+tstep
                    error('tend is too close to tstart');
                else
                    Sim.tend = tend;
                end
                Sim.infTime = 0;
            else
                if strcmp(tend,'inf')
                    % Simulation will run for indefinite time
                    Sim.infTime = 1;
                    Sim.tend = 10;
                end
            end
            Sim.Out.Tend = Sim.tend;
        end
        
        function [Xt] = Derivative(Sim,t,X)
            
            Xt = [Sim.Mod.Derivative(t,X(Sim.ModCo));
                  Sim.Con.Derivative(t,X(Sim.ConCo))];
        end

        function [value, isterminal, direction] = Events(Sim, t, X) 
            
             [xdim,ydim] = size(X);
             if xdim>ydim
                 X = X';
             end
            
            value = zeros(Sim.nEvents,1);
            isterminal = ones(Sim.nEvents,1);
            direction = zeros(Sim.nEvents,1);

            % Call model event function
            [value(Sim.ModEv), isterminal(Sim.ModEv), direction(Sim.ModEv)] = ...
                Sim.Mod.Events(t,X(Sim.ModCo), Sim.Env);
            
            % Call controller event function
            [value(Sim.ConEv), isterminal(Sim.ConEv), direction(Sim.ConEv)] = ...
                Sim.Con.Events(t,X(Sim.ConCo));
            

        end
        
        function [status] = Output_function(Sim,t,X,flag) 
            
             [xdim,ydim] = size(X);
             if xdim>ydim
                 X = X';
             end
             
           %Get control vlaue:
           switch flag
               
               case 'init'
                  
                  % get controler action - first time:
                  Sim.Mod.Hip_Torque = Sim.Con.Get_Hip_Torque(Sim.IC,t(1)); 
                  Sim.Mod.Ankle_Torque = Sim.Con.Get_Ankle_Torque(Sim.IC,t(1));
                  
                  % save for out:
                  Sim.Out.Hip_u = [Sim.Out.Hip_u ; Sim.Mod.Hip_Torque];
                  Sim.Out.Ankle_u = [Sim.Out.Ankle_u ; Sim.Mod.Ankle_Torque];                  
                  Sim.Out.Control_time  = [Sim.Out.Control_time  t(1)];

               case 'done'

                   return;
                            
               otherwise
                   

                  % Check for errors and consflicts (for debugging):
                  Sim.CheckForErrors(t,X);
                  
                  % get controler action:
                  Sim.Mod.Hip_Torque = Sim.Con.Get_Hip_Torque(X(:,end),t(1)); 
                  Sim.Mod.Ankle_Torque = Sim.Con.Get_Ankle_Torque(X(:,end),t(1));
                  
                  % save for out:
                  Sim.Out.Hip_u = [Sim.Out.Hip_u ; Sim.Mod.Hip_Torque];
                  Sim.Out.Ankle_u = [Sim.Out.Ankle_u ; Sim.Mod.Ankle_Torque];                  
                  Sim.Out.Control_time  = [Sim.Out.Control_time  t(1)];
                  
           end
           
           if Sim.Graphics == 1
             Sim.Render(t,X,flag);
           end
           
           status = Sim.StopSim; 
            
        end

        function StopButtonCB(Sim, hObject, eventdata, handles) %#ok<INUSD>
            if Sim.StopSim == 0
                Sim.StopSim = 1;
                Sim.Out.Type = -1;
                Sim.Out.Text = 'Simulation stopped by user.';
                set(hObject,'String','Close Window');
            else
                close(Sim.Fig)
            end
        end  
        
       function PauseButtonCB(Sim, hObject, eventdata, handles) %#ok<INUSD>

            if Sim.StopSim == 0 && Sim.PauseSim == 0
                
                Sim.PauseSim = 1; 
                set(hObject,'String','Resume');

                while Sim.PauseSim
                    %do nothing
                    pause(0.1)
                end
                
            elseif  Sim.StopSim == 0 && Sim.PauseSim == 1
                Sim.PauseSim = 0;
                set(hObject,'String','Pause');
            end

       end
        
       function DeleteFcnCB(Sim,hObject, eventdata, handles)%#ok<INUSD>
             
           if Sim.StopSim == 0 
               
                close all
                Sim.StopSim = 1;
                Sim.Out.Type = Sim.EndFlag_WindowClosed;
                Sim.Out.Text = 'Window closed by user, simulation stopped.';
                
           end
               
       end
        
        function out = JoinOuts(Sim,ext_out,last_i)
            if nargin<3
                last_i = length(Sim.Out.T);
            end
            
            out = Sim.Out;
            if isempty(ext_out) || length(ext_out.T)<1
                out.X = out.X(1:last_i,:);
                out.T = out.T(1:last_i,:);

            else
                out.X = [ext_out.X;out.X(1:last_i,:)];
                out.T = [ext_out.T;ext_out.T(end)+out.T(1:last_i,:)];

            end
        end
        
        function [] = RecordEvents(Sim,TE,YE,IE)
            
           if ~isempty(IE)
            
               Sim.EventsCounter = Sim.EventsCounter+1;

                   if sum(isnan(YE(end,:))) 
                       [  x , ~ ] = Sim.Mod.GetPos( YE(end,:), 'cart');
                       [ dx , ~ ] = Sim.Mod.GetVel( YE(end,:), 'cart');
                       YE(end,3) = x;
                       YE(end,4) = dx;
                   end

               Sim.Out.EventsVec.Type{Sim.EventsCounter} = IE(end);
               Sim.Out.EventsVec.Time{Sim.EventsCounter} = TE(end);
               Sim.Out.EventsVec.State{Sim.EventsCounter} = YE(end,:);
           
           end

        end
        
        function [] = CheckForErrors(Sim,t,X)
            
             % make sure model cannot be in stance phase with motor in:
             if strcmp(Sim.Mod.Phase,'stance') && strcmp(Sim.Mod.LinearMotor,'in') 
                error('Error: Cannot be in phase: stance, and linear motor: in')
             end 
             
            % make sure hip in track:
            [ ~, y_hip ] = GetPos(Sim.Mod, X, 'hip');
           
            if (y_hip+1e-6)<(2*Sim.Mod.cart_wheel_radius + Sim.Mod.cart_height - Sim.Mod.cart_width/2)
               % warning('Warning:  hip too low')
                 Sim.Out.Type = Sim.EndFlag_HipHitTrack;
                 Sim.Out.Text = 'Hip hit track';
                 Sim.StopSim = 1;
            end
            
             % make sure leg does not penetrate ground:
            [ ~, y_ankle ] = GetPos(Sim.Mod, X, 'ankle');
            if (y_ankle+1e-8)<Sim.Mod.ankle_radius
                warning('Warning:  foot penetrates ground')
                
            end 

             % make sure ZMP is within support polygon:
             if  strcmp(Sim.Mod.Phase,'stance')
                  [zmp1,zmp2] = Sim.Mod.CalcZMP( X );
%                   if abs(zmp)>Sim.Mod.foot_length/2 
%                   warning('Warning: ZMP out of support polygon')
%                   end


                 Sim.Out.ZMPtime_stamp = [Sim.Out.ZMPtime_stamp t(end)];
                 Sim.Out.ZMPval1 = [Sim.Out.ZMPval1  zmp1];
                 Sim.Out.ZMPval2 = [Sim.Out.ZMPval2  zmp2];
             end
             
             
             
             % make sure leg angle is within +-max_leg_angle
             theta = X(1);
             if (theta>Sim.max_leg_angle) || (theta<-Sim.max_leg_angle)
                 Sim.Out.Type = Sim.EndFlag_MaxLegAngle;
                 Sim.Out.Text = 'Leg reached max angle';
                 Sim.StopSim = 1;
             end
             
             
             
        end
        
    end
end


