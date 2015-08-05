                  
function [] = PoincareMapPlot(x_range,y_range,z_range,CM)

figure(123)
hold on   

for i = 1:length(CM(:))
    
    if CM(i)>0
        
        MarkerType = '+';
        MarkerColor = 'b';

    else
        
        MarkerType = 'x';
        MarkerColor = 'r';
        
    end
    
    [ix,iy,iz] = ind2sub(size(CM),i);
    P = PointFromCell([ix iy iz],x_range,y_range,z_range);
    scatter3(P(1),P(2),P(3),500,MarkerColor,MarkerType,'LineWidth',3)   
    
end

scatter3(0,0,0,500,'g','o','LineWidth',3)

axis([x_range(1) x_range(end) y_range(1) y_range(end) z_range(1) z_range(end)])
xlabel x
ylabel y
zlabel z
grid on

set(gca,'XTick',x_range, 'YTick',y_range ,'ZTick',z_range)