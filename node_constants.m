classdef node_constants
    properties (Constant)
        rf = @(n1, n2) (n1-n2)/(n1+n2);
        tr = @(n1, n2) 2*n1/(n1+n2);
        c = 299792458*1e6; %um/s
    end
    
    methods(Static)
        function p = prop
            c = node_constants.c;
            p = @(freq, d, n) exp(-1i*(2*pi*freq*1e12/c)*n*d);
        end
    end
end