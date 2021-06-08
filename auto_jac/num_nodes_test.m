on = thz_tim('date', '2020_09_18', 'num', 6);
off = thz_tim('date', '2020_09_18', 'num', 7);

t_smp = on.t;
A_smp = on.avg + off.avg;
t_ref = off.t;
A_ref = off.avg;


input = load_input('/home/uri/Desktop/nelly/nelly_stats/sno2_s15_input.json');

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

a_cut = input.settings.a_cut;

[func_smp, tree_smp] = build_transfer_function_tree(input.sample, t_cut_tree, a_cut);
[func_ref, tree_ref] = build_transfer_function_tree(input.reference, t_cut_tree, a_cut);
func = @(freq, n_solve) func_smp(freq, n_solve)/func_ref(freq, n_solve);




