%try GA
function [Genome , Best]=tryGAonSIN()
clc;clear all;close all

% Algorithm variables: 
Genome.PopulationNum = 1000;
Genome.KeepPercent = 10;
Genome.MutationVariance = 0.2;
Genome.CrossMutationRatio = 0.3;
Genome.MinFit = 2;

% this is the real values:
Genome.A.actual = 5;
Genome.B.actual = 1;
Genome.omega.actual = 1;
Genome.phi.actual = pi/2;

% set here range:
Genome.A.min = 1;
Genome.A.max = 10;
Genome.B.min  = -10;
Genome.B.max = 10;
Genome.omega.min  = 0.1;
Genome.omega.max = 100;
Genome.phi.min  = -pi;
Genome.phi.max = pi;

% init genome:
Genome = InitGenome(Genome);
Genome.t = 0:0.001:25;

% do some generations:
figure(1)
f_actual = fun(Genome,0);
plot(Genome.t,f_actual,'Color','b','LineWidth',2.3)
hold on



    for gen = 1:200

        [Genome , Best] = Generation(Genome);
        
        figure(1)
        hold on
        f_best = Best.B+Best.A*sin(Best.omega*Genome.t+Best.phi);
        color = [rand(1) rand(1) rand(1)];
        plot(Genome.t,f_best,'Color',color)
        disp(['done gen #' num2str(gen) ', with fit: ' num2str(Best.fit), ' error: ' num2str(Best.e)])
        disp(['Best A: ' num2str(Best.A) '. Best B: ' num2str(Best.B) '. Best omega: ' num2str(Best.omega) '. Best phi: ' num2str(Best.phi)])

        figure(3)
        subplot 221
        hold on
        plot(gen,Best.A,'Marker','.')       
        title('A')
        
        subplot 222
        hold on
        plot(gen,Best.B,'Marker','o')       
        title('B') 
        
        subplot 223
        hold on
        plot(gen,Best.omega,'Marker','*')       
        title('\omega')  

        subplot 224
        hold on
        plot(gen,Best.phi,'Marker','+')       
        title('\phi')  
        
        figure(2)
        semilogy(gen,Best.fit,'Marker','v')  
        hold on
        semilogy(gen,Best.e,'Marker','o','Color','g') 
        title(['gen #' num2str(gen) ', with fit: ' num2str(Best.fit) , ' error: ' num2str(Best.e)])
        xlabel #gen
        ylabel 'fitness,error'
        
        drawnow
        
        if Best.fit<Genome.MinFit
            
            figure
            plot(Genome.t,f_actual,'Color','b','LineWidth',2.3,'LineStyle','--')
            hold on
            plot(Genome.t,f_best,'Color',color)        
            
            title(['converged at gen #' num2str(gen) ', with fitness: ' num2str(Best.fit) , ' error: ' num2str(Best.e)])
            
            return;
            
        end


    end
    
   figure
   plot(Genome.t,f_actual,'Color','b','LineWidth',2.3)
   hold on
   plot(Genome.t,f_best,'Color',color)        
            
   title(['got to max generation, ' num2str(gen) ', with fitness: ' num2str(Best.fit)])

end

function f = fun(Genome,i)

t = Genome.t;

if i==0
A = Genome.A.actual;
B = Genome.B.actual;
w = Genome.omega.actual;
phi = Genome.phi.actual;
else
A = Genome.A.val(i);
B = Genome.B.val(i);
w = Genome.omega.val(i);
phi = Genome.phi.val(i);    
end

f = A*sin(w*t+phi)+B;
end

function [fit,error] = fitness(Genome,i)

t = Genome.t;

f = fun(Genome,i);
f_actual = fun(Genome,0);

fit = norm(f-f_actual);


A_error = Genome.A.val(i)-Genome.A.actual;
B_error = Genome.B.val(i)-Genome.B.actual;
omega_error = Genome.omega.val(i)-Genome.omega.actual;
phi_error = Genome.phi.val(i)-Genome.phi.actual;
error = norm([A_error B_error omega_error phi_error]);

end

function [Genome , Best] = Generation(Genome)

    for i = 1:Genome.PopulationNum
       [ Genome.fit(i) , Genome.e(i)] = fitness(Genome,i);
    end
    
    % sort by best fit:
    [~,best_fit_ind] = sort(Genome.fit);
    Best.A = Genome.A.val(best_fit_ind(1));
    Best.B = Genome.B.val(best_fit_ind(1));
    Best.omega = Genome.omega.val(best_fit_ind(1));
    Best.phi =  Genome.phi.val(best_fit_ind(1));
    [Best.fit , Best.e]= fitness(Genome,best_fit_ind(1));
    
    Genome_tmp = Genome;
    
    % keep 'Keep%'
    KeepPercentInd = floor(Genome.KeepPercent/100*Genome.PopulationNum);

    for i = 1:KeepPercentInd
        
        Genome.A.val(i) = Genome_tmp.A.val(best_fit_ind(i));
        Genome.B.val(i) = Genome_tmp.B.val(best_fit_ind(i));
        Genome.omega.val(i) = Genome_tmp.omega.val(best_fit_ind(i));
        Genome.phi.val(i) = Genome_tmp.phi.val(best_fit_ind(i));
    
    end
    
    % mutate 'Mutate%':
    MutatePercentInd = 2*KeepPercentInd;
  
    for i = (KeepPercentInd+1):MutatePercentInd
        
  
        del_A = normrnd(0,Genome.MutationVariance);
        del_B = normrnd(0,Genome.MutationVariance);
        del_omega = normrnd(0,Genome.MutationVariance);
        del_phi = normrnd(0,Genome.MutationVariance);
        
        Genome.A.val(i) = Genome_tmp.A.val(best_fit_ind(i))+del_A;
        Genome.B.val(i) = Genome_tmp.B.val(best_fit_ind(i))+del_B;
        Genome.omega.val(i) = Genome_tmp.omega.val(best_fit_ind(i))+del_omega;
        Genome.phi.val(i) = Genome_tmp.phi.val(best_fit_ind(i))+del_phi;
    
        
        if Genome.A.val(i)>Genome.A.max
             Genome.A.val(i)=Genome.A.max;
        end
        if Genome.A.val(i)<Genome.A.min
             Genome.A.val(i)=Genome.A.min;
        end 
        if Genome.B.val(i)>Genome.B.max
             Genome.B.val(i)=Genome.B.max;
        end
        if Genome.B.val(i)<Genome.B.min
             Genome.B.val(i)=Genome.B.min;
        end  
        if Genome.omega.val(i)>Genome.omega.max
             Genome.omega.val(i)=Genome.omega.max;
        end
        if Genome.omega.val(i)<Genome.omega.min
             Genome.omega.val(i)=Genome.omega.min;
        end    
        if Genome.phi.val(i)>Genome.phi.max
             Genome.phi.val(i)=Genome.phi.max;
        end
        if Genome.phi.val(i)<Genome.phi.min
             Genome.phi.val(i)=Genome.phi.min;
        end 
    end   
    
    
    % cross-over 'Cross%':     
    for i = (MutatePercentInd+1):Genome.PopulationNum
    
        Parent1 = best_fit_ind(randi(KeepPercentInd));
        Parent2 = best_fit_ind(randi(KeepPercentInd));
  
        if round(rand(1))
          Genome.A.val(i) = Genome_tmp.A.val(Parent1);
        else
          Genome.A.val(i) = Genome_tmp.A.val(Parent2); 
        end
        if rand(1)<Genome.CrossMutationRatio
          del_A = normrnd(0,Genome.MutationVariance);
          Genome.A.val(i) = Genome.A.val(i)+del_A;
        end 
        
        
        if round(rand(1))
          Genome.B.val(i) = Genome_tmp.B.val(Parent1);
        else
          Genome.B.val(i) = Genome_tmp.B.val(Parent2); 
        end
        if rand(1)<Genome.CrossMutationRatio
          del_B = normrnd(0,Genome.MutationVariance);
          Genome.B.val(i) = Genome.B.val(i)+del_B;
        end  
        
        if round(rand(1))
          Genome.omega.val(i) = Genome_tmp.omega.val(Parent1);
        else
          Genome.omega.val(i) = Genome_tmp.omega.val(Parent2); 
        end
        if rand(1)<Genome.CrossMutationRatio
          del_omega = normrnd(0,Genome.MutationVariance);
          Genome.omega.val(i) = Genome.omega.val(i)+del_omega;
        end          
        
        if round(rand(1))
          Genome.phi.val(i) = Genome_tmp.phi.val(Parent1);
        else
          Genome.phi.val(i) = Genome_tmp.phi.val(Parent2); 
        end
        if rand(1)<Genome.CrossMutationRatio
          del_phi = normrnd(0,Genome.MutationVariance);
          Genome.phi.val(i) = Genome.phi.val(i)+del_phi;
        end
        
        if Genome.A.val(i)>Genome.A.max
             Genome.A.val(i)=Genome.A.max;
        end
        if Genome.A.val(i)<Genome.A.min
             Genome.A.val(i)=Genome.A.min;
        end 
        if Genome.B.val(i)>Genome.B.max
             Genome.B.val(i)=Genome.B.max;
        end
        if Genome.B.val(i)<Genome.B.min
             Genome.B.val(i)=Genome.B.min;
        end  
        if Genome.omega.val(i)>Genome.omega.max
             Genome.omega.val(i)=Genome.omega.max;
        end
        if Genome.omega.val(i)<Genome.omega.min
             Genome.omega.val(i)=Genome.omega.min;
        end    
        if Genome.phi.val(i)>Genome.phi.max
             Genome.phi.val(i)=Genome.phi.max;
        end
        if Genome.phi.val(i)<Genome.phi.min
             Genome.phi.val(i)=Genome.phi.min;
        end 
        
    end

end


function Genome = InitGenome(Genome)

N = Genome.PopulationNum;
Genome.A.val = Genome.A.min+(Genome.A.max-Genome.A.min)*rand(1,N);
Genome.B.val = Genome.B.min+(Genome.B.max-Genome.B.min)*rand(1,N);
Genome.omega.val = Genome.omega.min+(Genome.omega.max-Genome.omega.min)*rand(1,N);
Genome.phi.val = Genome.phi.min+(Genome.phi.max-Genome.phi.min)*rand(1,N);

Genome.fit = ones(1,N)*10^99;
Genome.e = ones(1,N)*10^99;
end