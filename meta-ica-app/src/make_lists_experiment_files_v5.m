%% make_lists_experiment_files_v2
% Author: Jonathan Towne
% Email: townej@uthscsa.edu
%        jonathan@townemdphd.com
%        jonathantowne46@gmail.com
%        jmt8@alumni.rice.edu
% Last edited: June 1st, 2022
%
% This script takes a Sleuth export text file and reports coordinates that
% are reported redundantly within a paper and exports individual experiment
% text files after no filtering or paper level filtering.
%
% General output format:
%     "MAindex_000000_pap_000000_exp_00_Authorlabel.txt"
%     Naming scheme: 
%        - index:       Overall experiment index 
%                           (e.g. temp_it)
%        - pap:         paper index 
%                           (e.g. final_exp_filt_paper_index(temp_it) )
%        - exp:         experiment index (within-paper) 
%                           (e.g. exp_filt_pap_exp_ind )
%        - Authorlabel: paper/year 
%                           (e.g. final_exp_filt_paper_labels(temp_it) )
%

%% Chunk 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Select the input text file (raw sleuth export) %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% exported by experiment in either %%%%%%%%%%
%%%%%%%%%% Talairach or MNI reference space %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[theFILE, txtpath] = uigetfile('*.txt',"Pick Text File (Sleuth Export)");
cd(txtpath)

%% Import data to TABLE
opts                  = delimitedTextImportOptions("NumVariables", 3);
opts.DataLines        = [1, Inf];                                          % range
opts.Delimiter        = "\t";                                              % delimiter
opts.VariableNames    = ["Reference", "VarName2", "VarName3"];             % column names
opts.VariableTypes    = ["double", "double", "double"];                    % column types
opts.ExtraColumnsRule = "ignore";                                          % file level properties
opts.EmptyLineRule    = "read";                                            % file level properties
opts                  = setvaropts(opts, ["Reference", "VarName2", "VarName3"],...
                                   "ThousandsSeparator", ",");             % variable properties
vbpgingerALEtalexp    = readtable(strcat(txtpath,'\',theFILE), opts);      % import
clear opts                                                                 % clear temp var opts

%% Import data to STRINGS
opts                  = delimitedTextImportOptions("NumVariables", 3);
opts.DataLines        = [1, Inf];                                          % range 
opts.Delimiter        = "\t";                                              % delimiter 
opts.VariableNames    = ["ReferenceTalairach", "VarName2", "VarName3"];    % column names
opts.VariableTypes    = ["string", "string", "string"];                    % column types
opts.ExtraColumnsRule = "ignore";                                          % file level properties
opts.EmptyLineRule    = "read";                                            % file level properties
opts                  = setvaropts(opts, ["ReferenceTalairach", "VarName2", "VarName3"],...
                                   "WhitespaceRule", "preserve");          % variable properties
opts                  = setvaropts(opts, ["ReferenceTalairach", "VarName2", "VarName3"],...
                                   "EmptyFieldRule", "auto");              % variable properties
vbpgingerALEtalexp1   = readmatrix(strcat(txtpath,'\',theFILE), opts);     % import
clear opts                                                                 % clear temp var opts

%% check reference space
reference_split = strsplit(vbpgingerALEtalexp1{1,1},"=");
reference_space = reference_split{2};

%% read all the coordinates into cell array of n x 3 matrices
% each cell is a different experiment with n reported coordinates
the_dims                        = size(vbpgingerALEtalexp);
the_row_dim                     = the_dims(1);
the_col_dim                     = the_dims(2);
last_line_was_NaN               = 0;
count_title_NaNs                = 0;
experiment_cells                = {};
experiment_4thCol               = zeros(size(find(~isnan(vbpgingerALEtalexp{:,1})),1),4); %preallocates matrix to store all coordinates (first three columns) and experiment index (fourth column)
the_labels_subs                 = string();
count_coords                    = 0;                                       %count_noncoords                 = 0;
vbpgingerALEtalexp_indicesOfNaN = find(isnan(vbpgingerALEtalexp{:,1}));

for i = 1:the_row_dim
    cur_row = vbpgingerALEtalexp{i,:};                                     %get current row numbers (non-numbers are NaN)
    
    if isnan(cur_row(1))                                                   % IF current row is not numbers (blank line i.e. missing, or title text)
        if last_line_was_NaN                                               % IF the last line was not numbers (because if it was then the line is missing)
            the_labels_subs = [the_labels_subs;vbpgingerALEtalexp1(i,1)];  %store text labels
        end
        last_line_was_NaN = 1;                                             %on the next iteration, the previous line (on this current iteration) was not numbers  %count_noncoords = count_noncoords + 1; % (count non-coordinate lines for easy record of num coords))
        continue
    else                                                                   % ELSE occurs when current row is interpretable as numbers per reading in of table in vbpgingerALEtalexp
        if last_line_was_NaN                                               % IF indicates first coordinate for an experiment (since previous line was not coordinate numbers)
            count_title_NaNs                   = count_title_NaNs + 1;     %counts the beginning of an experiment as a title count (experiment count essentially) %index_for_indicesOfNaN             = find(vbpgingerALEtalexp_indicesOfNaN>i,1); % finds index for first subsequent NaN line %experiment_cells{count_title_NaNs} = zeros(vbpgingerALEtalexp_indicesOfNaN(index_for_indicesOfNaN)-i,3); 
            experiment_cells{count_title_NaNs} = zeros(vbpgingerALEtalexp_indicesOfNaN(find(vbpgingerALEtalexp_indicesOfNaN>i,1))-i,3); %calculates how many coordinates in the present experiment and pre-allocates accordingly %vbpgingerALEtalexp_indicesOfNaN(index_for_indicesOfNaN)-i;
            experiment_cells_cur_exp_coord     = 0;                        %prepares index for coordinate within current experiment
        end
        last_line_was_NaN = 0;
        experiment_cells_cur_exp_coord=experiment_cells_cur_exp_coord+1;   %experiment-level coordinate index
    end
    
    experiment_cells{count_title_NaNs}(experiment_cells_cur_exp_coord,:) = [cur_row];%stores coordiante in experiment cell array
    count_coords = count_coords + 1;
    experiment_4thCol(count_coords,:) = [cur_row count_title_NaNs];        %stores coordinate in all-coordinate array %experiment_4thCol = [experiment_4thCol; [cur_row count_title_NaNs]];
    
    if ~mod(i,1000)
        clc
        fprintf('Parsing line %d/%d\n',i,the_row_dim)
    end
    
end
clc
fprintf('Parsing line %d/%d\n',i,the_row_dim)

%% Extracts the labels for each of the experiments, corresponding to the cells in the previous chunk
the_labels_subs        = the_labels_subs(2:end);
col_num                = 1;
line_num               = 2;
the_labels_formed      = string(zeros(count_title_NaNs,3));
the_labels_formed(1,1) = the_labels_subs(1);
the_labels_formed(1,2) = the_labels_subs(2);

for i = 3:length(the_labels_subs)
    the_labels_formed(line_num,col_num) = the_labels_subs(i);
    
    if col_num > 2
        the_labels_formed(line_num,col_num-2) = strcat(the_labels_formed(line_num,col_num-2),the_labels_formed(line_num,col_num-1));
        the_labels_formed(line_num,col_num-1) = the_labels_subs(i);
        the_labels_formed(line_num,col_num)   = 0;
        col_num                               = 2; 
    end
    
    if i<length(the_labels_subs)
        if ~isempty(strfind(the_labels_subs(i+1),'// Subjects=')) & ~isempty(strfind(the_labels_subs(i),'// Subjects='))
            continue
        end
    end
    
    if ~isempty(strfind(the_labels_subs(i),'// Subjects=')) 
        col_num  = 1;
        line_num = line_num+1;
    else
        col_num  = col_num+1;
    end
end

%% This is an ugly method for handling poorly stored data
temp_search = strfind(the_labels_formed(:,1),"// Subjects=");
temp_index  = false(1, numel(temp_search));

for k = 1:numel(temp_search)
    temp_index(k) = ~isempty(temp_search{k} == 1);
end

delthese               = find(temp_index);
the_labels_formed_temp = the_labels_formed;

if ~isempty(delthese)
    the_labels_formed_temp(delthese-1,2) = the_labels_formed_temp(delthese,1);
    the_labels_formed_fixed              = the_labels_formed_temp(setdiff(1:numel(temp_search),delthese),:);
else
    the_labels_formed_fixed              = the_labels_formed_temp;
end

%% restructure for output - handles string formatting
size_the_labels_formed = size(the_labels_formed_fixed);
clean_out              = the_labels_formed_fixed;
clean_out2             = clean_out;

for i = 1:size_the_labels_formed(1)
    temp_sub        = strsplit(clean_out(i,2),"// Subjects=");
    clean_out(i,3)  = temp_sub(2);
    temp_lab        = strsplit(clean_out(i,1),"// ");
    temp_lab2       = strsplit(temp_lab(2),": ");
    clean_out(i,1)  = temp_lab2(1);
    clean_out(i,2)  = temp_lab2(2);
    temp_sub        = strsplit(clean_out2(i,2),"// Subjects=");
    clean_out2(i,3) = temp_sub(2);
    temp_lab        = strsplit(clean_out2(i,1),"// ");
    clean_out2(i,1) = temp_lab(2);
end

%% ID within-paper coordinates redundancy
unique_paper_array  = unique(clean_out(:,1));
paper_index         = zeros(1,length(clean_out(:,1)));
[u_dup,I_dup,J_dup] = unique(experiment_4thCol(:,1:3), 'rows', 'first');
hasDuplicates       = size(u_dup,1) < size(experiment_4thCol(:,1:3),1);
ixDupRows           = setdiff(1:size(experiment_4thCol(:,1:3),1), I_dup);
dupRowValues        = experiment_4thCol(ixDupRows,:);
dup_exp_nums        = unique(experiment_4thCol(ixDupRows,4));
questionable_papers = unique(clean_out(dup_exp_nums,1));
suspicious_papers   = [];
count_dup_coords    = 0;
count_dup_papes     = 0;

for temp_it = 1:length(paper_index)
    paper_index(temp_it) = find(strcmp(clean_out(temp_it,1),unique_paper_array));
end

for temp_it = 1:length(questionable_papers)
    temp_coords = [];
    cur_ques    = questionable_papers(temp_it);
    cur_qexps   = find(strcmp(cur_ques,clean_out(:,1)));
    
    for temp_it2 = 1:length(cur_qexps)
        temp_coords = [temp_coords;experiment_cells{cur_qexps(temp_it2)}];
    end
    
    [u_sus,I_sus,J_sus] = unique(temp_coords, 'rows', 'first');
    
    if size(u_sus,1) < size(temp_coords,1)
        suspicious_papers = [suspicious_papers; cur_ques];
        ixDupRows_sus     = setdiff(1:size(temp_coords,1), I_sus);
        dupRowValues_sus  = temp_coords(ixDupRows_sus,:);
        disp(cur_ques)
        fprintf("Number of cooordinate duplicates: %d\n",length(dupRowValues_sus))
        disp(sortrows(dupRowValues_sus,1))
        count_dup_papes   = count_dup_papes  + 1;
        count_dup_coords  = count_dup_coords + size(dupRowValues_sus,1);
    end
end
fprintf("~~~~~~~~~~~~~~~~~~~Summary~~~~~~~~~~~~~~~~~~~\n")
fprintf("%d papers with duplicate coordinates.\n",count_dup_papes)
fprintf("%d total within-paper coordinate duplicates.\n",count_dup_coords)
fprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n")

%% export experiment-filtered bmaps
sus_paper_cells               = {};                                        %create cell array for indices of experiments belonging to suspicious papers
dlgTitle                      = 'Experiment-filter Export';
dlgQuestion                   = 'Do you wish to export experiment-filtered text files?';
choice                        = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'No');
tic
pap_filt_file_count           = 0;
pap_filt_coord_count          = 0;   
pap_filt_coord_count_withreps = 0;

for temp_it = 1:length(suspicious_papers)
    sus_paper_cells{temp_it} = find(strcmp(suspicious_papers(temp_it),clean_out(:,1)));
end

if strcmpi(choice, 'Yes')
    outdir = uigetdir('Select Output Directory');
    cd(outdir)
    final_exp_filt_paper_labels     = strings();
    final_exp_filt_experiment_cells = {};
    final_exp_filt_paper_index      = [];
    
    for temp_it = 1:length(suspicious_papers)                              % FOR loop through SUSPICIOUS PAPERS
        temp_expfilt_current_paper = suspicious_papers(temp_it);           %current suspicious paper
        temp_expfilt_indices       = sus_paper_cells{temp_it};             %current indices of experiment_cells
        temp_num_exps_for_cur_pap  = length(temp_expfilt_indices);         %initial number of experiments for current paper
        temp_sus_coord_cells       = {};
        temp_sus_coord_mat_combo   = zeros(0,3);
        
        for temp_it2 = 1:temp_num_exps_for_cur_pap                         % FOR loop through to extract the experiments' coordinates for the current paper corresponding to indices in temp_expfilt_indices store in temp cell array temp_sus_coord_cells
            temp_sus_coord_cells{temp_it2} = experiment_cells{temp_expfilt_indices(temp_it2)};
            temp_sus_coord_mat_combo       = [temp_sus_coord_mat_combo;temp_sus_coord_cells{temp_it2}];%combine all coordinates
        end
        
        [u_expfilt,I_expfilt,J_expfilt] = unique(temp_sus_coord_mat_combo, 'rows', 'first');%find duplicate coordinates and store in n x 3 matrix
        ixDupRows_expfilt               = setdiff(1:size(temp_sus_coord_mat_combo,1), I_expfilt);
        dupRowValues_expfilt            = temp_sus_coord_mat_combo(ixDupRows_expfilt,:);
        
        for temp_it2 = 1:size(dupRowValues_expfilt,1)                      % FOR loop through duplicate coordinates
            cur_dup_coord = dupRowValues_expfilt(temp_it2,:);              %current duplicate coordinate
            temp_inds_for_dups_in_temp_sus_coord_cells = [];               %find which cells in temp_sus_coord_cells contain the duplicate
            for temp_it3 = 1:length(temp_sus_coord_cells)                  % FOR repeated for length(temp_sus_coord_cells) which is number of experiments for the paper (this will decrease with filtering)
                temp_temp_sus_coord = temp_sus_coord_cells{temp_it3};      %extract the temp_it3'th matrix from temp_sus_coord_cells
                if any(ismember(temp_temp_sus_coord,cur_dup_coord,'rows')) % IF the temp_it3'th cell contains the duplicate row, the index is save for combination
                    temp_inds_for_dups_in_temp_sus_coord_cells = [temp_inds_for_dups_in_temp_sus_coord_cells temp_it3];
                end
            end
            
            %go through cells in temp_sus_coord_cells containing the
            %temp_it2'th duplicate coordinate cur_dup_coord and combine and 
            %remove coordinate and combine --> reset the temp_sus_coord_cells
            if length(temp_inds_for_dups_in_temp_sus_coord_cells) == 1%instance of duplicate internal to single experiment
                temp_sus_coord_cells{temp_inds_for_dups_in_temp_sus_coord_cells} = ...
                    unique(temp_sus_coord_cells{temp_inds_for_dups_in_temp_sus_coord_cells},'rows');
            else
                for temp_it3 = 2:length(temp_inds_for_dups_in_temp_sus_coord_cells)
                    %combine all experiment cells' containing the
                    %temp_it2'th duplicate coordinate cur_dup_coord
                    %and combine those cells' matrices (in temp_sus_coord_cells)
                    temp_sus_coord_cells{temp_inds_for_dups_in_temp_sus_coord_cells(1)} = ...
                        [temp_sus_coord_cells{temp_inds_for_dups_in_temp_sus_coord_cells(1)}; ...
                        temp_sus_coord_cells{temp_inds_for_dups_in_temp_sus_coord_cells(temp_it3)}];
                end
                temp_sus_coord_cells{temp_inds_for_dups_in_temp_sus_coord_cells(1)} = ...
                    unique(temp_sus_coord_cells{temp_inds_for_dups_in_temp_sus_coord_cells(1)},'rows');%remove duplicates internal to combo
                temp_sus_coord_cells(temp_inds_for_dups_in_temp_sus_coord_cells(2:end))=[];% delete the cells that have been combined with the first remove duplicates internal to combo
            end                                                            % loop again for each duplicate coordinate contained
            
        end                                                                %complete with all duplicates contained within current paper's experiments
        temp_new_exps_for_cur_paper     = length(temp_sus_coord_cells);    %new number of experiments for the paper temp_expfilt_current_paper
        
        if temp_it>1                                                       % IF store the papers' final experiments (string array for names final_exp_filt_paper_labels
            final_exp_filt_paper_labels = [final_exp_filt_paper_labels;repmat(temp_expfilt_current_paper,temp_new_exps_for_cur_paper,1)];
        else
            final_exp_filt_paper_labels = repmat(temp_expfilt_current_paper,temp_new_exps_for_cur_paper,1);
        end
        
        final_exp_filt_experiment_cells = [final_exp_filt_experiment_cells;temp_sus_coord_cells']; %store temp_sus_coord_cells concatenated onto a final final_exp_filt_experiment_cells
        final_exp_filt_paper_index      = [final_exp_filt_paper_index;repmat(temp_it,temp_new_exps_for_cur_paper,1)];%store new paper index
    end                                                                    %done fixing all suspicious papers
    
    index_for_last_sus_paper = max(final_exp_filt_paper_index);            %first
    index_for_non_sus_papers = index_for_last_sus_paper + 1;
    
    try                                                                    %setdiff for unique papers vs suspicious papers --> gives non-sus papers
        non_suspicious_papers = setdiff(unique_paper_array,suspicious_papers);
    catch
        disp("No suspicious papers found")
    end
    
    non_sus_paper_cells = {};
    for temp_it = 1:length(non_suspicious_papers)
        cur_NONsus_paper = non_suspicious_papers(temp_it);
        %indices of non suspicious paper's experiments --> use to index experiment_cells
        % i.e. get indices for current not suspicious paper (to index experiment_cells)
        non_sus_paper_cells{temp_it}            = find(strcmp(non_suspicious_papers(temp_it),clean_out(:,1)));
        temp_num_NONsus_exps_for_cur_nonsus_pap = length(non_sus_paper_cells{temp_it});
        final_exp_filt_experiment_cells         = [final_exp_filt_experiment_cells;...
            experiment_cells(non_sus_paper_cells{temp_it})'];              %store experiments
        final_exp_filt_paper_labels             = [final_exp_filt_paper_labels;...
            repmat(cur_NONsus_paper,temp_num_NONsus_exps_for_cur_nonsus_pap,1)];%store paper labels
        final_exp_filt_paper_index              = [final_exp_filt_paper_index;...
            repmat(index_for_non_sus_papers,temp_num_NONsus_exps_for_cur_nonsus_pap,1)];%store paper index
        index_for_non_sus_papers                = index_for_non_sus_papers + 1;
    end
    
    count_cords_exp_filt       = 0;
    exp_filt_final_num_exps    = size(final_exp_filt_experiment_cells,1);  %final number of experiments
    header_Tal                 = [strcat("// Reference=",reference_space) "" ""];%beginning each file
    %omnibus file (like GingerALE export). I apologize profusely for not preallocating :(
    %populate first line of omnibus file (like GingerALE export)
    exp_filt_ALL_will_be_table = header_Tal;
    
    for temp_it = 1:exp_filt_final_num_exps                                % FOR export all text files for experiments
        exp_filt_cur_pape_for_filename = final_exp_filt_paper_labels(temp_it);
        cur_pap_ind_exp_filt           = final_exp_filt_paper_index(temp_it);
        
        if temp_it == 1                                                    % IF statement creates temporary counter for within-paper experiments
            exp_filt_pap_exp_ind = 1;
        elseif final_exp_filt_paper_index(temp_it) == final_exp_filt_paper_index(temp_it-1)
            exp_filt_pap_exp_ind = exp_filt_pap_exp_ind+1;
        else
            exp_filt_pap_exp_ind = 1;
        end
        
        exp_filt_temp_exp_coordsss = ...
            unique(final_exp_filt_experiment_cells{temp_it},'rows');       %current experiment label and coordinates
        exp_filt_temp_exp_labellll = ...
            strcat("// ",final_exp_filt_paper_labels(temp_it),": Experiment ",num2str(exp_filt_pap_exp_ind));
        count_cords_exp_filt       = ...
            count_cords_exp_filt + size(exp_filt_temp_exp_coordsss,1);     %count coordinates
        
        %temporary single experiment file stored as exp_filt_file_temp. populate this single experiment array
        %[strcat("// Reference=",reference_space) "" ""]
        %[strcat(final_exp_filt_paper_labels(temp_it),": Experiment ",num2str(exp_filt_pap_exp_ind)) "" ""]
        %[final_exp_filt_experiment_cells{temp_it}]
        exp_filt_file_temp         = [header_Tal;...
                                      [exp_filt_temp_exp_labellll "" ""];...
                                      ["// Subjects=4" "" ""];...
                                      string(exp_filt_temp_exp_coordsss)];
        %add experiment to large omnibus array starting at row 2 (but only one header at top, so that was added previously above before the for loop). an extra line is added to separate experiments in accordance with normal GingerALE's experiment-wise export format
        exp_filt_ALL_will_be_table = [exp_filt_ALL_will_be_table;exp_filt_file_temp(2:end,:);"" "" ""];
        %change single experiment array (exp_filt_file_temp) into a table and export
        exp_filt_file_TABLE_temp   = table(exp_filt_file_temp);
        
        %export table to exp file 
        %"MAindex_000000_pap_000000_exp_00_Authorlabel.txt"
        %Naming scheme: 
        %   - index: Overall experiment index
        %           temp_it
        %   - pap: paper index
        %           final_exp_filt_paper_index(temp_it)
        %   - exp: experiment index (within-paper)
        %           exp_filt_pap_exp_ind
        %   - Authorlabel: paper/year
        %           final_exp_filt_paper_labels(temp_it)
        temp_label_exp_filt_filename = strsplit(exp_filt_cur_pape_for_filename," ");
        spec_label_exp_filt_filename = strcat(temp_label_exp_filt_filename(1),temp_label_exp_filt_filename(length(temp_label_exp_filt_filename)));
        cur_label_exp_filt_filename  = spec_label_exp_filt_filename;
        
        %handle file name indices in accordance with labels above
        
        %Overall experiment index
        if temp_it<10
            cur_ind_string = strcat("00000",num2str(temp_it));
        elseif temp_it<100
            cur_ind_string = strcat("0000",num2str(temp_it));
        elseif temp_it<1000
            cur_ind_string = strcat("000",num2str(temp_it));
        elseif temp_it<10000
            cur_ind_string = strcat("00",num2str(temp_it));
        elseif temp_it<100000
            cur_ind_string = strcat("0",num2str(temp_it));
        else
            cur_ind_string = num2str(temp_it);
        end
        
        %Paper index
        if cur_pap_ind_exp_filt<10
            cur_pap_string = strcat("00000",num2str(cur_pap_ind_exp_filt));
        elseif cur_pap_ind_exp_filt<100
            cur_pap_string = strcat("0000",num2str(cur_pap_ind_exp_filt));
        elseif cur_pap_ind_exp_filt<1000
            cur_pap_string = strcat("000",num2str(cur_pap_ind_exp_filt));
        elseif cur_pap_ind_exp_filt<10000
            cur_pap_string = strcat("00",num2str(cur_pap_ind_exp_filt));
        elseif cur_pap_ind_exp_filt<100000
            cur_pap_string = strcat("0",num2str(cur_pap_ind_exp_filt));
        else
            cur_pap_string = num2str(cur_pap_ind_exp_filt);
        end
        
        %Eperiment index (within-paper)
        if exp_filt_pap_exp_ind<10
            cur_exp_string = strcat("0",num2str(exp_filt_pap_exp_ind));
        else
            cur_exp_string = num2str(exp_filt_pap_exp_ind);
        end
        
        exp_filt_final_temp_filename = strcat("MAindex_",cur_ind_string,...
            "_pap_",cur_pap_string,...
            "_exp_",cur_exp_string,"_",...
            cur_label_exp_filt_filename,".txt");
        writetable(exp_filt_file_TABLE_temp,exp_filt_final_temp_filename,...
            'Delimiter','\t','WriteVariableNames',false);
    end
    
    exp_filt_pap_filt_pap_count   = max(final_exp_filt_paper_index);
    exp_filt_pap_filt_file_count  = exp_filt_final_num_exps;
    exp_filt_pap_filt_coord_count = count_cords_exp_filt;
    
    cd ..
    
    %export one combined text file for exp_filt_file_TABLE_temp
    exp_filt_omnibus_filename = strcat("expFiltered_omnibus_",num2str(exp_filt_pap_filt_pap_count),...
        "papers_",num2str(exp_filt_pap_filt_file_count),...
        "exps_"  ,num2str(exp_filt_pap_filt_coord_count),"coords.txt");
    writetable(table(exp_filt_ALL_will_be_table),exp_filt_omnibus_filename,...
        'Delimiter','\t','WriteVariableNames',false);
    
    cd(txtpath)
    fprintf("~~~~~~~~~~~Experiment-filtered Export Summary~~~~~~~~~~~\n")
    fprintf("Experiment-filtered files exported: %d\n"   ,exp_filt_pap_filt_file_count)
    fprintf("Filtered coordinates exported:      %d\n"   ,exp_filt_pap_filt_coord_count)
    fprintf("Average coordinates per experiment: %1.1f\n",exp_filt_pap_filt_coord_count/(exp_filt_pap_filt_file_count+eps))
    fprintf("Total Papers:                       %d\n"   ,exp_filt_pap_filt_pap_count)
    fprintf("Average coordinates per paper:      %1.1f\n",exp_filt_pap_filt_coord_count/(exp_filt_pap_filt_pap_count+eps))
    fprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n")
end
toc

%% export paper-filtered bmaps
dlgTitle                      = 'Paper-filter Export';
dlgQuestion                   = 'Do you wish to export paper-filtered text files?';
choice                        = questdlg(dlgQuestion,dlgTitle,'Yes','No','No');
pap_filt_file_count           = 0;
pap_filt_coord_count          = 0;
pap_filt_coord_count_withreps = 0;

if strcmpi(choice, 'Yes')
    outdir = uigetdir('Select Output Directory');
    cd(outdir)
    
    for temp_it=1:length(unique_paper_array)
        cur_pape              = unique_paper_array(temp_it);
        temp_exp_cell_indices = find(paper_index==temp_it);
        temp_pap_filt_coords  = [];
        temp_label            = strsplit(cur_pape," ");
        spec_label            = strcat(temp_label(1),temp_label(length(temp_label)));
        cur_label             = spec_label;
        
        for temp_it2 = temp_exp_cell_indices
            temp_pap_filt_coords = [temp_pap_filt_coords;experiment_cells{temp_it2}];
        end
        
        pap_filt_coord_count_withreps = pap_filt_coord_count_withreps + size(temp_pap_filt_coords,1);
        temp_pap_filt_coords_noReps   = unique(temp_pap_filt_coords,'rows');
        pap_filt_coord_count          = pap_filt_coord_count + size(temp_pap_filt_coords_noReps,1);
        cur_pap_table                 = table([strcat("// Reference=",reference_space) "" "";
                                              [strcat("// ",cur_pape,": All Paper-level Filtered Coordinates") "" ""];
                                              ["// Subjects=4" "" ""];
                                              string(temp_pap_filt_coords_noReps)]);
                                          
        if temp_it<10
            cur_ind_string = strcat("000",num2str(temp_it));
        elseif temp_it<100
            cur_ind_string = strcat("00",num2str(temp_it));
        elseif temp_it<1000
            cur_ind_string = strcat("0",num2str(temp_it));
        else
            cur_ind_string = num2str(temp_it);
        end
        
        writetable(cur_pap_table,strcat('MA_',cur_ind_string,'_',cur_label,'_4sub_PaperFiltered.txt'),'Delimiter','\t','WriteVariableNames',false);
        pap_filt_file_count = pap_filt_file_count+1;
    end
end

cd(txtpath)
fprintf("~~~~~~~~~~~Paper-filtered Export Summary~~~~~~~~~~~\n")
fprintf("Paper-filtered files exported: %d\n",pap_filt_file_count)
fprintf("Total original coordinates:    %d\n",pap_filt_coord_count_withreps)
fprintf("Filtered coordinates exported: %d\n",pap_filt_coord_count)
fprintf("Average coordinates per file:  %1.1f\n",pap_filt_coord_count/(pap_filt_file_count+eps))
fprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n")

%% export unfiltered experiment bmaps
dlgTitle    = 'Unfiltered Experiment-wise Export';
dlgQuestion = 'Do you wish to export unfiltered experiment text files?';
choice      = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'No');

if strcmpi(choice, 'No')
    num_papers = length(unique(clean_out(:,1)));
    num_expers = length(clean_out);
    num_coords = length(experiment_4thCol);
    fprintf("First 10 Experiments: \n\n")
    disp(table(clean_out(1:10,1),clean_out(1:10,2),clean_out(1:10,3),'VariableNames',{'Paper','Experiment','Subjects (n)'}))
    fprintf("~~~~~~Unfilitered Export Summary~~~~~~\n")
    fprintf("Exported     %d text files.\n",0)
    fprintf("Papers:      %d\n",num_papers)
    fprintf("Experiments: %d\n",num_expers)
    fprintf("Coordinates: %d\n",num_coords)
    fprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n")
else
    outdir      = uigetdir('Select Output Directory');
    cd(outdir)
    dlgTitle    = 'Unfiltered Export';
end

i = 0;

if strcmpi(choice, 'Yes')
    bmap_cell_tabs = {};
    last_label     = "";
    cur_label      = "";
    index_label    = 1;
    tot_exps_temp  = size(clean_out);
    tot_exps       = tot_exps_temp(1);
    
    for i = 1:tot_exps
        bmap_cell_tabs{i} = table([strcat("// Reference=",reference_space) "" "";
                                  [strcat("// ",clean_out(i,1),": ", clean_out(i,2)) "" ""];
                                  ["// Subjects=4" "" ""];
            string(experiment_cells{i})]);
        temp_label = strsplit(clean_out(i,1)," ");
        spec_label = strcat(temp_label(1),temp_label(length(temp_label)));
        cur_label  = spec_label;
        cur_ind    = i;
        
        if strcmp(cur_label,last_label)
            index_label = index_label+1;
        else
            index_label = 1;
            last_label  = cur_label;
        end
        
        if cur_ind<10
            cur_ind_string = strcat("000",num2str(cur_ind));
        elseif cur_ind<100
            cur_ind_string = strcat("00",num2str(cur_ind));
        elseif cur_ind<1000
            cur_ind_string = strcat("0",num2str(cur_ind));
        else
            cur_ind_string = num2str(cur_ind);
        end
        
        writetable(bmap_cell_tabs{i},strcat('MA_',cur_ind_string,'_',cur_label,'_4sub.txt'),'Delimiter','\t','WriteVariableNames',false);
        
    end
else
    fprintf("Selected 'No'\n\n")
end

cd(txtpath)

new_num_papers = 1;
for temp_it = 2:length(clean_out(:,1))
    if ~strcmp(clean_out(temp_it,1),clean_out(temp_it-1,1))
        new_num_papers = new_num_papers+1;
    end
end

num_papers = new_num_papers; 
num_expers = length(clean_out);
num_coords = length(experiment_4thCol);
% fprintf("First 10 Experiments: \n\n")
% disp(table(clean_out(1:10,1),clean_out(1:10,2),clean_out(1:10,3),'VariableNames',{'Paper','Experiment','Subjects (n)'}))
fprintf("~~~~~~Unfilitered Export Summary~~~~~~\n")
fprintf("Exported %d text files.\n",i)
fprintf("Papers: %d\n",num_papers)
fprintf("Experiments: %d\n",num_expers)
fprintf("Coordinates: %d\n",num_coords)
fprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n")
