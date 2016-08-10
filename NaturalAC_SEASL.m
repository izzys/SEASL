function [ J_mean , grad, trial] = NaturalAC_SEASL(SYS,IC, sigma , gamma, theta)

    plot_trajectory = 0;
    N = 100;
    x0 = IC;
  
    NofWorkers = 4;
    
    theta_ind = find(sigma>0);
    
    sum_F = zeros(length(theta_ind),length(theta_ind));
    sum_g = zeros(length(theta_ind),1);
    sum_phi = zeros(length(theta_ind),1);
    sum_J = 0;
    trial = 0;
    
    
    for k = 1:N

        % get a trajectory with x0 and a policy theta:
        parfor i = 1:NofWorkers
        [~, ~, dtheta{i}, J{i}] = GetTrajectorySEASL(SYS, x0, theta, sigma, gamma, plot_trajectory);    
        end
        
        for i = 1:NofWorkers
        trial = trial+1;
        
        dLogPi = sum( dtheta{i}(:,theta_ind)./repmat(sigma(theta_ind).^2,size(dtheta{i}(:,theta_ind),1),1) ,1);
        sum_ksi = dLogPi';
        
        
        sum_F = sum_F + sum_ksi*sum_ksi';
        sum_g = sum_g + sum_ksi*J{i};
        sum_phi = sum_phi + sum_ksi;
        sum_J = sum_J + J{i};
        end 
        
        
        phi_mean = sum_phi/trial;
        F_mean = sum_F/trial;
        J_mean =  sum_J/trial;
        g_mean = sum_g/trial;
        
        Q = (1/trial)*(1+phi_mean'*inv(sum_F-phi_mean*phi_mean')*phi_mean);
        b = Q*(J_mean-phi_mean'*inv(F_mean)*g_mean);
        grad = inv(F_mean)*(g_mean-phi_mean*b);
        grad = grad';

      if k == 1
         grad_prev1 = grad;
         disp(['Done ' num2str(trial) ' episodes.' ])
      elseif k == 2
         grad_prev2 = grad_prev1;
         grad_prev1 = grad;
         disp(['Done ' num2str(trial) ' episodes.' ])
      elseif k == 3
          grad_prev3 = grad_prev2;
          grad_prev2 = grad_prev1;
          grad_prev1 = grad;
          disp(['Done ' num2str(trial) ' episodes.' ])
      elseif k>3
          Angle_diff1  = GetAngle( grad,grad_prev1 );
          Angle_diff2  = GetAngle( grad,grad_prev2 );
          Angle_diff3  = GetAngle( grad,grad_prev3 );

          angle_diff = norm([Angle_diff1 Angle_diff2 Angle_diff3]);
          disp(['Done ' num2str(trial) ' episodes with angle diff: ' num2str(angle_diff) ])
      if angle_diff <5
          disp(['Gradient estimate done after: ' num2str(trial-1) ' episodes. angle diff: ' num2str(angle_diff)])
          return
      end

      grad_prev3 = grad_prev2;
      grad_prev2 = grad_prev1;   
      grad_prev1 = grad;  

      end

     end

disp(['Gradient estimate did NOT converge! exiting after: ' num2str(k) ' episodes'])
