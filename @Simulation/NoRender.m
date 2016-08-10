function [] = NoRender(Sim,t,X,flag)
% Don't Renders the simulation graphics
    switch flag
        case 'init'
            t = t(1);
            
            if Sim.Once


                Sim.Once = 0;

            end
    end

    
    if ~isempty(X)
        
        [COMx,COMy]=Sim.Mod.GetPos(X(end,:),'COM');
        
         Sim.FlMin = COMx-1.5*Sim.AR*Sim.Mod.cart_length;
         Sim.FlMax = COMx+1.5*Sim.AR*Sim.Mod.cart_length;
         Sim.HeightMin = COMy-4/Sim.AR*Sim.Mod.cart_height;
         Sim.HeightMax = COMy+4/Sim.AR*Sim.Mod.cart_height;
                
        % Update environment render
        [ Sim.Env,FloorX, FloorY ]= Sim.Env.NoRender(Sim.FlMin,Sim.FlMax);
        
        %pass to model:
        Sim.Mod.Env_params.FloorX = FloorX;
        Sim.Mod.Env_params.FloorY = FloorY;
        
        % Update model render
        Sim.Mod = Sim.Mod.NoRender(X(end,Sim.ModCo));



    end
    status = Sim.StopSim;


end