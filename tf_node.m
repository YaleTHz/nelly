classdef tf_node < handle & matlab.mixin.Heterogeneous
    properties
        parent
        id
        tf
        num_layers
    end
    
    methods
        % cumulative transfer function upon reaching this node
        function t = tot_tf(obj)
            if isa(obj.parent, 'tf_node')
                t = obj.parent.tot_tf*obj.tf;
            else
                t = obj.tf;
            end
        end
        
        function nds = all_nodes(obj)
            todo = [obj];
            nds = [];
            while numel(todo) > 0
                curr = todo(1); 
                todo = todo(2:end);
                nds = [nds curr];
                todo = [todo curr.children];
            end
        end
        
        function lvs = leaves(obj)
            nds = obj.all_nodes;
            inds = zeros(size(nds));
            for ii = 1:numel(nds)
                inds(ii) = (numel(nds(ii).children) == 0);
            end
            lvs = nds(inds == 1);
        end
        
        function em = emitted(obj)
            lvs = obj.leaves;
            inds = zeros(size(lvs));
            
            % check if transmitting into final layer
            for ii = 1:numel(lvs)
                if isa(lvs(ii), 'interface_node')
                    if lvs(ii).into == obj.num_layers && lvs(ii).type == 1
                        inds(ii) = 1;
                    end
                else
                    if lvs(ii).index == obj.num_layers
                        inds(ii) = 1;
                    end
                end
            end
            
            em = lvs(inds == 1);
        end
        
        % returns the reflection nodes in the path to the current node
        function rs = reflections(obj)
            curr_node = obj;
            rs = [];
            
            while isa(curr_node, 'tf_node')
                if isa(curr_node, 'interface_node')
                    if curr_node.type == -1
                        rs = [rs curr_node];
                    end
                end
                curr_node = curr_node.parent;
            end

        end
        
        % determines if the path to this node includes cross-layer etalons
        function t_or_f = crosslayer(obj)
            refs = obj.reflections;
            froms = arrayfun(@(x) x.from, refs);
            t_or_f = numel(unique(froms)) > 1;
        end
        
        function tf_bd = tot_tf_breakdown(obj)
            emit = obj.emitted;
            cross_layer_inds = arrayfun(@(x) x.crosslayer, emit);
            no_ref_inds = arrayfun(@(x) numel(x.reflections) == 0,...
                emit);
            single_layer_inds = ~cross_layer_inds & ~no_ref_inds;
            
            tf_no_ref = sum(arrayfun(@tot_tf, emit(no_ref_inds)));
            tf_one_layer = sum(arrayfun(@tot_tf, emit(single_layer_inds)));
            tf_cross = sum(arrayfun(@tot_tf, emit(cross_layer_inds)));
            tf_bd = [tf_no_ref, tf_one_layer, tf_cross];
        end
        
        function t = tot_tf_all_leaves(obj)
            t = sum(arrayfun(@tot_tf, obj.emitted));
        end
                
        %% functions for displaying tree
        function vec = tree_vec(obj)
            nds = obj.all_nodes;
            vec = zeros(1, numel(nds));
            
            for ii = 1:numel(nds)
                nds(ii).id = ii;
            end
            
            for ii = 1:numel(nds)
                inds = arrayfun(@(x) x.id, nds(ii).children);
                vec(inds) = nds(ii).id;
            end
        end 
        
        function f = show(obj)
            f = figure();
            nds = obj.all_nodes;
            vec = obj.tree_vec;
            treeplot(vec)
            [x, y] = treelayout(vec);
            for ii = 1:numel(nds)
                ind = nds(ii).id;
                if isa(nds(ii), 'interface_node')
                    color = [1 0.6 0.6];
                    if nds(ii).type == -1
                        color = [1 0.7 0.5];
                    end
                    text(x(ind), y(ind), nds(ii).to_s,...
                        'backgroundcolor', color ,...
                        'horizontalalignment', 'center', 'color', 'w', ...
                        'fontweight', 'bold', 'fontsize', 8)
                else
                    text(x(ind), y(ind), nds(ii).to_s,...
                        'backgroundcolor', '[0.6 0.6 1]',...
                        'horizontalalignment', 'center', 'color', 'w', ...
                        'fontweight', 'bold', 'fontsize', 8)
                end
                hold on
            end
        end
        
        function show_tf(obj)
            figure()
            nds = obj.all_nodes;
            vec = obj.tree_vec;
            treeplot(vec)
            set(allchild(gca), 'markersize', 1)
            [x, y] = treelayout(vec);
            hold on
            
            for ii = 1:numel(nds)
                plot(x(ii), y(ii), 'ok',...
                    'markersize', 30*abs(nds(ii).tot_tf),...
                    'markerfacecolor', [0.5 0.5 0.5])
            end
                            
        end
    end
end