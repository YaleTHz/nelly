on = thz_tim('date', '2020_09_18', 'num', 6);
off = thz_tim('date', '2020_09_18', 'num', 7);
input = load_input('/home/uri/Desktop/nelly/nelly_stats/sno2_s15_input.json');


t_smp = on.t;
A_smp = on.avg + off.avg;
t_ref = t_smp;
A_ref= off.avg;
% calculate t_cut for tree

end_time = max([t_smp(:); t_ref(:)]);
t_cut_exp_ref = end_time - t_ref(find(A_ref == max(A_ref),1));

% estimate of time it takes to pass through reference geometry
ref_ns = arrayfun(@(x) x.n_func(1), input.reference);
ref_ds = arrayfun(@(x) x.d, input.reference);
ref_nd = dot(ref_ns, ref_ds);

t_traverse_reference = (1e12*ref_nd/3e14);
t_cut_tree = t_traverse_reference + t_cut_exp_ref;

a_cut = 1e-5;

%t_cut_tree = 6.565
[smp_func, smp_tree] = build_transfer_function_tree(input.sample,...
    t_cut_tree, a_cut);

[ref_func, ref_tree] = build_transfer_function_tree(input.reference,...
    t_cut_tree, a_cut);

n_opt = 2.4247-0.34936i;
nrs = [-1:1e-1:1] + real(n_opt);
nis = [-1:1e-1:1] + imag(n_opt);

freq = 1;
smp = smp_tree(freq, n_opt);
ref = ref_tree(freq, n_opt);

[d_re, d_im] = smp.tot_d_mat_emitted;
f = @(x) smp_func(1, x)/ref_func(1,x);
ref_mat = ref.tot_mat_emitted;
tf_re = inv(ref_mat)*d_re;
tf_im = inv(ref_mat)*d_im;
jac = [tf_re(:,1) tf_im(:,1)];

test_jacobian(f, real(n_opt), imag(n_opt), nrs, nis, jac)
