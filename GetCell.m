function ind = GetCell(x,x_range,y_range,z_range)
    if ~(x(1) > x_range(end) || x(2) > y_range(end) || x(3) > z_range(end) || x(1) < x_range(1) || x(2) < y_range(1) || x(3) < z_range(1))
        ind = [find(x_range<x(1),1,'last'),find(y_range<x(2),1,'last'),find(z_range<x(3),1,'last')];
    else
        ind = NaN;
    end
end