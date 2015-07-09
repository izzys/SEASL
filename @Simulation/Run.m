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
    X = [X; XTemp];
    Sim.Out.T = [Sim.Out.T; TTemp];

    while TimeCond && Sim.StopSim == 0

        Sim.RecordEvents(TE,YE,IE);
        StepDone = 0;
        Xa = XTemp(end,:);
        for ev = 1:length(IE)
            
            % Is it a model event?
            ModEvID = find(IE(ev) == Sim.ModEv,1,'first');
            if ~isempty(ModEvID)
                
                [Sim.Mod,Xa(Sim.ModCo)] = ...
                    Sim.Mod.HandleEvent(ModEvID, XTemp(end,Sim.ModCo),TTemp(end));
                
                % Call controller for model events:
                [Sim.Con,Xa(Sim.ConCo)] =  ...
                    Sim.Con.HandleExtEvent(ModEvID, XTemp(end,:),TTemp(end));
                
                
            end

            % Is it a controller event?
            ConEvID = find(IE(ev) == Sim.ConEv,1,'first');
            if ~isempty(ConEvID)
                
                [Sim.Con,Xa(Sim.ConCo)] = ...
                    Sim.Con.HandleEvent(ConEvID, XTemp(end,Sim.ConCo),TTemp(end));
                              
                if ConEvID==1
                    StepDone = 1;
                    % check change in sign at stance phase:
                    ind_impact = find(cell2mat(Sim.Out.EventsVec.Type)==1,1,'last');
                   
                    if ~isempty(ind_impact)
                    theta_at_impact = Sim.Out.EventsVec.State{ind_impact}(1);
                    theta_at_end_phse = Xa(1);

                    sign_change = sign(theta_at_impact*theta_at_end_phse);
                        if sign_change>0  %no sign change:
                             Sim.Out.Type = Sim.EndFlag_NoSignChange;
                             Sim.Out.Text = 'No sign change in stance phase';
                             Sim.StopSim = 1;
                        end

                    end
                
                end
                
                
                                
                if Sim.Con.Linear_motor_in
                    Sim.Con.Linear_motor_in = 0;
                    Sim.Mod.LinearMotor = 'in';
                    Sim.Mod.Phase = 'swing';
                end
                
                if Sim.Con.Linear_motor_out
                    Sim.Con.Linear_motor_out = 0;
                    Sim.Mod.LinearMotor = 'out';
                end

            end
            
        end
       
        Sim.newIC = Xa;
        
        if StepDone
            Sim.ICstore(:,2:end) = Sim.ICstore(:,1:end-1);
            Sim.ICstore(:,1) = Sim.newIC';
            Sim.StepsTaken = Sim.StepsTaken+1;
            if ~Sim.Graphics
            disp(['steps: ' num2str(Sim.StepsTaken)])
            end
            Sim = Sim.CheckConvergence();
            Sim.Out.PoincareSection(:,Sim.StepsTaken) = Sim.newIC';
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
            ode45(@Sim.Derivative,tspan,Sim.newIC,options); 
        
        if Sim.infTime == 1
            TimeCond = true;
            Sim.tend = Sim.tend + TTemp(end)-tspan(1);
        else
            TimeCond = TTemp(end)<Sim.tend;
        end
        
        % Save state and time
        X = [X; XTemp]; %#ok<AGROW>
        Sim.Out.T = [Sim.Out.T; TTemp];

    end
    
    %for not stable IC:
    if (Sim.EndCond(1) == 2) && (TTemp(end)>=Sim.tend-Sim.tstep) && ~norm(Sim.stepsSS) 
        Sim.StopSim = 1;
        set(Sim.StopButtonObj,'String','Close Window');
        Sim.Out.Type = Sim.EndFlag_TimeEndedBeforeConverge;
        Sim.Out.Text = 'Reached end of tspan before system converged.';
        Sim.IClimCyc = Sim.newIC';
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

