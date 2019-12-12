function [tf_func, tree_func] = build_transfer_function_tree(geom, t_cut, a_cut, varargin)

% process additional arguments
assert(mod(numel(varargin),2) == 0, 'Extra parameters come in pairs')
extra_args = struct;
for ii = 1:2:numel(varargin)
    extra_args.(varargin{ii}) = varargin{ii+1};
end

tf_method = 'tot_tf_all_leaves';
if isfield(extra_args, 'terms')
    tf_method = ['tot_tf_' extra_args.terms];
end


if numel(geom) > 1
    from = 1; into = 2; type = +1; t_acc = 0; amp_prev = 1; parent = [];
    tf_func = @(freq, n_solve) interface_node(from, into, type, t_acc, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent).(tf_method);
            
     tree_func = @(freq, n_solve) interface_node(from, into, type, t_acc, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent);
else
    index = 1; dir = +1; t_prev = 0; amp_prev = 1; parent = [];

    tf_func = @(freq, n_solve) layer_node(index, dir, t_prev, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent).(tf_method);
    tree_func = @(freq, n_solve) layer_node(index, dir, t_prev, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent);
end