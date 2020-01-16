
%[t, A_smp_pad, A_ref_pad] ...
%    = time_pad(t_smp, A_smp, t_ref, A_ref)

%% test with random data 
x1 = randx;
x2 = randx;
y1 = sin(rand*x1.^2);
y2 = sin(rand*x2.^2);


[x_all, y1_pad, y2_pad] = time_pad(x1, y1, x2, y2);

y1_test = interp1(x_all, y1_pad, x1);
y2_test = interp1(x_all, y2_pad, x2);

norm1 = norm(y1_test-y1)/norm(y1-mean(y1));
norm2 = norm(y2_test-y2)/norm(y2-mean(y2));

assert(norm1 < 1e-2, 'padded data deviates from original data')
assert(norm1 < 1e-2, 'padded data deviates from original data')
assert(y1_pad(1) == y1(1), 'beginning of padded data does not match beginning of original data')
assert(y1_pad(end) == y1(end),  'end of padded data does not match end of original data')
assert(y2_pad(1) == y2(1), 'beginning of padded data does not match beginning of original data')
assert(y2_pad(end) == y2(end),  'end of padded data does not match end of original data')

function [x] = randx()
x_lo = rand-1;
x_hi = x_lo + rand;
dt = (x_hi - x_lo)/100*(rand+1);

x = x_lo:dt:x_hi;
end