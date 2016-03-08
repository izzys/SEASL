function x = PointFromCell(cell,x_range,y_range,z_range)

switch nargin 
    
    case 4 %3D
        
        x = ([x_range(cell(1)),y_range(cell(2)),z_range(cell(3))]+[x_range(cell(1)+1),y_range(cell(2)+1),z_range(cell(3)+1)])/2;

    case 3 %2D
        
        
       x = ([x_range(cell(1)),y_range(cell(2))]+[x_range(cell(1)+1),y_range(cell(2)+1)])/2; 
       
    case 2 %1D
        
      x = (x_range(cell)+x_range(cell+1))/2; 
       
    otherwise
        error('Error: input aguments must be [x,y] or [x,y,z]')
end

end