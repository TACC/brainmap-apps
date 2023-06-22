%% make_lists_experiment_files_v2
% Author: Jonathan Towne
% townej@uthscsa.edu
% jonathantowne46@gmail.com
% jmt8@alumni.rice.edu
% Last edited: February 14, 2022
%
% This script takes a Sleuth export text file and reports coordinates that
% are reported redundantly within a paper and exports individual experiment
% text files after no filtering or paper level filtering.
%
% Example input files selected in Chunk 1 (just for dev purposes):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% DONT SHOW THIS FILE ONLINE PLEASE!!! %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% 'diseaseContext_tal_exp.txt' %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% 'diseaseContext_tal_exp_EXPfiltered.txt' %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% ONLY FOR DEVELOPMENT PURPOSES %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ^^^I'll provide a different input example file later that can be made public
%

%% Chunk 1

%addpath('C:\Users\HP\Documents\UTHSCSA\Grad_School\VBP_ICA\NIfTI_20140122')
addpath('C:\Users\HP\Documents\UTHSCSA\Grad_School\VBP_ICA\NIfTI_20140122')
addpath('C:\Users\HP\Documents\MATLAB\spm12')
[theFILE, txtpath] = uigetfile('*.txt',"Pick Text File (Sleuth Export - Talairach Coordinates)");
cd(txtpath)

%% Import data to table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set up the Import Options and import the data %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["ReferenceTalairach", "VarName2", "VarName3"];
opts.VariableTypes = ["double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["ReferenceTalairach", "VarName2", "VarName3"], "ThousandsSeparator", ",");

% Import the data
vbpgingerALEtalexp = readtable(strcat(txtpath,'\',theFILE), opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Clear temporary variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear opts

%% import strings - Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["ReferenceTalairach", "VarName2", "VarName3"];
opts.VariableTypes = ["string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["ReferenceTalairach", "VarName2", "VarName3"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["ReferenceTalairach", "VarName2", "VarName3"], "EmptyFieldRule", "auto");

% Import the data
vbpgingerALEtalexp1 = readmatrix(strcat(txtpath,'\',theFILE), opts);

clear opts

%% read all the coordinates into cell array of n x 3 matrices
% each cell is a different experiment with n reported coordinates

the_dims = size(vbpgingerALEtalexp);
the_row_dim = the_dims(1);
the_col_dim = the_dims(2);
last_line_was_NaN = 0;
count_title_NaNs=0;
experiment_cells = {};
experiment_4thCol = zeros(size(find(~isnan(vbpgingerALEtalexp{:,1})),1),4); %preallocates matrix to store all coordinates (first three columns) and experiment index (fourth column)
%experiment_4thCol = zeros(0,4);

the_labels_subs = string();
count_coords = 0;
%count_noncoords = 0;
vbpgingerALEtalexp_indicesOfNaN = find(isnan(vbpgingerALEtalexp{:,1}));

for i = 1:the_row_dim
    cur_row = vbpgingerALEtalexp{i,:};  %get current row numbers (non-numbers are NaN)
    if isnan(cur_row(1)) % if current row is not numbers (blank line i.e. missing, or title text)
        if last_line_was_NaN % if the last line was not numbers (because if it was then the line is missing)
            the_labels_subs = [the_labels_subs;vbpgingerALEtalexp1(i,1)]; % store text labels
        end
        last_line_was_NaN=1; %on the next iteration, the previous line (on this current iteration) was not numbers
        %count_noncoords = count_noncoords + 1; % (count non-coordinate lines for easy record of num coords))
        continue
    else % occurs when current row is interpretable as numbers per reading in of table in vbpgingerALEtalexp
        if last_line_was_NaN %indicates first coordinate for an experiment (since previous line was not coordinate numbers)
            count_title_NaNs = count_title_NaNs+1; %counts the beginning of an experiment as a title count (experiment count essentially)
            
            %index_for_indicesOfNaN = find(vbpgingerALEtalexp_indicesOfNaN>i,1); % finds index for first subsequent NaN line
            %experiment_cells{count_title_NaNs}=zeros(vbpgingerALEtalexp_indicesOfNaN(index_for_indicesOfNaN)-i,3); 
            
            experiment_cells{count_title_NaNs}=zeros(vbpgingerALEtalexp_indicesOfNaN(find(vbpgingerALEtalexp_indicesOfNaN>i,1))-i,3); 
            
            %vbpgingerALEtalexp_indicesOfNaN(index_for_indicesOfNaN)-i
            %calculates how many coordinates in the present experiment and
            %pre-allocates accordingly
            experiment_cells_cur_exp_coord=0;%prepares index for coordinate within current experiment
        end
        last_line_was_NaN=0;
        experiment_cells_cur_exp_coord=experiment_cells_cur_exp_coord+1; %experiment-level coordinate index
    end
    experiment_cells{count_title_NaNs}(experiment_cells_cur_exp_coord,:)=[cur_row];%stores coordiante in experiment cell array
    count_coords = count_coords + 1;
    experiment_4thCol(count_coords,:) = [cur_row count_title_NaNs];%stores coordinate in all-coordinate array
    %experiment_4thCol = [experiment_4thCol; [cur_row count_title_NaNs]];
    if ~mod(i,1000)
        clc
        fprintf('Parsing line %d/%d\n',i,the_row_dim)
    end
end
clc
fprintf('Parsing line %d/%d\n',i,the_row_dim)

temp_struct = struct('tableRaw',vbpgingerALEtalexp);
temp_struct.stringRaw = vbpgingerALEtalexp1;
temp_struct.experimentX4thCol = experiment_4thCol;
temp_struct.experimentCells = experiment_cells;
save('readinStruct.mat','temp_struct')

%% Extracts the labels for each of the experiments, corresponding to the cells in the previous chunk
the_labels_subs = the_labels_subs(2:end);
col_num=1;
line_num=2;
the_labels_formed = string(zeros(count_title_NaNs,3));
the_labels_formed(1,1)=the_labels_subs(1);
the_labels_formed(1,2)=the_labels_subs(2);
for i = 3:length(the_labels_subs)
    the_labels_formed(line_num,col_num) = the_labels_subs(i);
    if col_num==3
        the_labels_formed(line_num,col_num-2) = strcat(the_labels_formed(line_num,col_num-2),the_labels_formed(line_num,col_num-1));
        the_labels_formed(line_num,col_num-1) = the_labels_subs(i);
        the_labels_formed(line_num,col_num) = 0;
    end
    
    if i<length(the_labels_subs)
        if ~isempty(strfind(the_labels_subs(i+1),'// Subjects')) & ~isempty(strfind(the_labels_subs(i),'// Subjects'))
            continue
        end
    end
    
    if ~isempty(strfind(the_labels_subs(i),'// Subjects')) % && ~isempty(strfind(the_labels_subs(i-2),'// Subjects'))
        col_num=1;
        line_num = line_num+1;
    else
        col_num=col_num+1;
    end
end

%% This is an ugly method for handling poorly stored data
%the_labels_formed_fixed = [the_labels_formed(1:129,:);the_labels_formed(1:131,:)];
%the_labels_formed_fixed(129,2)=the_labels_formed(130,1);

temp_search = strfind(the_labels_formed(:,1),"// Subjects=");
temp_index = false(1, numel(temp_search));
for k = 1:numel(temp_search)
    temp_index(k) = ~isempty(temp_search{k} == 1);
end
delthese = find(temp_index);
the_labels_formed_temp = the_labels_formed;

% the_labels_formed_fixed = the_labels_formed_temp(setdiff(1:numel(temp_search),delthese),:);
if ~isempty(delthese)
    the_labels_formed_temp(delthese-1,2) = the_labels_formed_temp(delthese,1);
    the_labels_formed_fixed = the_labels_formed_temp(setdiff(1:numel(temp_search),delthese),:);
else
    the_labels_formed_fixed = the_labels_formed_temp;
end
% for del_iter = delthese
%     the_labels_formed_temp(del_iter-1,2) = the_labels_formed_temp(del_iter,1);
%     the_labels_formed_fixed = the_labels_formed_temp(setdiff(1:numel(temp_search),delthese),:);
% %     the_labels_formed_fixed = [the_labels_formed_temp(1:(del_iter-1),:);the_labels_formed_temp((del_iter+1):end,:)];
% %     the_labels_formed_fixed(del_iter-1,2)=the_labels_formed_temp(del_iter,1);
%     the_labels_formed_temp = the_labels_formed_fixed;
% end

%% backup
% backup_struct = struct('tableRaw',vbpgingerALEtalexp);
% backup_struct.stringRaw = vbpgingerALEtalexp1;
% backup_struct.theLabelsFormed = the_labels_formed;
% backup_struct.theLabelsFormedFixed = the_labels_formed_fixed;
% backup_struct.experimentX4thCol = experiment_4thCol;
% backup_struct.experimentCells = experiment_cells;
% backup_struct.tempSearch = temp_search;
% backup_struct.tempIndex = temp_index;
% save('readinStruct.mat','backup_struct')

%% restructure for output - handles string formatting

size_the_labels_formed = size(the_labels_formed_fixed);
clean_out = the_labels_formed_fixed;
clean_out2 = clean_out;
for i=1:size_the_labels_formed(1)
    temp_sub = strsplit(clean_out(i,2),"// Subjects=");
    clean_out(i,3) = temp_sub(2);
    temp_lab = strsplit(clean_out(i,1),"// ");
    temp_lab2 = strsplit(temp_lab(2),": ");
    clean_out(i,1) = temp_lab2(1);
    clean_out(i,2) = temp_lab2(2);
    
    temp_sub = strsplit(clean_out2(i,2),"// Subjects=");
    clean_out2(i,3) = temp_sub(2);
    temp_lab = strsplit(clean_out2(i,1),"// ");
    clean_out2(i,1) = temp_lab(2);
end

%% ID within-paper coordinates redundancy
%experiment_4thCol
%experiment_cells
unique_paper_array = unique(clean_out(:,1));
paper_index = zeros(1,length(clean_out(:,1)));
for temp_it = 1:length(paper_index)
    paper_index(temp_it) = find(strcmp(clean_out(temp_it,1),unique_paper_array));
end

[u_dup,I_dup,J_dup] = unique(experiment_4thCol(:,1:3), 'rows', 'first');
hasDuplicates = size(u_dup,1) < size(experiment_4thCol(:,1:3),1);
ixDupRows = setdiff(1:size(experiment_4thCol(:,1:3),1), I_dup);
dupRowValues = experiment_4thCol(ixDupRows,:);

dup_exp_nums = unique(experiment_4thCol(ixDupRows,4));
questionable_papers = unique(clean_out(dup_exp_nums,1));
suspicious_papers = [];
count_dup_coords = 0;
count_dup_papes = 0;
for temp_it = 1:length(questionable_papers)
    temp_coords=[];
    cur_ques = questionable_papers(temp_it);
    cur_qexps = find(strcmp(cur_ques,clean_out(:,1)));
    for temp_it2 = 1:length(cur_qexps)
        temp_coords = [temp_coords;experiment_cells{cur_qexps(temp_it2)}];
    end
    [u_sus,I_sus,J_sus] = unique(temp_coords, 'rows', 'first');
    if size(u_sus,1) < size(temp_coords,1)
        suspicious_papers = [suspicious_papers;cur_ques];
        ixDupRows_sus = setdiff(1:size(temp_coords,1), I_sus);
        dupRowValues_sus = temp_coords(ixDupRows_sus,:);
        disp(cur_ques)
        fprintf("Number of cooordinate duplicates: %d\n",length(dupRowValues_sus))
        disp(sortrows(dupRowValues_sus,1))
        count_dup_papes = count_dup_papes + 1;
        count_dup_coords = count_dup_coords + size(dupRowValues_sus,1);
    end
end

fprintf("~~~~~~~~~~~~~~~~~~~Summary~~~~~~~~~~~~~~~~~~~\n")
fprintf("%d papers with duplicate coordinates.\n",count_dup_papes)
fprintf("%d total within-paper coordinate duplicates.\n",count_dup_coords)
fprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n")

%% export paper-filtered bmaps
dlgTitle    = 'Paper-filter Export';
dlgQuestion = 'Do you wish to export paper-filtered text files?';
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'No');
pap_filt_file_count = 0;
pap_filt_coord_count = 0;
pap_filt_coord_count_withreps = 0;
if strcmpi(choice, 'Yes')
    outdir = uigetdir('Select Output Directory');
    cd(outdir)
    for temp_it=1:length(unique_paper_array)
        cur_pape = unique_paper_array(temp_it);
        temp_exp_cell_indices = find(paper_index==temp_it);
        temp_pap_filt_coords = [];
        for temp_it2 = temp_exp_cell_indices
            temp_pap_filt_coords = [temp_pap_filt_coords;experiment_cells{temp_it2}];
        end
        pap_filt_coord_count_withreps = pap_filt_coord_count_withreps + size(temp_pap_filt_coords,1);
        temp_pap_filt_coords_noReps = unique(temp_pap_filt_coords,'rows');
        pap_filt_coord_count = pap_filt_coord_count + size(temp_pap_filt_coords_noReps,1);
        cur_pap_table = table(["// Reference=Talairach" "" "";
            [strcat("// ",cur_pape,": All Paper-level Filtered Coordinates") "" ""];
            ["// Subjects=4" "" ""];
            string(temp_pap_filt_coords_noReps)]);
        
        temp_label = strsplit(cur_pape," ");
        spec_label = strcat(temp_label(1),temp_label(length(temp_label)));
        cur_label = spec_label;
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
        pap_filt_file_count=pap_filt_file_count+1;
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

dlgTitle    = 'Experiment-wise Export';
dlgQuestion = 'Do you wish to export experiment text files?';
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'No');
if strcmpi(choice, 'No')
    num_papers = length(unique(clean_out(:,1)));
    num_expers = length(clean_out);
    num_coords = length(experiment_4thCol);
    fprintf("First 10 Experiments: \n\n")
    
    disp(table(clean_out(1:10,1),clean_out(1:10,2),clean_out(1:10,3),'VariableNames',{'Paper','Experiment','Subjects (n)'}))
    
    fprintf("~~~~~~~~~~~~Unfilitered Export Summary~~~~~~~~~~~~~\n")
    fprintf("Exported %d text files.\n",0)
    fprintf("Papers: %d\n",num_papers)
    fprintf("Experiments: %d\n",num_expers)
    fprintf("Coordinates: %d\n",num_coords)
    fprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n")
else
    outdir = uigetdir('Select Output Directory');
    cd(outdir)
    dlgTitle    = 'Experiment-wise Export';
    dlgQuestion = 'Are you sure you want to export experiment text files?';
    choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'No');
end




i=0;
if strcmpi(choice, 'Yes')
    
    bmap_cell_tabs = {};
    last_label = "";
    cur_label = "";
    index_label = 1;
    tot_exps_temp = size(clean_out);
    tot_exps = tot_exps_temp(1);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for i=1:tot_exps
        bmap_cell_tabs{i} = table(["// Reference=Talairach" "" "";
            [strcat("// ",clean_out(i,1),": ", clean_out(i,2)) "" ""];
            ["// Subjects=4" "" ""];
            string(experiment_cells{i})]);
        temp_label = strsplit(clean_out(i,1)," ");
        spec_label = strcat(temp_label(1),temp_label(length(temp_label)));
        cur_label = spec_label;
        if strcmp(cur_label,last_label)
            index_label = index_label+1;
        else
            index_label = 1;
            last_label = cur_label;
        end
        cur_ind=i;
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
new_num_papers=1;
for temp_it = 2:length(clean_out(:,1))
    if ~strcmp(clean_out(temp_it,1),clean_out(temp_it-1,1))
        new_num_papers = new_num_papers+1;
    end
end

num_papers = new_num_papers; %length(unique(clean_out(:,1)));
num_expers = length(clean_out);
num_coords = length(experiment_4thCol);
% fprintf("First 10 Experiments: \n\n")
% 
% disp(table(clean_out(1:10,1),clean_out(1:10,2),clean_out(1:10,3),'VariableNames',{'Paper','Experiment','Subjects (n)'}))

fprintf("~~~~~~~~~Experiment-filtered Export Summary~~~~~~~~\n")
fprintf("Exported %d text files.\n",i)
fprintf("Papers: %d\n",num_papers)
fprintf("Experiments: %d\n",num_expers)
fprintf("Coordinates: %d\n",num_coords)
fprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n")