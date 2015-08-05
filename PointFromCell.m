function x = PointFromCell(cell,x_range,y_range,z_range)
x = ([x_range(cell(1)),y_range(cell(2)),z_range(cell(3))]+[x_range(cell(1)+1),y_range(cell(2)+1),z_range(cell(3)+1)])/2;
end