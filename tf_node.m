classdef tf_node < handle & matlab.mixin.Heterogeneous
    properties
    end
    
    methods
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
                id = nds(ii).id;
                if isa(nds(ii), 'interface_node')
                    text(x(id), y(id), nds(ii).to_s,...
                        'backgroundcolor', '[1 0.6 0.6]',...
                        'horizontalalignment', 'center', 'color', 'w', ...
                        'fontweight', 'bold', 'fontsize', 8)
                else
                    text(x(id), y(id), nds(ii).to_s,...
                        'backgroundcolor', '[0.6 0.6 1]',...
                        'horizontalalignment', 'center', 'color', 'w', ...
                        'fontweight', 'bold', 'fontsize', 8)
                end
            end
        end
    end
end