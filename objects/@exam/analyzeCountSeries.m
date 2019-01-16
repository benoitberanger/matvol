function varargout = analyzeCountSeries( examArray, par )
% ANALYZECOUNTSERIES regroup exam by number of series.
%
% Syntax : [best, more, less, out] = analyzeCountSeries(examArray, par)
%                                    analyzeCountSeries(examArray, par)
%          [best, more, less, out] = analyzeCountSeries(examArray)
%                                    analyzeCountSeries(examArray)
% All outputs are @exam arrays
%
% See also compareOrientation

%% Check input arguments

if ~exist('par','var')
    par = ''; % for defpar
end

defpar.serie_regex = '.*';
defpar.N           = 1; % keep N best groups

defpar.verbose     = 1;
defpar.pct         = 0; % Parallel Computing Toolbox
defpar.redo        = 0; % read again the json files & update @serie.sequence

par = complet_struct(par,defpar);


%% Read json parameters & count series

%TableParam = examArray.getSerie(par.serie_regex).json2table(par);
par.redo = 0; % don't need anymore for he next json2table

[TableSer, Group] = examArray.countSeries(par.serie_regex);


%% Pickup the best group

% OLD Hypothesis : the largest group in 'countSeries' is the "right" group, the one with the good number of sequences
% New hypothesis : keep N best groups

nGroups = length(Group);
N = min(nGroups,par.N);

counter = 0;

for iGroup = nGroups : -1 : nGroups-N+1
    
    counter = counter + 1;
    
    bestGroup = Group(iGroup);
    
    bestGroup_name = [bestGroup.name];
    examArray_best{counter} = examArray.getExam(bestGroup_name);
    
    %TableParam_best = examArray_best{counter}.getSerie(par.serie_regex).json2table(par);
    TableSer_best   = examArray_best{counter}.countSeries(par.serie_regex);
    
    list_exam_best = {examArray_best{counter}.name}';
    summary_best{counter} = table2struct(TableSer_best(end,2:end));
    
    
    %% Best group info
    
    if par.verbose > 0
        fprintf('\n')
        cprintf('*comment','Largest group is N = %d/%d (%d %%)\n', bestGroup.N, length(examArray), round(100*bestGroup.N/length(examArray)))
        disp(summary_best{counter})
        fprintf('\n')
    end
    
    if par.verbose > 1
        cprintf('_comment','List for subjects\n')
        cprintf('comment','%s\n',list_exam_best{:})
        fprintf('\n')
    end
    
    list_sequence_best = fieldnames(summary_best{counter});
    list_exam_name     = TableSer.Properties.RowNames;
    
    
    %% Exams with MORE than expected series (such as 2 T1w instead of 1)
    
    examArray_more{counter} = exam.empty;
    for seq = 1 : length(list_sequence_best)
        index = TableSer.(list_sequence_best{seq}) > summary_best{counter}.(list_sequence_best{seq});
        list_more = list_exam_name(index);
        if par.verbose > 1
            cprintf('key','Exam with '), cprintf('_key','more '), cprintf('*key','%s ',list_sequence_best{seq}), cprintf('key',', N = %d (%d %%)\n',sum(index), round(100*sum(index)/length(examArray)))
            if par.verbose > 1
                fprintf('%s\n',list_more{:})
            end
            fprintf('\n')
        end
        if ~isempty(list_more)
            examArray_more{counter} = examArray_more{counter}.removeTag(cellstr2regex(list_more,1)) + examArray.getExam([list_more;{''}]);
        end
    end
    
    
    %% Exams with LESS than expected series (such as 0 T1w instead of 1)
    
    examArray_less{counter} = exam.empty;
    for seq = 1 : length(list_sequence_best)
        index = TableSer.(list_sequence_best{seq}) < summary_best{counter}.(list_sequence_best{seq});
        list_less = list_exam_name(index);
        if par.verbose > 1
            cprintf('err','Exam with '), cprintf('_err','less '), cprintf('*err','%s ',list_sequence_best{seq}), cprintf('err',', N = %d (%d %%)\n',sum(index), round(100*sum(index)/length(examArray)))
            if par.verbose > 1
                fprintf('%s\n',list_less{:})
            end
            fprintf('\n')
        end
        if ~isempty(list_less)
            examArray_less{counter} = examArray_less{counter}.removeTag(cellstr2regex(list_less,1)) + examArray.getExam([list_less;{''}]);
        end
    end
    
    
    %% Exams with series that are NOT in the "best group" (where does this serie come from ?)
    
    list_sequence     = TableSer.Properties.VariableNames(2:end)';
    list_out_sequence = setxor(list_sequence_best,list_sequence);
    
    examArray_out{counter} = exam.empty;
    for seq = 1 : length(list_out_sequence)
        index = TableSer.(list_out_sequence{seq}); index = logical(index);
        list_out = list_exam_name(index);
        if par.verbose > 1
            cprintf('magenta','Exam with '), cprintf('*magenta','%s ',list_out_sequence{seq}), cprintf('magenta',', N = %d (%d %%)\n',sum(index), round(100*sum(index)/length(examArray)))
            if par.verbose > 1
                fprintf('%s\n',list_out{:})
            end
            fprintf('\n')
        end
        if ~isempty(list_out)
            examArray_out{counter} = examArray_out{counter}.removeTag(cellstr2regex(list_out,1)) + examArray.getExam([list_out;{''}]);
        end
    end
    
    
end % iGroup


%% Output

if nargout > 0
    varargout = {};
    if par.N == 1
        varargout{end+1} = examArray_best{1}; % best group
        varargout{end+1} = examArray_more{1}; % MORE than expected
        varargout{end+1} = examArray_less{1}; % LESS than expected
        varargout{end+1} = examArray_out {1}; % ?
        varargout{end+1} = summary_best  {1}; % info
    else
        varargout{end+1} = examArray_best; % best group
        varargout{end+1} = examArray_more; % MORE than expected
        varargout{end+1} = examArray_less; % LESS than expected
        varargout{end+1} = examArray_out ; % ?
        varargout{end+1} = summary_best  ; % info
    end
end


end % function
