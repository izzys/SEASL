clc;clear all;close all;clear classes;

plot_trajectory = 0;
desired_speed = 2.5; %[m/s]

[ SYS ] = InitEnvironmentSEASL(desired_speed);

phi = [0.05 0.45 0.55 0.9];
tau = [10 , -15];
T = 1.2;

theta = [ phi , tau , T];
sigma = [ 0, 0, 0, 0, eps, eps, eps];
gamma = 1;
theta_ind = find(sigma>0);

%       angle  angle/sec      x       x/sec    phase
IC =  [  0.35     -3.5        0        2.97    0.71  ] ;

theta1 = 8:0.05:17;
theta2 = 0.8:0.05:1.5;
max_t1 = length(theta1);
max_t2 = length(theta2);

Jmat = zeros(length(theta1), length(theta2));

tStart = tic;
parfor t1  = 1:max_t1
    for t2 = 1:max_t2

        tic
        
        theta = [phi, theta1(t1) , -theta1(t1) , theta2(t2)];
        [~, ~, ~, J] = GetTrajectorySEASL(SYS, IC, theta ,sigma ,gamma ,plot_trajectory);
        
        Jmat(t1, t2) = J;
        
        disp(['done exp #' num2str(t2+max_t2*(t1-1)) ' out of ' num2str(max_t1*max_t2) ... 
            ' .It took ' num2str(toc) ' sec.' ]);
    end
end

tend = toc(tStart);
disp(['total time: ' num2str(tend) ' sec.'])

getSEASLJ_2par_data.theta1 = theta1;
getSEASLJ_2par_data.theta2 = theta2;

getSEASLJ_2par_data.Jmat = Jmat;
getSEASLJ_2par_data.sigma = sigma;

save getSEASLJ_2par_data_SMILE getSEASLJ_2par_data;

%%

figure(1)
hold on
[X ,Y] = meshgrid(theta1, theta2);
surf(X, Y, Jmat')
xlabel('\theta_1 (\tau)')
ylabel('\theta_2 (T)')
title('J(\theta)')

figure(2)
hold on
contour(X, Y, Jmat', 100)
[dJx, dJy] = gradient(Jmat');
quiver(theta1, theta2, dJx, dJy, 'Color', 'b')
xlabel('\theta_1 (\tau)')
ylabel('\theta_2 (T)')
title('dJ(\theta)')
