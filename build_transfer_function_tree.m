function func = build_transfer_function_tree(geom, t_cut, a_cut)
from = 1; into = 2; type = +1; t_acc = 0; amp_prev = 1; parent = [];

func = @(freq, n_solve) interface_node(from, into, type, t_acc, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent).tot_tf_all_leaves;
end