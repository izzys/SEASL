                  
function [] = PoincareMapPlot2D(Sim,x_range,y_range,CM)

figure(123)
hold on   

for i = 1:length(CM(:))
    
    if CM(i)==1
        MarkerSize = 25;
        MarkerType = '+';
        MarkerColor = 'b';
        
        [ix,iy,iz] = ind2sub(size(CM),i);
        P = PointFromCell([ix iy],x_range,y_range);
        scatter(P(1),P(2),MarkerSize,MarkerColor,MarkerType,'LineWidth',1)   

    elseif CM(i)==0
        MarkerSize = 8;
        MarkerType = '.';
        MarkerColor = 'r';
        
        [ix,iy,iz] = ind2sub(size(CM),i);
        P = PointFromCell([ix iy],x_range,y_range);
        scatter(P(1),P(2),MarkerSize,MarkerColor,MarkerType,'LineWidth',1)   
    end

end

scatter(Sim.IClimCyc(2),Sim.IClimCyc(5),50,'g','o','LineWidth',3)

axis([x_range(1) x_range(end) y_range(1) y_range(end)])
xlabel x
ylabel y
grid on

set(gca,'XTick',x_range, 'YTick',y_range )