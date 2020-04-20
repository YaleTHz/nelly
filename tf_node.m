classdef tf_node < handle & matlab.mixin.Heterogeneous
    properties
        parent
        id
        tf
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
    end
end