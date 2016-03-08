function []= plot_out(Sim)

set(0, 'DefaultFigurePaperType', 'a4letter', ...
 'DefaultAxesFontSize', 10, ...
'DefaultAxesFontName', 'TimesNewRoman', ...
'DefaultAxesGridLineStyle', '-', ...
'DefaultAxesLayer', 'Bottom', ...
'DefaultAxesUnits', 'normalized', ...
'DefaultAxesXcolor', [0, 0, 0], ...
'DefaultAxesYcolor', [0, 0, 0], ...
'DefaultAxesZcolor', [0, 0, 0], ...
'DefaultAxesVisible', 'on', ...
'DefaultLineLineStyle', '-', ...
'DefaultLineLineWidth', 1, ...
'DefaultLineMarker', 'none', ...
'DefaultLineMarkerSize', 5, ...
'DefaultTextColor', [0, 0, 0], ...
'DefaultTextFontUnits', 'Points', ...
'DefaultTextFontSize', 10, ...
'DefaultTextFontName', 'TimesNewRoman', ...
'DefaultTextVerticalAlignment', 'middle', ...
'DefaultTextHorizontalAlignment', 'left');


theta = Sim.Out.X(:,1);
dtheta = Sim.Out.X(:,2);
x = Sim.Out.X(:,3);
dx = Sim.Out.X(:,4);
t = Sim.Out.T;

hip_u = Sim.Out.Hip_u;
ankle_u = Sim.Out.Ankle_u;
u_time = Sim.Out.Control_time;

phase = Sim.Out.X(:,5);

zmp1 = Sim.Out.ZMPval1;
zmp2 = Sim.Out.ZMPval2;
zmp_time = Sim.Out.ZMPtime_stamp;

if ~isempty(Sim.Out.EventsVec)
    
EventsTime = cell2mat(Sim.Out.EventsVec.Time);
EventsX = cell2mat(Sim.Out.EventsVec.State);
EventsX = vec2mat(EventsX,Sim.stDim);

Xa = cell2mat(Sim.Out.EventsVec.Xa);
Xa = vec2mat(Xa,Sim.stDim);


ind_event1 = find(cell2mat(Sim.Out.EventsVec.Type)==1);
Event1_time = EventsTime(ind_event1);
Event1_state = EventsX(ind_event1,:);
Event1_sym = 'og';
if ~isempty(ind_event1)
    Legend1 = 'Event1 - foot hits floor';
else
    Legend1 = '';
end

ind_event2 = find(cell2mat(Sim.Out.EventsVec.Type)==2);
Event2_time = EventsTime(ind_event2);
Event2_state = EventsX(ind_event2,:);
Event2_sym = 'xr';
if ~isempty(ind_event2)
    Legend2 = 'Event2 - hip hits switch';
else
    Legend2 = '';
end

ind_event3 = find(cell2mat(Sim.Out.EventsVec.Type)==3);
Event3_time = EventsTime(ind_event3);
Event3_state = EventsX(ind_event3,:);
Event3_sym = 'vk';
if ~isempty(ind_event3)
    Legend3 = 'Event3 -  max height';
else
    Legend3 = '';
end

ind_event4 = find(cell2mat(Sim.Out.EventsVec.Type)==4);
Event4_time = EventsTime(ind_event4);
Event4_state = EventsX(ind_event4,:);
Event4_sym = '*b';
if ~isempty(ind_event4)
    Legend4 = 'Event4 - nominal LC';
else
    Legend4 ='';
end


ind_event5 = find(cell2mat(Sim.Out.EventsVec.Type)==5);
Event5_time = EventsTime(ind_event5);
Event5_state = EventsX(ind_event5,:);
Event5_sym = 'hk';
if ~isempty(ind_event5)
    Legend5 = 'Event5 - end of phase';
else
    Legend5 ='';
end


color = [rand(1) rand(1) rand(1)];


figure(121)

subplot 321
hold on

ylabel('\theta')
plot(Event1_time,Event1_state(:,1),Event1_sym)
plot(Event2_time,Event2_state(:,1),Event2_sym)
plot(Event3_time,Event3_state(:,1),Event3_sym)
plot(Event4_time,Event4_state(:,1),Event4_sym)
plot(Event5_time,Event5_state(:,1),Event5_sym)

if ~isempty(ind_event2)
legend(Legend1,Legend2,Legend3,Legend4,Legend5)
else
    legend(Legend1,Legend3,Legend4,Legend5)
end
plot(t,theta,'Color',color)

subplot 322
hold on
plot(t,x,'Color',color)
ylabel('x , zmp')
plot(zmp_time,zmp1,'.m')
plot(zmp_time,zmp2,'.c')
plot(zmp_time,ones(1,length(zmp_time))*Sim.Mod.foot_length/2 ,'xr')
legend('x','zmp1','zmp2','foot length')
plot(zmp_time,-ones(1,length(zmp_time))*Sim.Mod.foot_length/2 ,'xr')
plot(Event1_time,Event1_state(:,3),Event1_sym)
plot(Event2_time,Event2_state(:,3),Event2_sym)
plot(Event3_time,Event3_state(:,3),Event3_sym)
plot(Event4_time,Event4_state(:,3),Event4_sym)
plot(Event5_time,Event5_state(:,3),Event5_sym)

subplot 323
hold on
plot(t,dtheta,'Color',color)
plot(Event1_time,Event1_state(:,2),Event1_sym)
plot(Event2_time,Event2_state(:,2),Event2_sym)
plot(Event3_time,Event3_state(:,2),Event3_sym)
plot(Event4_time,Event4_state(:,2),Event4_sym)
plot(Event5_time,Event5_state(:,2),Event5_sym)

ylabel('\theta dot')

subplot 324
hold on
plot(Event1_time,Event1_state(:,4),Event1_sym)
plot(Event2_time,Event2_state(:,4),Event2_sym)
plot(Event3_time,Event3_state(:,4),Event3_sym)
plot(Event4_time,Event4_state(:,4),Event4_sym)
plot(Event5_time,Event5_state(:,4),Event5_sym)

plot(t,dx,'Color',color)
ylabel('x dot')

subplot 325
stairs(u_time,hip_u,'Color',color)
hold on
plot(t,phase,'--','Color',[0.7 0.7 0.7])
ylabel('u hip')
xlabel('Time [sec]')
plot(Event1_time,Event1_state(:,5),Event1_sym)
plot(Event2_time,Event2_state(:,5),Event2_sym)
plot(Event3_time,Event3_state(:,5),Event3_sym)
plot(Event4_time,Event4_state(:,5),Event4_sym)
plot(Event5_time,Event5_state(:,5),Event5_sym)
subplot 326
hold on
plot(u_time,ankle_u,'Color',color)
ylabel('u ankle')
xlabel('Time [sec]')
plot(t,phase,'--','Color',[0.7 0.7 0.7])


figure(122)

subplot 121
hold on
title('d\theta-\phi Phase plane ')
plot(Event1_state(:,2),Event1_state(:,5),Event1_sym)
plot(Event2_state(:,2),Event2_state(:,5),Event2_sym)
plot(Event3_state(:,2),Event3_state(:,5),Event3_sym)
plot(Event4_state(:,2),Event4_state(:,5),Event4_sym)
plot(Event5_state(:,2),Event5_state(:,5),Event5_sym)

if ~isempty(ind_event2)
legend(Legend1,Legend2,Legend3,Legend4,Legend5)
else
    legend(Legend1,Legend3,Legend4,Legend5)
end
plot(dtheta,phase,'Color',color)
xlabel('d\theta')
ylabel('\phi')




subplot 122

hold on
title('\theta-d\theta Phase plane ')
plot(Event1_state(:,1),Event1_state(:,2),Event1_sym)
plot(Event2_state(:,1),Event2_state(:,2),Event2_sym)
plot(Event3_state(:,1),Event3_state(:,2),Event3_sym)
plot(Event4_state(:,1),Event4_state(:,2),Event4_sym)
plot(Event5_state(:,1),Event5_state(:,2),Event5_sym)

if ~isempty(ind_event2)
legend(Legend1,Legend2,Legend3,Legend4)
else
    legend(Legend1,Legend3,Legend4)
end
plot(theta,dtheta,'Color',color)
xlabel('\theta')
ylabel('d\theta')



figure(127)
hold on
title('\theta - d\theta-\phi Phase plane ')
plot3(Event1_state(:,1),Event1_state(:,2),Event1_state(:,5),Event1_sym)
plot3(Event2_state(:,1),Event2_state(:,2),Event2_state(:,5),Event2_sym)
plot3(Event3_state(:,1),Event3_state(:,2),Event3_state(:,5),Event3_sym)
plot3(Event4_state(:,1),Event4_state(:,2),Event4_state(:,5),Event4_sym)
plot3(Event5_state(:,1),Event5_state(:,2),Event5_state(:,5),Event5_sym)

if ~isempty(ind_event2)
legend(Legend1,Legend2,Legend3,Legend4,Legend5)
else
    legend(Legend1,Legend3,Legend4,Legend5)
end
plot3(theta,dtheta,phase,'Color',color)
xlabel('\theta')
ylabel('d\theta')
zlabel('\phi')


figure(1)
hold on
Poincare_sym = '--hb';
Poincare_state = Xa(ind_event1,:);
%plot([ dtheta(1) ],[phase(1) ],Poincare_sym,'MarkerSize',10,'LineWidth',2)
plot([dtheta(1)  ; Poincare_state(:,2)],[ phase(1) ; Poincare_state(:,5)],Poincare_sym,'MarkerSize',10,'LineWidth',2)
drawnow

disp 'avarage speed:'
v = (Sim.Out.X(end,3)-Sim.Out.X(1,3))/Sim.Out.T(end)
%v2 = mean(Sim.Out.X(:,4))

 ind2 =  find( cell2mat(Sim.Out.EventsVec.Type)==2 ,1,'last' );
 ind3 =  find( cell2mat(Sim.Out.EventsVec.Type)==3 ,1,'last' );
 
 LC = Sim.IClimCyc
 phi_short = Sim.Out.EventsVec.Xa{ind2}(5)
  phi_extend = Sim.Out.EventsVec.Xa{ind3}(5)
end