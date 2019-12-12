% Takes sample geometry from the input json file and interprets and
% reformats for export in the GUI sample/ref geometry text boxes.

%% Extract geometry from run parameter json file
% Jacob A. Spies
% 03 Feb 2021

function output = tf_interpreter_gui(structure)
    output={};
    for i = 1:length(structure)
        n_temp = structure(i).n;
        if isnumeric(n_temp)
            n_temp = num2str(n_temp);
        end
        output{i,1} = char(sprintf('%s, d=%d , n=%s\n',structure(i).name,structure(i).d,n_temp));
    end
end