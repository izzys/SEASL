clc;clear all;close all;clear classes;
set(0,'DefaultFigureWindowStyle','normal')




Tend = 0.5;
T = 1.35; %starting T
Tlast = T;
LC =  [   0.359391210428063  -5.158800155979966  24.864400260045976   4.346289131413131   0.717706102022023];
phi_short = [];
phi_extend = [];
phi_tau = [0.1 0.25 0.4 0.99];
tau = [2 -3];
devide =2;
i = 1;
increment = -0.01;

    date_and_hour = datestr(now);
    Hour = hour(date_and_hour);
    Minute = minute(date_and_hour);
    Seconds = second(date_and_hour);


while T>=Tend

Sim = Simulation();
Sim.Graphics = 1;
%1: number of steps, 2: covergance
% set terrain:
Sim.Env.DisturbanceMaxHeight = 0.00;
Sim.Env.DisturbanceSign = -1;
Sim.Env.start_x = 5;
Sim.Env.end_x = 7;

Sim.EndCond = 2;
Sim = Sim.SetTime(0,0.01,100);
Sim.minDiff = 1e-9;

% Set up the model:
Sim.Mod = Sim.Mod.Set('Phase','stance','LinearMotor','out');


 % REFLEX:
 Sim.Con = Sim.Con.Set('Period',T,'phi_tau',phi_tau,'tau',tau,...
                        'phi_reflex',[NaN NaN]); 
       
Sim.Con.Controller_Type = 'CPG';%'sin';%
Sim.Con.PhaseReset = 0;
Sim.Con.PhaseShift = 0;

Sim.IClimCyc =  LC;

Sim.Con.IC = Sim.IClimCyc(5); % LC
Sim.Con.Init();

% note that if IC match the stance phase - only the first two IC count:

Sim.Mod.IC =   Sim.IClimCyc(1:4); % LC

Sim = Sim.Init();

% Simulate:

Sim.DebugMode = 0;
Sim.IgnoreErrors = 1;
Sim = Sim.Run();

    if Sim.Out.Type == Sim.EndFlag_Converged
        
    Sim = Sim.SetTime(0,0.05,100);
    Sim.Mod = Sim.Mod.Set('Phase','stance','LinearMotor','out');
    Sim.Con.IC = Sim.IClimCyc(5); % LC
    Sim.Con.Init();
    Sim.Mod.IC =   Sim.IClimCyc(1:4); % LC
    Sim = Sim.Init();
    Sim = Sim.Run();

    Sim.PMeps = 5e-7;
    [EigVal1,EigVec1] = Sim.Poincare();

    %get output stuff:
    v = (Sim.Out.X(end,3)-Sim.Out.X(1,3))/Sim.Out.T(end);
    ind2 =  find( cell2mat(Sim.Out.EventsVec.Type)==2 ,1,'last' );
    ind3 =  find( cell2mat(Sim.Out.EventsVec.Type)==3 ,1,'last' );
 
    LC = Sim.IClimCyc;
    phi_short = Sim.Out.EventsVec.Xa{ind2}(5);
    phi_extend = Sim.Out.EventsVec.Xa{ind3}(5);

    EIG.ReflexEigVal{i} = EigVal1;
    EIG.ReflexEigVec{i} = EigVec1;
    EIG.LC{i} = LC;
    EIG.phi_reflex{i} = [ phi_short phi_extend ];
    EIG.velocity{i} = v;
    EIG.T{i} = T;
    EIG.Period{i} = Sim.Period(1);
    
    
    EigVal1
    period = Sim.Period(1)
    % NO REFLEX:
     Sim.Con = Sim.Con.Set('Period',T,'phi_tau',phi_tau,'tau',tau,...
                            'phi_reflex',[ phi_short phi_extend ]); 
    [EigVal2,EigVec2] = Sim.Poincare();

    EigVal2
    EIG.NoReflexEigVal{i} = EigVal2;
    EIG.NoReflexEigVec{i} = EigVec2;

    %advance:
    Tlast = T;
    T = T+increment
    i = i+1
    

        save(['EIG__' datestr(now,'dd-mmm-yyyy') '_'  num2str(Hour) '_' num2str(Minute) '_' num2str(Seconds) ],'EIG')

    else %T incremented to much:
    disp('reducing increment')
    increment = increment/devide
    T = Tlast+increment

    end

end
disp('done EIG')
t = cell2mat(EIG.T);
E1 = cell2mat(EIG.NoReflexEigVal);
E2 = cell2mat(EIG.ReflexEigVal);
figure
plot(t,E1(1,:),t,E1(2,:))
figure
plot(t,abs(E2(1,:)),t,abs(E2(2,:)))