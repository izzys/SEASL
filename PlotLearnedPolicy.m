function [ ] = PlotLearnedPolicy( PendLearn )

J= PendLearn.J;
grad = PendLearn.grad;
theta = PendLearn.theta;
SYS = PendLearn.SYS;

figure(3)
hold on

for i = 1:length(J)
    
    u = theta(i+1,1)-theta(i,1);
    v = theta(i+1,2)-theta(i,2);

    quiver(theta(i,1),theta(i,2),u,v,1)
    text(theta(i,1),theta(i,2),['J = ' num2str(J(i)) ])
    
    
end

end

