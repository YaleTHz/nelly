classdef node_constants
    properties (Constant)
        rf = @(n1, n2) (n1-n2)/(n1+n2);
        tr = @(n1, n2) 2*n1/(n1+n2);
    end
    
    methods(Static)
        function p = prop
            c = physconst('LightSpeed')*1e6; %um/s
            p = @(freq, d, n) exp(-1i*(2*pi*freq*1e12/c)*n*d);
        end  
    end
end