function [ Sim ] = Run( Sim )
% Run the simulation until an event occurs
% Handle the event and keep running
    X = [];
    Sim.Out.T = [];
    
    options=odeset('MaxStep',Sim.tstep/10,'RelTol',.5e-12,'AbsTol',.5e-11,...
            'OutputFcn', @Sim.Output_function, 'Events', @Sim.Events);

    tspan = Sim.tstart:Sim.tstep:Sim.tend;

    [TTemp,XTemp,TE,YE,IE] = ...
        ode45(@Sim.Derivative,tspan,Sim.IC,options); 

    
    if Sim.infTime == 1
        TimeCond = true;
        Sim.tend = Sim.tend + TTemp(end)-tspan(1);
    else
        TimeCond = TTemp(end)<Sim.tend;
    end
    
    % Save state and time
    if strcmp(Sim.Mod.Phase, 'stance')
        [XTemp(:,3) , ~] = Sim.Mod.GetPos(XTemp,'cart'); 
        [XTemp(:,4) , ~] = Sim.Mod.GetVel(XTemp,'cart');  
    end
    X = [X; XTemp];
    Sim.Out.T = [Sim.Out.T; TTemp];
    
    while TimeCond && Sim.StopSim == 0
        
% ~~ %%%%%%%%% for debugging %%%%%%%%%%  ~~   
if Sim.DebugMode
disp('=====================')
Sim.Mod.Phase
TE
YE
IE

disp('=====================')
pause
end
% ~~ %%%%%%%%% for debugging %%%%%%%%%%  ~~   


        StepDone = 0;
        Xa = XTemp(end,:);
        for ev = 1:length(IE)
            
            % Is it a model event?
            ModEvID = find(IE(ev) == Sim.ModEv,1,'first');
            if ~isempty(ModEvID)
                
                [Sim.Mod,Xa(Sim.ModCo)] = ...
                    Sim.Mod.HandleEvent(ModEvID, Xa(Sim.ModCo),TTemp(end));
                
                % Call controller for model events:
                if strcmp(Sim.Mod.Phase, 'stance')
                    [Xa(3) , ~] = Sim.Mod.GetPos(Xa,'cart'); 
                    [Xa(4) , ~] = Sim.Mod.GetVel(Xa,'cart'); 
                end
                [Sim.Con,Xa(Sim.ConCo)] =  ...
                    Sim.Con.HandleExtEvent(ModEvID, XTemp(end,:),Xa,TTemp(end));
                
                     
                switch ModEvID 
                    
                    case 1 %check only 1 stance phase for each period
                        Sim.stance_counter = Sim.stance_counter+1;

                         StepDone = 1;
%                         if Sim.stance_counter>1
%                             Sim.Out.Type = Sim.EndFlag_MoreThanOneStance;
%                             Sim.Out.Text = 'More than 1 stance phase for period';
%                             Sim.StopSim = 1;
%                         end

                    case 2  %check that leg hits track only if theta>0 

                        if Xa(1)>0 && ~Sim.IgnoreErrors
                            Sim.Out.Type = Sim.EndFlag_NoSignChange;
                            Sim.Out.Text = 'Leg hits track when theta>0';
                            Sim.StopSim = 1;


                        end

                    case 3 % check that foot does not extend into ground
                    
                        [ x_ankle, y_ankle ] = Sim.Mod.GetPos(Xa, 'ankle');
                        ind = find(x_ankle<=Sim.Mod.Env_params.FloorX,1,'first');
                        FloorY = Sim.Mod.Env_params.FloorY( ind );
                     
                        if (y_ankle+1e-8)<(Sim.Mod.ankle_radius+FloorY) && ~Sim.IgnoreErrors
                            Sim.Out.Type = Sim.EndFlag_LegHitsGroundDuringExtend;
                            Sim.Out.Text =' foot penetrates ground during extend';
                            Sim.StopSim = 1;

                        end
                end
               

            end

            % Is it a controller event?
            ConEvID = find(IE(ev) == Sim.ConEv,1,'first');
            if ~isempty(ConEvID)
                
                [Sim.Con,Xa(Sim.ConCo)] = ...
                    Sim.Con.HandleEvent(ConEvID, XTemp(end,Sim.ConCo),TTemp(end));
                              
%               if ConEvID==1             
                        % check change in sign at stance phase:
%                         ind_impact = find(cell2mat(Sim.Out.EventsVec.Type)==1,1,'last');
% 
%                         if ~isempty(ind_impact)
%                         theta_at_impact = Sim.Out.EventsVec.State{ind_impact}(1);
%                         theta_at_end_phse = Xa(1);
% 
%                         sign_change = sign(theta_at_impact*theta_at_end_phse);
%                             if sign_change>0  %no sign change:
%                                  Sim.Out.Type = Sim.EndFlag_NoSignChange;
%                                  Sim.Out.Text = 'No sign change in stance phase';
%                                  Sim.StopSim = 1;
%                             end
% 
%                         end               
%                end
                            
                if Sim.Con.Linear_motor_in
                    
                    Sim.Con.Linear_motor_in = 0;
                    Sim.Mod.LinearMotor = 'in';
                    Sim.Mod.Phase = 'swing';
                    Sim.Mod.leg_length = Sim.Mod.Leg_params.swing_length;
                    
%                     x_a =  Sim.Mod.GetPos(Xa,'cart');
%                     dx_a = Sim.Mod.GetVel(Xa,'cart');
%                         
%                     Xa(3) = x_a;
%                     Xa(4) = dx_a;
                    
                end
                
                if Sim.Con.Linear_motor_out
                    Sim.Con.Linear_motor_out = 0;
                    Sim.Mod.LinearMotor = 'out';
                    
                    [ x_ankle, y_ankle ] = Sim.Mod.GetPos(Xa, 'ankle');
                     ind = find(x_ankle<=Sim.Mod.Env_params.FloorX,1,'first');
                     FloorY = Sim.Mod.Env_params.FloorY( ind );
                     
                    if (y_ankle+1e-8)<(Sim.Mod.ankle_radius+FloorY) && ~Sim.IgnoreErrors
                        Sim.Out.Type = Sim.EndFlag_LegHitsGroundDuringExtend;
                        Sim.Out.Text ='foot penetrates ground during extend';
                        Sim.StopSim = 1;
                    end
                end

            end
         
        Sim.RecordEvents(TE(ev),YE(ev,:),IE(ev),Xa);    
            
        end
        
        
        Sim.IC = Xa;
        
        if StepDone
                        
            Sim.ICstore(2:end,:) = Sim.ICstore(1:end-1,:);
            Sim.ICstore(1,:) = Sim.IC;
            Sim.StepsTaken = Sim.StepsTaken+1;

            Sim = Sim.CheckConvergence();
            Sim.Out.PoincareSection(:,Sim.StepsTaken) = Sim.IC;

            Sim.stance_counter = 0;
        end
        
        
        if Sim.EndCond(1) == 1 && Sim.StepsTaken >= Sim.EndCond(2) 
                Sim.Out.Type = Sim.EndFlag_DoneNumberOfSteps;
                Sim.Out.Text = ['Finished taking ',num2str(Sim.StepsTaken),...
                    ' steps'];
                Sim.StopSim = 1;       
        end
        
        if Sim.StopSim
            break;
        end
 
       
        % Continue simulation
        tspan = TTemp(end):Sim.tstep:Sim.tend;
        if length(tspan)<2
            % Can happen at the end of tspan
            Sim.StopSim = 1;
            break;
        end
        [TTemp,XTemp,TE,YE,IE] = ...
            ode45(@Sim.Derivative,tspan,Sim.IC,options); 
        
        if Sim.infTime == 1
            TimeCond = true;
            Sim.tend = Sim.tend + TTemp(end)-tspan(1);
        else
            TimeCond = TTemp(end)<Sim.tend;
        end
        
        % Save state and time
        if strcmp(Sim.Mod.Phase, 'stance')
             [XTemp(:,3) , ~] = Sim.Mod.GetPos(XTemp,'cart'); 
             [XTemp(:,4) , ~] = Sim.Mod.GetVel(XTemp,'cart');  
        end

        X = [X; XTemp];%#ok<AGROW>
        Sim.Out.T = [Sim.Out.T; TTemp];
        
    end
    
    %for not stable IC:
    if (Sim.EndCond(1) == 2) && (TTemp(end)>=Sim.tend-Sim.tstep) && ~norm(Sim.stepsSS) 
        Sim.StopSim = 1;
        set(Sim.StopButtonObj,'String','Close Window');
        Sim.Out.Type = Sim.EndFlag_TimeEndedBeforeConverge;
        Sim.Out.Text = 'Reached end of tspan before system converged.';
        Sim.IClimCyc = Sim.IC;
        Sim.Period = [1, Inf];   
    end
    
    
    % Prepare simulation output

    Sim.Out.X = X;
    if ~isempty(Sim.Period)
        Sim.Out.Tend = Sim.Out.T(end);
    else
        Sim.Out.Tend = Sim.tend;
    end

    Sim.Out.nSteps = Sim.StepsTaken;
    Sim.Out.StepsSS = Sim.stepsSS;
    
    disp(Sim.Out.Text)


end

