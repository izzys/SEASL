                  
function [] = PoincareMapPlot2D(Sim,x_range,y_range,CM,roa_est)
        figure
        

        
        ind0 = GetCell2D([Sim.IClimCyc(2);Sim.IClimCyc(5)],x_range,y_range);
        CM.Bin(ind0(1),ind0(2)) = -1;
        CM.OutType(ind0(1),ind0(2)) = -1;
%figure(123)
%hold on   

         
     %  clims = [ -1 1]; 
        
%         imagesc(x_range,y_range,CM.Bin')
%         set(gca,'Ydir','normal')
%         hold on 
%          grid on
%    %      colormap summer
%    colormap(gray)
%          axis([x_range(1) x_range(end) y_range(1) y_range(end)])
%         xlabel d\theta
%         ylabel \phi
        
    
       
        imagesc(x_range,y_range,CM.OutType',[-10 0])
           colormap summer
        set(gca,'Ydir','normal')
         hold on 
       %  grid on
         %colormap spring colormap(gray)
         axis([x_range(1) 0 0 1])
        xlabel d\theta
        ylabel \phi

%  for i = 1:length(CM.Bin(:))
% %     
%      if CM.Bin(i)==1
%         MarkerSize = 25;
%         MarkerType = '+';
%         MarkerColor = 'g';
%         
%        [ix,iy] = ind2sub(size(CM.Bin),i);
%        P = PointFromCell([ix iy],x_range,y_range);
%        scatter(P(1),P(2),MarkerSize,MarkerColor,MarkerType,'LineWidth',1)   
% 
%     end
% end
%     elseif CM.Bin(i)==0
%         MarkerSize = 8;CM

%         MarkerType = '.';
%         MarkerColor = 'r';
%         
%         [ix,iy] = ind2sub(size(CM.Bin),i);
%         P = PointFromCell([ix iy],x_range,y_range);
%         scatter(P(1),P(2),MarkerSize,MarkerColor,MarkerType,'LineWidth',1)   
%     end
% 
% end

scatter(Sim.IClimCyc(2),Sim.IClimCyc(5),50,'k','h','LineWidth',3)


%grid on

%set(gca,'XTick',x_range, 'YTick',y_range )

% if ~isempty(roa_est)
% 
%     hold on   
%     pvar x1 x2
%     Vd = subs(roa_est.V,[x1 x2]',[x1-Sim.IClimCyc(2)   x2-Sim.IClimCyc(5) ]');
%     pcontour(Vd,roa_est.gamma,[x_range(1) x_range(end) y_range(1) y_range(end)]);
% 
% end

        
        