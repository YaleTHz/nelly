classdef  interface_node < handle & tf_node
    properties
        from   % index of material after interface
        into   % index of material after interface
        t_acc  % total time accumulated to reach this node
        amp    % amplitude after this node
        type   % +1 for transmission, -1 for reflection
        child  % layer_node child
    end
    
    methods
        function obj = interface_node(from, into, type, t_acc, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent)
            obj.from = from; obj.into = into; obj.t_acc = t_acc;
            obj.type = type; obj.parent = parent;
            
            fprintf('%d->%d\n', from ,into)
            n_from = geom(from).n_func(freq, n_solve);
            n_into = geom(into).n_func(freq, n_solve);
            
            rf = node_constants.rf;
            tr = node_constants.tr;
            
            % handle reflection 
            if type == -1
               amp = amp_prev*abs(rf(n_from, n_into));
               obj.amp = amp;
               if amp > a_cut
                   obj.child = layer_node(from, from-into, t_acc, amp,...
                       geom, freq, n_solve, t_cut, a_cut, obj);
               end
            end
            
            if type == +1
                amp = amp_prev*abs(tr(n_from, n_into));
                obj.amp = amp;                
                if (amp > a_cut) && into < numel(geom)
                    obj.child = layer_node(into, into-from, t_acc, amp, ...
                        geom, freq, n_solve, t_cut, a_cut, obj);
                end
            end
        end
        
        function cs = children(obj)
            cs = [];
            if isa(obj.child, 'layer_node')
                cs = obj.child;
            end
        end
        
        function s = to_s(obj)
            type_s = 'r';
            if obj.type > 0
                type_s = 't';
            end
            s = sprintf('%d -> %d (%s)', obj.from, obj.into, type_s);
        end
    end
end