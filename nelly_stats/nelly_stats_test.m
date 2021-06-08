on = thz_tim('date', '2020_09_18', 'num', 6);
off = thz_tim('date', '2020_09_18', 'num', 7);
input = load_input('/home/uri/Desktop/nelly/nelly_stats/sno2_s15_input.json');

varargin = {};

[freq, mus, covs] = scan_stats(input, on.data(:,1), on.data(:,2:end), 1);


[freq, tf_spec, freq_full, tf_full, spec_smp, spec_ref] = ...
    exp_tf(on.t, on.avg + off.avg, off.t, off.avg, input);



t_smp = on.t;
A_smp = on.avg + off.avg;
t_ref = off.t;
A_ref = off.avg;


fft_sets = input.settings.fft;

% determine time cut off for etalons (relative to peak)
% (for non tree version)
t_cut_exp = t_smp(end) - t_smp(find(A_smp == max(A_smp),1));
switch fft_sets.windowing_type
    case 'gauss'
        t_cut_wind = 3*fft_sets.windowing_width;
    case 'square' 
        t_cut_wind = fft_sets.windowing_width/2;
    otherwise
        t_cut_wind = Inf;
end

% calculate t_cut for tree
end_time = max([t_smp(:); t_ref(:)]);
t_cut_exp_ref = end_time - t_ref(find(A_ref == max(A_ref),1));
t_cut_exp_ref = min([t_cut_exp_ref t_cut_wind]);

% estimate of time it takes to pass through reference geometry
ref_ns = arrayfun(@(x) x.n_func(1), input.reference);
ref_ds = arrayfun(@(x) x.d, input.reference);
ref_nd = dot(ref_ns, ref_ds);

t_traverse_reference = (1e12*ref_nd/3e14);
t_cut_tree = t_traverse_reference + t_cut_exp_ref;

% estimate starting refractive index 
% real part
delay = t_smp(find(A_smp == max(A_smp),1)) - t_ref(find(A_ref == max(A_ref),1));
n_est = estimate_n(delay, input);
if real(n_est) < 1
    warning('Estimated refractive index is less than 1')
    n_est = 1;
end

% imaginary part
k_mean = mean([min(freq) max(freq)])*2*pi*1e12/3e14;
d_inds = find(strcmp({input.sample.n}, 'solve'));
d_tot = sum(arrayfun(@(ii) input.sample(ii).d, d_inds));
n_prev = [real(n_est) log(mean(abs(tf_spec)))/(d_tot*k_mean)];

a_cut = input.settings.a_cut;

% build transfer functions
func_smp = build_transfer_function_tree(input.sample, t_cut_tree, a_cut,...
    varargin{:});
func_ref = build_transfer_function_tree(input.reference, t_cut_tree, a_cut,...
    varargin{:});
func = @(freq, n_solve) func_smp(freq, n_solve)/func_ref(freq, n_solve);


n_fit = zeros(2, numel(freq));
n_traces = 2;
traces = zeros(numel(freq), n_traces);
pdfs = cell(1, numel(freq));
tf_probs = cell(1, numel(freq));
accepts = zeros(numel(freq), 1);
tic
for ii = 1:numel(freq)
    err = @(n) n_error(func(freq(ii), complex(n(1), n(2))), tf_spec(ii));
    opts = optimset();
    n_opt = fminsearch(err, n_prev, opts);

    % MCMC sampling
    tf_prob = div_dist(mus(ii), covs{ii}, spec_ref(ii));
    tf_probs{ii} = tf_prob;
    pdf = @(x) tf_prob(func(freq(ii), x)-1);
    pdfs{ii} = pdf;
    sig = 5e-3;
    proppdf = @(x,y) normpdf(abs(x-y), 0, sig);
    proprnd = @(x) x + sig*((rand-0.5) + 1i*(rand-0.5));
    
    [trace, accept] = mhsample(n_opt(1)+1i*n_opt(2) ,n_traces,...
        'pdf',pdf,'proppdf',proppdf, 'proprnd',proprnd);
    
    traces(ii,:) = trace';
    accepts(ii) = accept;
    n_prev = n_opt;
    n_fit(:,ii) = n_opt;
    fprintf('%0.2f THz: n = %s\n', freq(ii), num2str(complex(n_opt(1), n_opt(2))))
end   
toc
n_fit = n_fit(1,:) - 1i*n_fit(2,:);


function [chi] = n_error(t1, t2)
chi1 = (log(abs(t1)) - log(abs(t2)))^2;
d = angle(t1) - angle(t2);
chi2 = (mod(d + pi, 2*pi) - pi)^2;
chi = chi1+chi2;
end