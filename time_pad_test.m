% 1 in 2
x1 = [-5:0.1:5];
a1 = x1.^2;

x2 = [-3:0.5:10];
a2 = 0.9*(x2-2).^2-5;

[x_all, a2_pad, a1_pad] = time_pad(x2, a2, x1, a1);

plot(x1,a1, '.-')
hold on
plot(x2,a2, '.-')
plot(x_all, a1_pad, 's-')
plot(x_all, a2_pad, 's-')
