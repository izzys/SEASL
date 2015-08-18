
function []= plot_out(Sim)

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
    Legend2 = 'Event2 - hip hits track';
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
Event4_sym = '*k';
if ~isempty(ind_event4)
    Legend4 = 'Event4 - new phase';
else
    Legend4 ='';
end

figure(121)

subplot 321
hold on

ylabel('\theta')
plot(Event1_time,Event1_state(:,1),Event1_sym)
plot(Event2_time,Event2_state(:,1),Event2_sym)
plot(Event3_time,Event3_state(:,1),Event3_sym)
plot(Event4_time,Event4_state(:,1),Event4_sym)

if ~isempty(ind_event2)
legend(Legend1,Legend2,Legend3,Legend4)
else
    legend(Legend1,Legend3,Legend4)
end
plot(t,theta)

subplot 322
hold on
plot(t,x)
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

subplot 323
hold on
plot(t,dtheta)
plot(Event1_time,Event1_state(:,2),Event1_sym)
plot(Event2_time,Event2_state(:,2),Event2_sym)
plot(Event3_time,Event3_state(:,2),Event3_sym)
plot(Event4_time,Event4_state(:,2),Event4_sym)
ylabel('\theta dot')

subplot 324
hold on
plot(Event1_time,Event1_state(:,4),Event1_sym)
plot(Event2_time,Event2_state(:,4),Event2_sym)
plot(Event3_time,Event3_state(:,4),Event3_sym)
plot(Event4_time,Event4_state(:,4),Event4_sym)
plot(t,dx)
ylabel('x dot')

subplot 325
stairs(u_time,hip_u)
hold on
plot(t,phase,'--','Color',[0.7 0.7 0.7])
ylabel('u hip')
xlabel('Time [sec]')
subplot 326
hold on
plot(u_time,ankle_u)
ylabel('u ankle')
xlabel('Time [sec]')
plot(t,phase,'--','Color',[0.7 0.7 0.7])
figure(122)
hold on
title('\theta-d\theta Phase plane ')
plot(Event1_state(:,1),Event1_state(:,2),Event1_sym)
plot(Event2_state(:,1),Event2_state(:,2),Event2_sym)
plot(Event3_state(:,1),Event3_state(:,2),Event3_sym)
plot(Event4_state(:,1),Event4_state(:,2),Event4_sym)

if ~isempty(ind_event2)
legend(Legend1,Legend2,Legend3,Legend4)
else
    legend(Legend1,Legend3,Legend4)
end
color = [rand(1) rand(1) rand(1)];
plot(theta,dtheta,'color',color)
xlabel('\theta')

ylabel('d\theta')

end

