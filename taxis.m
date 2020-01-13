function [t_out] = taxis(t_in, N_fwd, N_back)
N_back
dt = mean(diff(t_in));

t_tot = t_in(end)-t_in(1);

df = 1/(t_tot*N_fwd/numel(t_in));

t_out = (1/(df*N_back))*[0:N_back-1];
