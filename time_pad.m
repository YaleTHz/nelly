% This function adjusts the spacing and pads the time traces to allow
% data with different time ranges/spacing to be transformed together.
% the data is padded by repeating the nearest value, and is interpolated
% linearly.
% This interpolation also provides even spacing even if the original data 
% files did not have this.
function [t, A_smp_pad, A_ref_pad] ...
    = time_pad(t_smp, A_smp, t_ref, A_ref)

dt_ref = mean(diff(t_ref)); dt_smp = mean(diff(t_smp));

if abs((dt_ref-dt_smp)/min([dt_ref dt_smp])) > 0.01
    warning('The provided time traces have different time spacing; applying interpolation in time_pad')
end

if min(t_ref) ~= min(t_smp)
    warning('The provided time traces have different time ranges; applying padding in time_pad')
end
t_lo = min([min(t_ref) min(t_smp)]);
dt = min([dt_ref dt_smp]);
t_hi = max([max(t_ref) max(t_smp)]);
n = (t_hi-t_lo)/dt;
t = t_lo:(t_hi-t_lo)/floor(n):t_hi;
fprintf('dt1: %0.5f\n', dt)
fprintf('dt2: %0.05f\n', (t_hi-t_lo)/floor(n))
fprintf('t_hi: %0.5f, t_lo: %0.5f\n', t_lo, t_hi)
fprintf('t_mi: %0.5f, t_ma: %0.5f\n', min(t), max(t))

A_smp_pad = pad(t_smp, A_smp);
A_ref_pad = pad(t_ref, A_ref);

function A = pad(t_pre, A_pre)
add_lo = sum(t_pre == t_lo) == 0;
add_hi = sum(t_pre == t_hi) == 0;
A = interp1([t_lo*ones(add_lo); t_pre(:); t_hi*ones(add_hi)],...
    [A_pre(1)*ones(add_lo); A_pre(:); A_pre(end)*ones(add_hi)], t);
end
end
