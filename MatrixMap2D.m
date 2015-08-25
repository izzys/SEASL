function [PM] = MatrixMap2D(Sim,x_range,y_range,map_fun)
nX = length(x_range);
nY = length(y_range);
% -1 - not assigned 
PM.CM = -1*ones((nX-1),(nY-1));
PM.IC = -1*ones((nY-1)*(nX-1),2);
PM.ICnext = -1*ones((nY-1)*(nX-1),2);
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

        [xx,yy] = ind2sub(size(PM.CM),i);
        ic = PointFromCell([xx,yy],x_range,y_range)
        ic_next = map_fun(ic)
        
        
     %   cur_cell = GetCell2D(ic,x_range,y_range);
        
        PM.IC(i,:) = ic;
        PM.ICnext(i,:)  = ic_next;
        
        if sum(isnan(ic_next))
             PM.CM(xx,yy) = 0;
        else
             PM.CM(xx,yy) = 1;  
        end
        
        disp([num2str(sum(PM.CM(:)~=-1)),' out of ',num2str((nX-1)*(nY-1))]);
    

        save(['PM__' datestr(now,'dd-mmm-yyyy') '_'  num2str(Hour) '_' num2str(Minute) '_' num2str(Seconds) ],'PM')

        
    end
        
end

end
       
            
          
                
    