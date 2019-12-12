%% Output formatted json files
% Jacob A. Spies
% 05 Feb 2021

function [] = format_json(struct,filename,path)

    txt = jsonencode(struct);
    
    fmt = regexprep(txt, '{', '{\n');
    fmt = regexprep(fmt, ',', ':\n');
    
    fileID = fopen([path,filename],'w');
    fprintf(fileID,'%s',encoded_input);
    fclose(fileID);

end