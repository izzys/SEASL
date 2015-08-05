function CM = CellMap(Sim,x_range,y_range,z_range,map_fun)
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
for i = 1:length(CM(:))
    
    if CM(i) ~= -1
        continue
    else
        ind = [i];
        stop = 0;
        [xx,yy,zz] = ind2sub(size(CM),ind(end));
        ic = PointFromCell([xx,yy,zz],x_range,y_range,z_range)';
        while ~stop
            ic = map_fun(ic);
            cur_cell = GetCell(ic,x_range,y_range,z_range);
                if ~isnan(cur_cell)
                    cur_ind = sub2ind(size(CM),cur_cell(1),cur_cell(2),cur_cell(3));
                    ind = [ind,cur_ind]; 
                    if CM(cur_ind) ~= -1
                        CM(ind) = CM(cur_ind);
                        stop = 1;
                    end
                           
                else
                    CM(ind) = 0;
                    stop = 1;
                            
                end
                
                
                
        end
        disp([num2str(sum(CM(:)~=-1)),' out of ',num2str((nX-1)*(nY-1)*(nZ-1))]);

    end
        
end

end
       
            
          
                
    