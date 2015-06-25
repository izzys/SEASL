% Render model:
function Mod = Render(Mod,X)

    [x_hip,y_hip] = Mod.GetPos(X,'hip');
    [x_ankle,y_ankle] = Mod.GetPos(X,'ankle');
    [x_cart,~] = Mod.GetPos(X,'cart');
    
    % set z values:
    z_hip = 4;
    z_ankle = 4;
    z_leg = 3;
    z_foot = 3;
    z_wheel = 2;
    z_cart = 1;
    z_track = 2;
    
    if isempty(Mod.RenderObj) % Model hasn't been rendered yet


        % Render hip axis:
        Mod.RenderObj.hip = DrawCircle(Mod, x_hip, y_hip, z_hip, Mod.hip_radius, Mod.hip_color, []);
        
        % Render ankle axis:
        Mod.RenderObj.ankle = DrawCircle(Mod, x_ankle, y_ankle, z_ankle, Mod.ankle_radius, Mod.ankle_color, []);
        
        % Render leg (upper link ???)
        Mod.RenderObj.leg = DrawLeg(Mod, x_ankle, y_ankle, x_hip, y_hip, z_leg, []);
        
        % Render foot 
        Mod.RenderObj.foot = DrawFoot(Mod, x_ankle, y_ankle, z_foot, []);     
        
        % Render cart
        x0 = x_cart;L = Mod.cart_length; H = Mod.cart_height; W = Mod.cart_width;r = Mod.cart_wheel_radius;l = Mod.cart_track_length;
        Mod.RenderObj.cart = DrawCart(Mod, 0,2*r+H/2, z_cart, []); 
        Mod.RenderObj.vertical_track = DrawTrack(Mod, 0, 2*r+H-W+l/2, z_track, []); 
        Mod.RenderObj.wheel1 = DrawCircle(Mod, x0+L/2-W/2, r, z_wheel, r, Mod.cart_wheel_color, []);  
        Mod.RenderObj.wheel2 = DrawCircle(Mod, x0-L/2+W/2, r, z_wheel, r, Mod.cart_wheel_color, []);  
        
        % Finished rendering, call function again to proceed with the code below:
        Mod = Render(Mod,X);
    else
        
        % Model was already rendered - Re-draw links
        DrawCircle(Mod, x_hip, y_hip, z_hip, Mod.hip_radius, Mod.hip_color, Mod.RenderObj.hip);
        DrawCircle(Mod, x_ankle, y_ankle, z_ankle, Mod.ankle_radius, Mod.ankle_color, Mod.RenderObj.ankle);
        DrawLeg(Mod, x_ankle, y_ankle, x_hip, y_hip, z_leg, Mod.RenderObj.leg);
        DrawFoot(Mod, x_ankle, y_ankle, z_foot, Mod.RenderObj.foot);
        x0 = x_cart;L = Mod.cart_length; H = Mod.cart_height; W = Mod.cart_width;r = Mod.cart_wheel_radius;l = Mod.cart_track_length;
        DrawCart(Mod, x0,0, z_cart, Mod.RenderObj.cart); 
        DrawTrack(Mod, x0,0, z_track, Mod.RenderObj.vertical_track);
        DrawCircle(Mod, x0+L/2-W/2, r, z_wheel, r, Mod.cart_wheel_color, Mod.RenderObj.wheel1);
        DrawCircle(Mod, x0-L/2+W/2, r, z_wheel, r, Mod.cart_wheel_color, Mod.RenderObj.wheel2);       
    end

    %         ~   Auxiliary nested functions ~      
    
    % Draw Circle:
    function [ res ] = DrawCircle(Mod, x, y, z, R, color,Obj)
        
        if isempty(Obj)
            
            coordX=zeros(1,Mod.CircRes);
            coordY=zeros(1,Mod.CircRes);
            coordZ=zeros(1,Mod.CircRes);

            for k=1:Mod.CircRes
                coordX(1,k)=R*cos(k/Mod.CircRes*2*pi);
                coordY(1,k)=R*sin(k/Mod.CircRes*2*pi);
                coordZ(1,k)=0;
            end

            res.Geom=patch(coordX,coordY,coordZ,color);
            set(res.Geom,'EdgeColor',color.^4);
            set(res.Geom,'LineWidth',2*Mod.LineWidth);
            
            res.Trans=hgtransform('Parent',gca);
            Txy=makehgtform('translate',[x y z]);
            
            set(res.Geom,'Parent',res.Trans);
            set(res.Trans,'Matrix',Txy);
            
        else

            Txy=makehgtform('translate',[x y z]);
            set(Obj.Trans,'Matrix',Txy); 
            
            res=1;          
        end
    end

    % Draw leg:
    % Draws the leg of from (x_ankle,y_ankle) to (x_hip,y_hip)
    function [ res ] = DrawLeg(Mod, x0, y0, x1, y1, z, Obj)
       
        if isempty(Obj)
            
            Length=sqrt((x1-x0)^2+(y1-y0)^2);
            Mod.Initial_leg_length = Length;
            Center=[(x0+x1)/2;
                    (y0+y1)/2];
            Orientation=atan2(y1-y0,x1-x0);

            res.Trans=hgtransform('Parent',gca);
            Txy=makehgtform('translate',[Center(1) Center(2) z]);
            Rz=makehgtform('zrotate',Orientation-pi/2);

            coordX=zeros(1,2*Mod.LinkRes+1);
            coordY=zeros(1,2*Mod.LinkRes+1);
            coordZ=zeros(1,2*Mod.LinkRes+1);

            x=0;
            y = Length/2-Mod.leg_width/2;
            
            for k=1:Mod.LinkRes
                coordX(1,k)=x+Mod.leg_width/2*cos(k/Mod.LinkRes*pi);
                coordY(1,k)=y+Mod.leg_width/2*sin(k/Mod.LinkRes*pi);
                coordZ(1,k)=0;
            end

            y = -Length/2+Mod.leg_width/2;
            
            for k=Mod.LinkRes:2*Mod.LinkRes
                coordX(1,k+1)=x+Mod.leg_width/2*cos(k/Mod.LinkRes*pi);
                coordY(1,k+1)=y+Mod.leg_width/2*sin(k/Mod.LinkRes*pi);
                coordZ(1,k+1)=0;
            end

            res.Geom=patch(coordX,coordY,coordZ,Mod.leg_color);
            set(res.Geom,'EdgeColor',[0 0 0]);
            set(res.Geom,'LineWidth',2*Mod.LineWidth);
            set(res.Geom,'Parent',res.Trans);
            set(res.Trans,'Matrix',Txy*Rz);
        else

            Center=[(x0+x1)/2;
                    (y0+y1)/2];
            Orientation=atan2(y1-y0,x1-x0);
            Length=sqrt((x1-x0)^2+(y1-y0)^2);

            Txy=makehgtform('translate',[Center(1) Center(2) z]);
            Rz=makehgtform('zrotate',Orientation-pi/2);
            Sx=makehgtform('scale',[1,Length/Mod.Initial_leg_length,1]);
            set(Obj.Trans,'Matrix',Txy*Rz*Sx);
            
            res=1;
        end
    end

    % Draw foot:
    % Draws the foot at (x_ankle,y_ankle) parallel to the ground
    function [ res ] = DrawFoot(Mod, x0, y0, z, Obj)
       
        if isempty(Obj)
            
            Length= Mod.foot_length;
            Center=[x0;y0];
            Orientation=0;

            res.Trans=hgtransform('Parent',gca);
            Txy=makehgtform('translate',[Center(1) Center(2) z]);
            Rz=makehgtform('zrotate',Orientation-pi/2);

            coordX=zeros(1,2*Mod.LinkRes+1);
            coordY=zeros(1,2*Mod.LinkRes+1);
            coordZ=zeros(1,2*Mod.LinkRes+1);

            x=0;
            y = Length/2-Mod.foot_width/2;
            
            for k=1:Mod.LinkRes
                coordX(1,k)=x+Mod.foot_width/2*cos(k/Mod.LinkRes*pi);
                coordY(1,k)=y+Mod.foot_width/2*sin(k/Mod.LinkRes*pi);
                coordZ(1,k)=0;
            end

            y = -Length/2+Mod.foot_width/2;
            
            for k=Mod.LinkRes:2*Mod.LinkRes
                coordX(1,k+1)=x+Mod.foot_width/2*cos(k/Mod.LinkRes*pi);
                coordY(1,k+1)=y+Mod.foot_width/2*sin(k/Mod.LinkRes*pi);
                coordZ(1,k+1)=0;
            end

            res.Geom=patch(coordX,coordY,coordZ,Mod.foot_color);
            set(res.Geom,'EdgeColor',[0 0 0]);
            set(res.Geom,'LineWidth',2*Mod.LineWidth);

            set(res.Geom,'Parent',res.Trans);
            set(res.Trans,'Matrix',Txy*Rz);
        else
            Center=[x0;y0];
            Orientation=0;
            Length=Mod.foot_length;

            Txy=makehgtform('translate',[Center(1) Center(2) z]);
            Rz=makehgtform('zrotate',Orientation-pi/2);
            Sx=makehgtform('scale',[Length/Mod.foot_length,1,1]);
            set(Obj.Trans,'Matrix',Txy*Rz*Sx);
            res=1;
        end
    end

    % Draw cart:
    function [ res ] = DrawCart(Mod, x0, y0, z, Obj)
       
        if isempty(Obj)



            d = 2*r;
            Center=[x0;y0];
            Orientation= Mod.slope;

            res.Trans=hgtransform('Parent',gca);
            Txy=makehgtform('translate',[Center(1) Center(2) z]);
            Rz=makehgtform('zrotate',Orientation);


%                                   L
%                    2 =========================== 3 W
%                     | 7                       6 |
%                     |                           |
%                     |                           | H
%                     |                           |
%                    1| 8                       5 |4
%                   r O                         r O
                       
                    
                    %    1      2       3       4         5        6         7         8  
            coordX = [x0-L/2 ,x0-L/2 ,x0+L/2 ,x0+L/2 ,x0+L/2-W ,x0+L/2-W ,x0-L/2+W ,x0-L/2+W ];
            coordY = [   d   ,  d+H  ,  d+H  ,  d    ,   d     ,  d+H-W  ,  d+H-W  ,    d    ];           
            coordZ=zeros(1,8);            
            
            res.Geom=patch(coordX,coordY,coordZ,Mod.cart_color);
            set(res.Geom,'EdgeColor',[0 0 0]);
            set(res.Geom,'LineWidth',2*Mod.LineWidth);

            set(res.Geom,'Parent',res.Trans);
            set(res.Trans,'Matrix',Txy*Rz);
        else
            Center=[x0;y0];
            Orientation=Mod.slope;

            Txy=makehgtform('translate',[Center(1) Center(2) z]);
            Rz=makehgtform('zrotate',Orientation);
            Sx=makehgtform('scale',[1,1,1]);
            set(Obj.Trans,'Matrix',Txy*Rz*Sx);
            res=1;
        end
    end

    % Draw cart:
    function [ res ] = DrawTrack(Mod, x0,y0, z, Obj)
       
        if isempty(Obj)

 
            w = Mod.cart_track_width;
            d = 2*r;
            
            
            Center=[x0;y0];
            Orientation= Mod.slope;

            res.Trans=hgtransform('Parent',gca);
            Txy=makehgtform('translate',[Center(1) Center(2) z]);
            Rz=makehgtform('zrotate',Orientation);

       
                    %    1      2       3       4        
            coordX = [x0-w/2 ,x0-w/2 ,x0+w/2 ,x0+w/2 ];
            coordY = [d+H-W  , d+H+l   , d+H+l   ,d+H-W  ];  
            coordZ=zeros(1,4);            


            res.Geom=patch(coordX,coordY,coordZ,Mod.cart_color);
            set(res.Geom,'EdgeColor',[0 0 0]);
            set(res.Geom,'LineWidth',2*Mod.LineWidth);

            set(res.Geom,'Parent',res.Trans);
            set(res.Trans,'Matrix',Txy*Rz);
        else
            
            Center=[x0;y0];
            Orientation=Mod.slope;

            Txy=makehgtform('translate',[Center(1) Center(2) z]);
            Rz=makehgtform('zrotate',Orientation);
            Sx=makehgtform('scale',[1,1,1]);
            set(Obj.Trans,'Matrix',Txy*Rz*Sx);
            res=1;
        end
    end
end