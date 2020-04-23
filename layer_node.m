classdef layer_node < handle & tf_node
    properties
        index  % index of material in geometry
        t_acc  % time accumulated upon reaching the end of the layer
        amp    % amplitude upon reaching end of layer
        dir    % forward (+1, i.e. increasing index) or backward (-1)
        ref    % interface node for reflection
        trn    % interface node for transmission
    end
    
    methods
        % t_acc is time *prior* to entering layer
        function obj = layer_node(index, dir, t_prev, amp_prev,...
                geom, freq, n_solve, t_cut, a_cut, parent)
            
            prop = node_constants.prop;
            
            obj.index = index; obj.dir = dir; obj.parent = parent;
            obj.num_layers = numel(geom);
            
            % calculate new time delay
            n = geom(index).n_func(freq, n_solve);
            d = geom(index).d;
            dt = ((real(n)*d)/node_constants.c)*1e12;
            t_acc = t_prev + dt;
            obj.t_acc = t_acc;
            obj.tf = prop(freq, d, n);
            
            % calculate amplitude
            amp = amp_prev*abs(prop(freq, d, n));
            obj.amp = amp;
            
            into = index + dir;
            
            % add reflection/transmission if we haven't reached time or 
            % amplitude cut offs
            if (t_acc < t_cut) && (amp > a_cut)
                % reflection
                if index ~= 1
                    obj.ref = interface_node(index, into, -1, t_acc, amp,...
                        geom, freq, n_solve, t_cut, a_cut, obj);
                end
                
                % transmission
                if into ~= 1
                    obj.trn = interface_node(index, into, +1, t_acc, amp,...
                        geom, freq, n_solve, t_cut, a_cut, obj);
                end
            end            
        end

        function cs = children(obj)
            cs = [];
            if isa(obj.ref, 'interface_node')
                cs = [cs obj.ref];
            end
            
            if isa(obj.trn, 'interface_node')
                cs = [cs obj.trn];
            end
        end    
        
        function s = to_s(obj)
            s = num2str(obj.index);
        end
    end
end
        