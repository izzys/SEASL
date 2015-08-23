function CM = CellMap2D(Sim,x_range,y_range,map_fun)
nX = length(x_range);
nY = length(y_range);
CM = -1*ones(nX-1,nY-1);
%%
ind0 = GetCell2D([Sim.IClimCyc(2);Sim.IClimCyc(5)],x_range,y_range);
CM(ind0(1),ind0(2)) = 1;

       % ic = PointFromCell([ind0(1),ind0(2)],x_range,y_range)



% -1 - not assigned 
% 1 - converge
% 0 - diverge

    date_and_hour = datestr(now);
    Hour = hour(date_and_hour);
    Minute = minute(date_and_hour);
    Seconds = second(date_and_hour);
    
%%%%%%%%%%   test %%%%%%%%%%%%%%
% ll = length(CM);
% CM(:,:,1) = spiral(5);    
% CM(:,:,2) = spiral(5)+ll^2;     
% CM(:,:,3) = spiral(5)+2*ll^2;      
% CM(:,:,4) = spiral(5)+3*ll^2; 
% CM(:,:,5) = spiral(5)+4*ll^2; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[sizeCMx , sizeCMy  ]= size(CM);
if sizeCMx == sizeCMy && ~isodd(sizeCMx-1)
    
    temp = spiral(sizeCMx) ;   
    [~, xy_ind] = sort(temp(:));

    SpiralInd = xy_ind';
else 
    if ~isodd(sizeCMx)
        disp('CM has not-even dimentions. aborting spiral mapping')
    end

    if sizeCMx ~= sizeCMy
        disp('CM x and y dimentions are not equal. aborting spiral mapping')
    end
    
    SpiralInd = 1:length(CM(:));
end

for i = SpiralInd
    i
    if CM(i) ~= -1
        continue
    else
        ind = [i];
        stop = 0;
        [xx,yy] = ind2sub(size(CM),ind(end));
        ic = PointFromCell([xx,yy],x_range,y_range)
        while ~stop
            ic = map_fun(ic)
            cur_cell = GetCell2D(ic,x_range,y_range);
                if ~isnan(cur_cell)
                    cur_ind = sub2ind(size(CM),cur_cell(1),cur_cell(2));
                    ind = [ind,cur_ind]
                    if CM(cur_ind) ~= -1
                        CM(ind) = CM(cur_ind);
                        stop = 1;
                    end
                           
                else
                    CM(ind) = 0;
                    stop = 1;
                            
                end
                
                
                
        end
        disp([num2str(sum(CM(:)~=-1)),' out of ',num2str((nX-1)*(nY-1))]);
    

    save(['CM__' datestr(now,'dd-mmm-yyyy') '_'  num2str(Hour) '_' num2str(Minute) '_' num2str(Seconds) ],'CM')

        
    end
        
end

end
       
            
          
                
    