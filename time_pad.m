function [t, A_smp_pad, A_ref_pad] ...
    = time_pad(t_smp, A_smp, t_ref, A_ref)
% TIME_PAD: match two time traces in time range and spacing
%
% [t, A_smp_pad, A_ref_pad] = time_pad(t_smp, A_smp, t_ref, A_ref) = 
%   .....TIME_PAD(t_smp, A_smp, t_ref, A_ref) takes the two input time
%   traces and interpolates them so that they have the same time range and
%   spacing.
% 
% INPUT
% t_smp, A_smp -- this pair gives the first time trace
% t_ref, A_ref -- this pair give the second time trace
% 
% OUTPUT
% t         -- the time points for both interpolated traces
% A_smp_pad -- the interpolated amplitude corresponding to the input A_smp
% A_ref_pad -- the interpolated amplitude corresponding to the input A_ref


% check for different spacing
dt_ref = mean(diff(t_ref)); dt_smp = mean(diff(t_smp));

if abs((dt_ref-dt_smp)/min([dt_ref dt_smp])) > 0.01
    warning('The provided time traces have different time spacing; applying interpolation in time_pad')
end

% check for differing time ranges
if min(t_ref) ~= min(t_smp)
    warning('The provided time traces have different time ranges; applying padding in time_pad')
end

% generate new time scale
t_lo = min([min(t_ref) min(t_smp)]);
dt = min([dt_ref dt_smp]);
t_hi = max([max(t_ref) max(t_smp)]);
n = (t_hi-t_lo)/dt;
t = t_lo:(t_hi-t_lo)/floor(n):t_hi;

A_smp_pad = pad(t_smp, A_smp);
A_ref_pad = pad(t_ref, A_ref);

% linearly interpolate time traces across new time scale (padding with
% zeros)
function A = pad(t_pre, A_pre)
add_lo = sum(t_pre == t_lo) == 0;
add_hi = sum(t_pre == t_hi) == 0;
A = interp1([t_lo*ones(add_lo); t_pre(:); t_hi*ones(add_hi)],...
    [A_pre(1)*ones(add_lo); A_pre(:); A_pre(end)*ones(add_hi)], t);
end
end
