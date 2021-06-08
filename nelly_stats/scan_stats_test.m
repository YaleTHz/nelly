on = thz_tim('date', '2020_09_18', 'num', 6);
off = thz_tim('date', '2020_09_18', 'num', 7);
input = load_input('/home/uri/Desktop/nelly/nelly_stats/sno2_s15_input.json');

[freq, mus, covs] = scan_stats(input, on.data(:,1), on.data(:,2:end), 1);


n_samples = 1e3;

specs = zeros(n_samples, numel(freq));
tfs = zeros(n_samples, numel(freq));


for ii = 1:n_samples
    [freq, tf_spec, freq_full, tf_full, spec_smp, spec_ref, smp_full, ref_full] = ...
    exp_tf(on.t, on.resample(1), off.t, off.avg, input);
    specs(ii,:) = spec_smp;
end

num_rows = floor(sqrt(numel(freq)));
num_cols = ceil(sqrt(numel(freq)));

for r = 1:num_rows
    for c = 1:num_cols
        ii = (r-1)*num_cols + c;
        if ii <= numel(freq)
            subplot(num_rows, num_cols, ii)
            plot(real(specs(:,ii)), imag(specs(:,ii)), '.')
            hold on
            plot_ellipse([real(mus(ii)) imag(mus(ii))], covs{ii})
        end
    end
end