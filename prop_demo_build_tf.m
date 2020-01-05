load test.mat
input = load_input('sample_files/sample_input.json');

t = d_ref(:,1); A = d_ref(:,2);

[freq, spec] = fft_func(t,A, input.settings.fft);

func = build_transfer_function(input);

tf_prop = zeros(numel(spec),1);

for i = 1:numel(freq)
    tf_prop(i) = func(freq(i), 3.4175);
end

spec_prop = spec.*tf_prop;

figure('Units', 'inches', 'Position', [0 0 6 2])
subplot(1,2,1)
semilogy(freq, abs(spec))
hold on
semilogy(freq, abs(spec_prop), '--')
xlim([0 8])
set(allchild(gca), 'linewidth', 2.2)
xlabel('Freq. (THz)')
ylabel('Amplitude')
legend('reference', 'propagated', 'location', 'southwest')

pad_back = 2^12;
t_ifft = taxis(t, 2^input.settings.fft.padding, pad_back);

subplot(1,2,2)
plot(t_ifft, real(ifft(spec, pad_back)))
hold on
plot(t_ifft, real(ifft(spec.*tf_prop, pad_back)))
title(geometry_string(input))
set(allchild(gca), 'linewidth', 1.5)
xlabel('t (ps)')
ylabel('A (a.u)')
xlim([0 10])
