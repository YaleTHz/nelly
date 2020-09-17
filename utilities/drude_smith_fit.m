function [x, func] = drude_smith_fit(freq, cond)

% x(1) -- sigma_0
% x(2) -- scattering time
% x(3) -- c parameter

func = @(x) (x(1)./(1-1i*2*pi*freq*x(2))).*(1+x(3)./(1-1i*2*pi*freq*x(2))); 

x = fminsearch(@(x) norm(cond-func(x)), [130, 0.1, -1]);