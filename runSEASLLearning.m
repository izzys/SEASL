clc;clear all ; close all;clear classes

plot_trajectory = 0;
desired_speed = 2.5; %[m/s]
   
SYS = InitEnvironmentSEASL(desired_speed);
    
phi = [0.05 0.45 0.55 0.9];
tau = [15 , -15];
T = 1.1;

theta = [ phi , tau , T];
sigma = [ 0.1, 0.1, 0.1 ,0.1 ,0.1, 0.1, 0.5];
theta_ind = find(sigma>0);

%     angle  angle/sec    x      x/sec   phase
IC =  [ 0.35  -3.5        0       2.97   0.71] ;
gamma = 1;
alpha  = 0.001;
 
figure(124)
[~, ~, ~, J] = GetTrajectorySEASL(SYS, IC, theta, zeros(1,length(sigma)), gamma, 0);
trials = 1;
hold on
Jplot = plot(trials,J,'--ob');
xlabel step
ylabel J
title 'J(\theta)'

method = 1; %FINITE DIFF: 1  REINFORCE: 2  NATURAL: 3 

for i = 1:50
    
    % do some trials until gradient estimation converges:
    if method==1                                           
         [J(i+1), grad(i,:),trials(i+1)] = FiniteDifferenceSEASL(SYS,IC,sigma ,gamma, theta(i,:) );
    elseif method ==2
         [J(i+1), grad(i,:),trials(i+1)] = reinforceSEASL(SYS,IC, sigma ,gamma, theta(i,:));
    elseif method ==3
         [J(i+1), grad(i,:),trials(i+1)] = NaturalAC_SEASL(SYS,IC, sigma ,gamma, theta(i,:));  
    end

    % update theta:
    theta(i+1,:) = theta(i,:);
    theta(i+1,theta_ind) = theta(i,theta_ind) + alpha * grad(i,:);
    disp(['done step #' num2str(i)  '. theta: ' num2str(theta(i+1,theta_ind))])
    
    % plot the J:

    set(Jplot,'Xdata',cumsum(trials),'Ydata',J)
    
    figure(11)
    hold on
    u = theta(i+1,theta_ind(1))-theta(i,theta_ind(1));
    v = theta(i+1,theta_ind(2))-theta(i,theta_ind(2));

    quiver(theta(i,theta_ind(1)),theta(i,theta_ind(2)),u,v,1)
    text(theta(i,theta_ind(1)),theta(i,theta_ind(2)),['J = ' num2str(J(i)) ])
    xlabel('\theta_1 (\phi_1)')
    ylabel('\theta_2 (\phi_2)')
    
    if length(theta_ind)>=4
    figure(12)   
    hold on
    u = theta(i+1,theta_ind(3))-theta(i,theta_ind(3));
    v = theta(i+1,theta_ind(4))-theta(i,theta_ind(4));

    quiver(theta(i,theta_ind(3)),theta(i,theta_ind(4)),u,v,1)
    text(theta(i,theta_ind(3)),theta(i,theta_ind(4)),['J = ' num2str(J(i)) ])    
    xlabel('\theta_3 (\phi_3)')
    ylabel('\theta_4 (\phi_4)')
        
    end
    
    if length(theta_ind)>=6
    figure(13)   
    hold on
    u = theta(i+1,theta_ind(5))-theta(i,theta_ind(5));
    v = theta(i+1,theta_ind(6))-theta(i,theta_ind(6));

    quiver(theta(i,theta_ind(5)),theta(i,theta_ind(6)),u,v,1)
    text(theta(i,theta_ind(5)),theta(i,theta_ind(6)),['J = ' num2str(J(i)) ])    
    xlabel('\theta_5 (\tau_1)')
    ylabel('\theta_6 (\tau_2)')    
        
    end  
    
    
    if length(theta_ind)>=7
    figure(15)   
    hold on
    u = theta(i+1,theta_ind(6))-theta(i,theta_ind(6));
    v = theta(i+1,theta_ind(7))-theta(i,theta_ind(7));

    quiver(theta(i,theta_ind(6)),theta(i,theta_ind(7)),u,v,1)
    text(theta(i,theta_ind(6)),theta(i,theta_ind(7)),['J = ' num2str(J(i)) ])    
    xlabel('\theta_6 (\tau_2)')   
    ylabel('\theta_7 (T)')         
        
    end      
    
    
    drawnow
    
    SEASLLearn.trials = trials;
    SEASLLearn.J = J;
    SEASLLearn.grad = grad;
    SEASLLearn.sigma = sigma;
    SEASLLearn.theta = theta;
    SEASLLearn.SYS = SYS;
    SEASLLearn.alpha = alpha;
   
end

 
    date_and_hour = datestr(now);
    Hour = hour(date_and_hour);
    Minute = minute(date_and_hour);
    Seconds = second(date_and_hour);
    name = getenv('COMPUTERNAME');
    save(['SEASLLearn_' name '_' datestr(now,'dd-mmm-yyyy') '_'  num2str(Hour) '_' num2str(Minute) '_' num2str(Seconds) ],'SEASLLearn')
    
