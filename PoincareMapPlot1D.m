                  
function [] = PoincareMapPlot1D(Sim,x_range,PM)
   

% subplot(2,3,[1 2 3])
ind = find(~isnan(PM.ICnext));

x = PM.IC(ind);
y = PM.ICnext(ind);

t = x(1):0.1:x(end);

plot(x,y,'.')
hold on
plot(t,t,'--')

%plot(Sim.IClimCyc(2),Sim.IClimCyc(2),'kh','MarkerSize',15)



xlabel(' \theta dot k')
ylabel(' \theta dot k+1')

% subplot(2,3,6)

% plot(x,y,'.')
% hold on
% plot(t,t,'--')

%plot(Sim.IClimCyc(2),Sim.IClimCyc(2),'kh','MarkerSize',15)


xlabel(' \theta dot k')
ylabel(' \theta dot k+1')