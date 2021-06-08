function [] = test_jacobian(f, x_re, x_im, xs_re, xs_im, jac)
f_x_re = arrayfun( @(x) f(x + 1i*x_im), xs_re);
f_x_im = arrayfun( @(x) f(x_re + 1i*x), xs_im);

func_val = f(x_re + 1i*x_im);

%% d re(f)/d re(x)
subplot(2,2,1)
plot(xs_re, real(f_x_re), '.')
hold on
plot(x_re, real(func_val), 'o')
plot(xs_re, jac(1,1)*(xs_re-mean(xs_re)) + real(func_val))
title('$\frac{\partial\Re[f]}{\partial\Re[x]}$',...
    'interpreter', 'latex', 'fontsize', 16)
xlabel('$\Re[x]$', 'interpreter', 'latex')
ylabel('$\Re[f]$', 'interpreter', 'latex')


subplot(2,2,2)
plot(xs_im, real(f_x_im), '.')
hold on
plot(x_im, real(func_val), 'o')
plot(xs_im, jac(1,2)*(xs_im-mean(xs_im)) + real(func_val))
title('$\frac{\partial\Re[f]}{\partial\Im[x]}$',...
    'interpreter', 'latex', 'fontsize', 16)
xlabel('$\Im[x]$', 'interpreter', 'latex')
ylabel('$\Re[f]$', 'interpreter', 'latex')


subplot(2,2,3)
plot(xs_re, imag(f_x_re), '.')
hold on
plot(x_re, imag(func_val), 'o')
plot(xs_re, jac(2,1)*(xs_re-mean(xs_re)) + imag(func_val))
title('$\frac{\partial\Im[f]}{\partial\Re[x]}$',...
    'interpreter', 'latex', 'fontsize', 16)
xlabel('$\Re[x]$', 'interpreter', 'latex')
ylabel('$\Im[f]$', 'interpreter', 'latex')

subplot(2,2,4)
plot(xs_im, imag(f_x_im), '.')
hold on
plot(x_im, imag(func_val), 'o')
plot(xs_im, jac(2,2)*(xs_im-mean(xs_im)) + imag(func_val))
title('$\frac{\partial\Im[f]}{\partial\Im[x]}$',...
    'interpreter', 'latex', 'fontsize', 16)
xlabel('$\Im[x]$', 'interpreter', 'latex')
ylabel('$\Im[f]$', 'interpreter', 'latex')
