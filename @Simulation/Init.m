function [ Sim ] = Init( Sim )
% Initialize simulation properties
    % Set states
    Sim.stDim = Sim.Mod.stDim + Sim.Con.stDim; % state dimension
    Sim.ModCo = 1:Sim.Mod.stDim; % Model coord. indices
    Sim.ConCo = Sim.Mod.stDim+1:Sim.stDim; % Contr. coord. indices

    % Set events
    Sim.nEvents = Sim.Mod.nEvents + Sim.Con.nEvents;
    Sim.ModEv = 1:Sim.Mod.nEvents; % Model events indices
    Sim.ConEv = Sim.Mod.nEvents+1:Sim.nEvents; % Contr. events indices
    
    
    % Set linear motor - in/out:
    if Sim.Mod.IC(2)<=0 && Sim.Mod.IC(1)>0 
        Sim.Mod.LinearMotor = 'out';
    end
    if Sim.Mod.IC(2)>0 && Sim.Mod.IC(1)>=0
        Sim.Mod.LinearMotor = 'in';
    end

    
    % Check Sim IC:

    if strcmp(Sim.Mod.Phase,'stance') && strcmp(Sim.Mod.LinearMotor,'in') 
        error('Error: contradicting starting position. Cannot be in start phase: stance, and linear motor: in')
    end
    

    % check here if IC are ok !! 

    [ ~, y_hip ] = GetPos(Sim.Mod, Sim.Mod.IC, 'hip');
    if y_hip<(2*Sim.Mod.cart_wheel_radius + Sim.Mod.cart_height - Sim.Mod.cart_width/2)
        error('Error: wrong IC , hip too low')
    end
    [ ~, y_ankle ] = GetPos(Sim.Mod, Sim.Mod.IC, 'ankle');
    if y_ankle<Sim.Mod.ankle_radius
        error('Error: wrong IC , foot penetrates ground')
    end    

    % init model:

    if strcmp(Sim.Mod.LinearMotor , 'out')
    	Sim.Mod.leg_length = Sim.Mod.Leg_params.stance_length;
    elseif strcmp(Sim.Mod.LinearMotor , 'in')
        Sim.Mod.leg_length = Sim.Mod.Leg_params.swing_length;
    else
        error('Error: linear motor not initialized')
    end
    
    if strcmp(Sim.Mod.Phase,'stance')
        theta = Sim.Mod.IC(1);  
        x_cart = Sim.Mod.IC(3);
        l = Sim.Mod.Leg_params.stance_length;

        Sim.Mod.x0 = x_cart+l*sin(theta);
    end
    
    if strcmp(Sim.Con.Controller_Type,'Hopf_adaptive') && Sim.Con.NumOfNeurons>1
        Sim.Con.IC = repmat(Sim.Con.IC,Sim.Con.NumOfNeurons,1);
    end
    
    Sim.IC = [Sim.Mod.IC ; Sim.Con.IC];
    Sim.StopSim = 0;
    Sim.PauseSim = 0; 
    
    % Set render params
    if Sim.Graphics == 1
        if Sim.Fig == 0
            Sim.Once = 1;
        end
        
        % Init window size params
        scrsz = get(0, 'ScreenSize');
        if scrsz(3)>2*scrsz(4) % isunix()
            % If 2 screens are used in Linux
            scrsz(3) = scrsz(3)/2;
        end
        Sim.FigWidth = scrsz(3)-500;
        Sim.FigHeight = scrsz(4)-350;
        Sim.AR = Sim.FigWidth/Sim.FigHeight;
        if isempty(Sim.IC)
            [Sim.COMx0,Sim.COMy0] = Sim.Mod.GetPos(zeros(1,Sim.Mod.stDim),'COM');
        else
            [Sim.COMx0,Sim.COMy0] = Sim.Mod.GetPos(Sim.IC(Sim.ModCo),'COM');
        end
        
        % Init world size params
        Sim.FlMin = Sim.COMx0-1.5*Sim.AR*Sim.Mod.cart_length;
        Sim.FlMax = Sim.COMx0+1.5*Sim.AR*Sim.Mod.cart_length;
        Sim.HeightMin = Sim.COMy0-4/Sim.AR*Sim.Mod.cart_height;
        Sim.HeightMax = Sim.COMy0+4/Sim.AR*Sim.Mod.cart_height;

    end
   
    Sim.Mod.Hip_Torque = 0;
    Sim.Mod.Ankle_Torque = 0; 
    
    % counters:
    Sim.stance_counter = 0;
    Sim.StepsTaken = 0;
    
    % init stats:
    Sim.ICstore = zeros(Sim.stDim, Sim.nICsStored);
    Sim.stepsSS = zeros(1,Sim.nICsStored-1);
    
    % Init Sim.End result
    Sim.Out.Hip_u = [];
    Sim.Out.Ankle_u = [];   
    Sim.Out.PoincareSection = [];
    Sim.Out.Control_time = [];
    Sim.Out.Type = Sim.EndFlag_EndOfTime;
    Sim.Out.Text = 'Reached end of tspan';
    Sim.Out.ZMPtime_stamp = [];
    Sim.Out.ZMPval1 = [];
    Sim.Out.ZMPval2 = [];
end

