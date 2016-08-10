function [  J , dJdtheta,trials] = FiniteDifferenceSEASL(SYS,IC,sigma,gamma,theta )

   angle_diff = 100;
   plot_trajectory = 0;
   theta_ind = find(sigma>0);
   angle_diff_vec = [];
   NofWorkers = 4;
   trials = 0;
   k = 1;
   J_sum = 0;
   
    % run estimations of the gradient
    while angle_diff > 2 && k < 100
       

     
       % run roll outs untill Jforward converges
        parfor i = 1:NofWorkers
            
        d  = randn(1,length(theta_ind));
        dtheta{i}  = sigma(theta_ind).*d ;
        
       
        theta_forw = theta;
        theta_forw(theta_ind) = theta(theta_ind) + dtheta{i} ;
        theta_back = theta;
        theta_back(theta_ind) = theta(theta_ind) - dtheta{i} ;
        
        [ ~ , ~ , ~ , J_forw{i}] =  GetTrajectorySEASL(SYS , IC,theta_forw , sigma ,gamma , plot_trajectory);
        

        [~ , ~ , ~ , J_back{i}] =  GetTrajectorySEASL(SYS , IC,theta_back , sigma ,gamma , plot_trajectory); 
        
        end
        
        for i = 1:NofWorkers
          
          trials = trials+1;
          J_sum = J_sum + 1/2*J_forw{i} + 1/2*J_back{i};
          dTheta(trials,:) =  dtheta{i};    
          dJ(trials,1) = J_forw{i} - J_back{i};

        end
        
         if k>1
            dJdtheta = inv(dTheta'*dTheta)*dTheta'*dJ;
            dJdtheta = dJdtheta'

            
            if k==2

                dJdtheta_prev1 = dJdtheta;

            elseif k==3
                dJdtheta_prev2 = dJdtheta_prev1;
                dJdtheta_prev1 = dJdtheta;
                
            elseif k==4
                dJdtheta_prev3 = dJdtheta_prev2;
                dJdtheta_prev2 = dJdtheta_prev1;
                dJdtheta_prev1 = dJdtheta;
            else
              angle_diff1 = GetAngle(dJdtheta,dJdtheta_prev1);
              angle_diff2 = GetAngle(dJdtheta,dJdtheta_prev2);
              angle_diff3 = GetAngle(dJdtheta,dJdtheta_prev3);
              angle_diff = norm([angle_diff1 angle_diff2 angle_diff3])
              angle_diff_vec = [angle_diff_vec angle_diff];
              
              dJdtheta_prev3 = dJdtheta_prev2;
              dJdtheta_prev2 = dJdtheta_prev1;
              dJdtheta_prev1 = dJdtheta;
            end
            
            end
            

        k = k+1;    
            
    end
    
    J = J_sum/trials;
    
    figure(256)
    hold on
    plot(angle_diff_vec,'--v')
    ylabel('angle')

end

