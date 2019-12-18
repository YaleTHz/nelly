load test.mat
input = load_input('sample_files/sample_input.json');

t = d_ref(:,1); A = d_ref(:,2);

[freq, spec] = fft_func(t,A, input.settings.fft);

func = build_transfer_function(input);

tf_prop = zeros(numel(spec),1);

for i = 1:numel(freq)
    tf_prop(i) = func(freq(i), 0);
end

spec_prop = spec.*tf_prop;

pad = 2^input.settings.fft.padding;
t_ifft = mean(diff(t))*[1:pad];

figure()
subplot(1,2,1)
semilogy(freq, abs(spec))
hold on
semilogy(freq, abs(spec_prop), '--')
xlim([0 8])
set(allchild(gca), 'linewidth', 2.2)

subplot(1,2,2)
plot(t_ifft, real(ifft(spec.*tf_prop, pad)))
hold on
plot(t_ifft, real(ifft(spec, pad)))
title(input.geometry)
xlim([0 20])



