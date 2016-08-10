% %%%%%%%%%%%%No Rendering function %%%%%%%%%%%%
% Only get FloorX and Floor Y!!
function [Te,FloorX,FloorY]=NoRender(Te,Min,Max)
    FloorX=Min:Te.FloorStep:Max;
    FloorY=Te.Surf(FloorX);     
end