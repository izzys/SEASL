function CM = MapMatrix(Sim,x_range,y_range,z_range,map_fun)
nX = length(x_range);
nY = length(y_range);
nZ = length(z_range);
CM = -1*ones(nX-1,nY-1,nZ-1);
%%
ind0 = GetCell([Sim.IClimCyc(1);Sim.IClimCyc(2);Sim.IClimCyc(4)],x_range,y_range,z_range);
CM(ind0(1),ind0(2),ind0(3)) = 1;
% -1 - not assigned 
% 1 - converge
% 0 - diverge

    date_and_hour = datestr(now);
    Hour = hour(date_and_hour);
    Minute = minute(date_and_hour);
    Seconds = second(date_and_hour);
    
    
for i = 1:length(CM(:))
    
        [xx,yy,zz] = ind2sub(size(CM),ind(end));
        ic = PointFromCell([xx,yy,zz],x_range,y_range,z_range)'
        ic = map_fun(ic)
        
        cur_cell = GetCell(ic,x_range,y_range,z_range);

        disp([num2str(sum(CM(:)~=-1)),' out of ',num2str((nX-1)*(nY-1)*(nZ-1))]);
    

        save(['CM__' datestr(now,'dd-mmm-yyyy') '_'  num2str(Hour) '_' num2str(Minute) '_' num2str(Seconds) ],'CM')

        

        
end

       
            
          
                
    