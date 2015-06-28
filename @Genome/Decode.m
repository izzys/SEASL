function [ Sim ] = Decode( Ge, Sim, Seq )
%DECODE Decode loads a string of numbers (genome) into a simulation
%   Decode receives a string of numbers and converts it based on the
%   genome keys in order to update the properties of a simulaiton
%   (including the Model, Environment, Controller, initial conditions, etc)

Res = Ge.CheckGenome(Seq);
if Res{1} == 0
%     disp(Res{2});
    % Instead of throwing an error, let's get a random sequence and
    % continue running
%     error('ERROR: Invalid sequence');
%     return;
    Seq = Ge.RandSeq();
end

SeqPos = 1; % Position along the genome sequence
for k = 1:size(Ge.Keys,2)
    % Go over each key
    switch Ge.Keys{1,k}
        %% %%%%%%%%%% Simulation keys in general %%%%%%%%%% %%
        case {'IC','ic','init cond','initial conditions'}
            if isfield(Ge.KeyExtra,Ge.Keys{1,k})
                KE = Ge.KeyExtra.(Ge.Keys{1,k});
                % Store initial conditions provided based
                % on the KeyExtra value for 'IC'
                for v = 1:length(KE)
                    if KE(v) ~= 0
                        Sim.IC(v) = Sim.IC(v) ...
                            + sign(KE(v))*Seq(SeqPos-1+abs(KE(v)));
                    end
                end
            else
                Sim.IC = Seq(SeqPos:SeqPos+Ge.Keys{2,k});
            end
            
        %% %%%%%%%%%% Controller keys %%%%%%%%%% %%
        case Sim.Con.SetKeys
            Sim.Con = Sim.Con.Set(Ge.Keys{1,k},Seq(SeqPos:SeqPos+Ge.Segments(k)-1));
        
        %% %%%%%%%%%% Model keys %%%%%%%%%% %%
        case Sim.Mod.SetKeys
            Sim.Mod = Sim.Mod.Set(Ge.Keys{1,k},Seq(SeqPos:SeqPos+Ge.Segments(k)-1));
        
        %% %%%%%%%%%% Environment keys %%%%%%%%%% %%
        case Sim.Env.SetKeys
            Sim.Env = Sim.Env.Set(Ge.Keys{1,k},Seq(SeqPos:SeqPos+Ge.Segments(k)-1));
    end
    
    % Move the sequence reading position
    SeqPos = Ge.AdvSeq(SeqPos,k);
end

end

