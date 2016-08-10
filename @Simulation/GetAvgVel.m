function [ dx ] = GetAvgVel( Sim )

p_ind = Sim.PoincareEventInd;
last_p_ind = find( cell2mat(Sim.Out.EventsVec.Type(1:end-1))==p_ind ,1,'last');

if isempty(last_p_ind)
    dx = mean( Sim.Out.X(1:end,4) );
else
    last_time = Sim.Out.EventsVec.Time{last_p_ind};
    last_dx_ind = find(Sim.Out.T>last_time,1,'last');
    dx = mean( Sim.Out.X(last_dx_ind:end,4) );
end

end

