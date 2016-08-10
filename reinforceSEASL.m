function [ Jout , grad, trial] = reinforceSEASL(SYS,IC, sigma , gamma, theta)

    plot_trajectory = 0;
    N = 100;
    x0 = IC;
    J_sum = 0;
    sumdJdTheta = 0;
    NofWorkers = 4;
    
    theta_ind = find(sigma>0);
    
    sumdLogPi = zeros(1,length(theta_ind));
    sum_b_num = zeros(1,length(theta_ind));
    sum_b_den = zeros(1,length(theta_ind));
    
    trial = 1;
    for k = 1:N

        % get a trajectory with x0 and a policy theta:
        parfor i = 1:NofWorkers
        [~, ~, dtheta{i}, J{i}] = GetTrajectorySEASL(SYS, x0, theta, sigma, gamma, plot_trajectory);
        end
        
        for i = 1:NofWorkers
 
        dLogPi = sum( dtheta{i}(:,theta_ind) );%./repmat(sigma(theta_ind).^2,size(dtheta{i}(:,theta_ind),1),1) ,1);
        sumdLogPi = sumdLogPi+dLogPi;
        
        sum_b_num = sum_b_num + (dLogPi).^2 * J{i};
        sum_b_den = sum_b_den +  (dLogPi).^2;

        b_num = sum_b_num;
        b_den = sum_b_den;
        
        b = b_num./b_den;
        
        dJdTheta = dLogPi .* (J{i}*ones(1,length(theta_ind)) - b);
        sumdJdTheta = sumdJdTheta + dJdTheta;
        
        
        grad = sumdJdTheta/trial;
        J_sum = J_sum + J{i};
        Jout = J_sum/trial;
        
        trial = trial+1;
        
        end
        


              if k == 1
                 grad_prev1 = grad;
                 disp(['Done ' num2str(trial-1) ' episodes.' ])
              elseif k == 2
                 grad_prev2 = grad_prev1;
                 grad_prev1 = grad;
                 disp(['Done ' num2str(trial-1) ' episodes.' ])
              elseif k == 3
                  grad_prev3 = grad_prev2;
                  grad_prev2 = grad_prev1;
                  grad_prev1 = grad;
                  disp(['Done ' num2str(trial-1) ' episodes.' ])
              elseif k>3
                  Angle_diff1  = GetAngle( grad,grad_prev1 );
                  Angle_diff2  = GetAngle( grad,grad_prev2 );
                  Angle_diff3  = GetAngle( grad,grad_prev3 );

                  angle_diff = norm([Angle_diff1 Angle_diff2 Angle_diff3]);
                  disp(['Done ' num2str(trial-1) ' episodes with angle diff: ' num2str(angle_diff) ])
              if angle_diff <2
                  disp(['Gradient estimate done after: ' num2str(trial-1) ' episodes. angle diff: ' num2str(angle_diff)])
                  return
              end

              grad_prev3 = grad_prev2;
              grad_prev2 = grad_prev1;   
              grad_prev1 = grad;  

              end

     end

disp(['Gradient estimate did NOT converge! exiting after: ' num2str(k) ' episodes'])
