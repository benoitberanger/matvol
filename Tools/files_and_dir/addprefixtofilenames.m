function newlist = addprefixtofilenames(filelist,prefix)
% ADDPREFIXTOFILENAMES Adds prefixs to files name.
%
% 1. filelist can be a cell-array where each element is a char-array
% containing a list of file names.
%
% 2. filelist can be a char-array containing a list of file names.
%
% prefix can be char : prefix will be applied to each elements of the
% filelist{i}.
%
% prefix can be cell-array of char : prefix{i} will be applied to each
% elements of the filelist{i}.
%
% note : the 'filelist' will remain a char or a cell, depending on its
% nature.
%

%% Check input arguments

if nargin ~= 2
    error('filelist & prefix must be defined')
end


%% Prepare inputs and outputs format

prefix = cellstr(prefix); % avoid problems of class or dimensions

% If the filelist is char, we want the newlist to also be char
makeitchar = 0;
if ischar(filelist)
    filelist   = cellstr(filelist);
    makeitchar = 1;
end

% Repeat prefix to match filelist size if needed
if numel(prefix) == 1
    prefix = repmat(prefix,size(filelist));
end

if numel(filelist) > numel(prefix)
    error('Dimensions mismatch : if there is N elements in filelist, there must be N prefix, OR juste 1 prefix')
end


%% Add the prefixes

newlist = cell(length(filelist),1);

for i = 1:length(filelist)
    
    wfiles = [];
    
    for line = 1:size(filelist{i},1)
        [pathstr,name,extension] = fileparts( deblank( filelist{i}(line,:) ) );
        wfiles = strvcat(wfiles, fullfile(pathstr,[prefix{i} name extension ]));
    end
    
    newlist{i} = wfiles;
    
end

if makeitchar
    newlist = char(newlist);
end


end % function
