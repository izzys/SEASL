function [ Con ] = Set( Con, varargin )
% Sets desired object properties

nParams = (nargin-1)/2;
if rem(nParams,1)~=0 || nargin<1
    error('Set failed: not enough inputs')
else
    for p = 1:nParams
        key = varargin{2*p-1};
        value = varargin{2*p};
        if ~isnumeric(value)
            error('Set failed: property value must be numeric');
        end
        
        switch key

            case 'Period'
                Con.Period = value; 
            case 'tau'
                Con.tau = value; 
            case 'phi_tau'
                Con.phi_tau = value; 
            case 'phi_reflex'
                Con.phi_reflex = value; 
            case 'TC'
                Con.TC = value;
            case 'Period_var'
                Con.Period_var = value;
            case 'phi_var'
                Con.phi_var = value;                
            case 'tau_var'
                Con.tau_var = value;                
                

            otherwise
                error(['Set failed: ',key,' property not found']);
        end
    end
end

