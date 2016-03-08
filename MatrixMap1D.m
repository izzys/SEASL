function [PM] = MatrixMap1D(Sim,x_range,map_fun)
nX = length(x_range);
% -1 - not assigned 
PM.CM = -1*ones((nX-1),1);
PM.IC = -1*ones((nX-1),1);
PM.ICnext = -1*ones((nX-1),1);
%%

date_and_hour = datestr(now);
Hour = hour(date_and_hour);
Minute = minute(date_and_hour);
Seconds = second(date_and_hour);
    
for i = 1:length(PM.CM(:))
i
    if PM.CM(i) ~= -1
        continue
    else

        ic = PointFromCell(i,x_range)
        ic_next = map_fun([ ic Sim.IClimCyc(5) ])
        
     %   cur_cell = GetCell2D(ic,x_range,y_range);
        
        PM.IC(i) = ic;
        PM.ICnext(i)  = ic_next(1);
        
        if sum(isnan(ic_next))
             PM.CM(i) = 0;
        else
             PM.CM(i) = 1;  
        end
        
        disp([num2str(sum(PM.CM~=-1)),' out of ',num2str(nX-1)]);
    

        save(['PM__' datestr(now,'dd-mmm-yyyy') '_'  num2str(Hour) '_' num2str(Minute) '_' num2str(Seconds) ],'PM')

        
    end
        
end

end
       
            
          
                
    