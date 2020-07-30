% takes freq in THz, cond in S/m
function [x, func] = drude_fit(freq, cond)

func = @(x) x(1)./(1-1i*2*pi*freq*x(2)); 

x = fminsearch(@(x) norm(cond-func(x)), [1000, 0.03]);