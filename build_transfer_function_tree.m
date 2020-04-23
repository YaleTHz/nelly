function [tf_func, tree_func] = build_transfer_function_tree(geom, t_cut, a_cut)

if numel(geom) > 1
    from = 1; into = 2; type = +1; t_acc = 0; amp_prev = 1; parent = [];
    tf_func = @(freq, n_solve) interface_node(from, into, type, t_acc, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent).tot_tf_all_leaves;
            
     tree_func = @(freq, n_solve) interface_node(from, into, type, t_acc, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent);
else
    index = 1; dir = +1; t_prev = 0; amp_prev = 1; parent = [];

    tf_func = @(freq, n_solve) layer_node(index, dir, t_prev, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent).tot_tf_all_leaves;
    tree_func = @(freq, n_solve) layer_node(index, dir, t_prev, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent).tot_tf_all_leaves;
end