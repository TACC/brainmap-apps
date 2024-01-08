%% runALE_on_perExpTxtFiles
% Author: Jonathan Towne
% Email: townej@uthscsa.edu
%        jonathan@townemdphd.com
%        jonathantowne46@gmail.com
%        jmt8@alumni.rice.edu
% Last edited: November 21st, 2022
%
% This function takes a directory of sleuth-style text files containing
% coordinates for one experiment (or more) and applies the ALE algorithm,
% producing ALE value, P value, and Z score maps as outputs (.nii). These
% outputs are then sorted into sub-folders within the original text file
% directory.
%
% Requirements Variables (SET THESE BEFORE using this function):
%        - jar_dir:  directory containing GingerALE.jar
%        - mask_dir: directory containing mask files
%        - mni_mask: MNI mask file
%        - tal_mask: Talairach mask file
%        - gingerALE_jar: If you renamed the GingerALE jar file then set
%                         the new name here
%
% Instructions for use:
%     Inputs: 
%        - txt_dir:     Directory containing single-experiment text files
%                           (e.g. 'C:\Users\HP\Documents\UTHSCSA\Grad_School\Eslami files\xGTMready_from_Jodie\xGTM\MA_Z_temp\lists\un_filt')
%        - std_space:   Standardized coordinate space
%                           (i.e. 'MNI' or 'TAL')
%     Outputs:
%        - GingerALE produces three nifti files for each experiment's text
%          file. These outputs are initially produced in the directory
%          specified by the first input to the function (txt_dir: specifying
%          the directory that contains the text files). They are then
%          sorted into three respective sub-folders within txt_dir.
%        - ALE_niftis:  (.nii) ALE maps
%        - PVal_niftis: (.nii) P Value maps
%        - Z_niftis:    (.nii) Z maps
%
% Examples
% txt_dir = 'C:\Users\HP\Documents\UTHSCSA\Grad_School\Eslami files\xGTMready_from_Jodie\xGTM\MA_Z_temp\lists\un_filt';
% std_space = 'MNI' or 'TAL'

function runALE_on_perExpTxtFiles(txt_dir,std_space)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Directories
mask_dir           = 'C:\Users\HP\Documents\UTHSCSA\Grad_School\scripts\masks\';
jar_dir            = 'C:\Users\HP\Documents\UTHSCSA\Grad_School\scripts\jars\';
% Mask files
mni_mask           = 'MNI152_wb_dil.nii.gz';
tal_mask           = 'Tal_wb_dil.nii.gz';
% Jar files
gingerALE_jar      = 'GingerALE.jar';
gingerALE_fullPath = strcat(jar_dir,gingerALE_jar);

% Verify necessary files are present
if ~isfile(strcat(mask_dir,mni_mask)), error('MNI mask file not found.\nCheck directory: %s\n',mask_dir);       end
if ~isfile(strcat(mask_dir,tal_mask)), error('Talairach mask file not found.\nCheck directory: %s\n',mask_dir); end
if ~isfile(gingerALE_fullPath),        error('GingerALE jar file not found.\nCheck directory: %s\n',jar_dir);   end

% Handle input arguments
if     nargin < 2,                std_space = 'MNI'; fprintf('No standard space specified. Default: MNI\n');
elseif nargin <1,                 error('Not enough input argments. Please specify a directory as the first input parameter.\n'); end
if     ~isfolder(txt_dir),        error('Invalid directory\n%s\n',txt_dir); end
if     ~strcmp(txt_dir(end),'\'), txt_dir_s = strcat(txt_dir,'\'); else, txt_dir_s=txt_dir; end
if     strcmp(std_space,'MNI'),   mask_file = mni_mask;
elseif strcmp(std_space,'TAL'),   mask_file = tal_mask;
else,                             error('Invalid standard space. Please select ''MNI'' or ''TAL''\n'); 
end

% Full path to mask file
mask_file_fullPath         = strcat(mask_dir,mask_file);

% Identify all text files in the specified input folder directory
txt_dir_s_txt              = strcat(txt_dir_s,'*.txt');
txt_files_in_txt_dir       = dir(txt_dir_s_txt);
txt_files_in_txt_dir_count = length(txt_files_in_txt_dir); % Number of txt files identified

% Check first file for reference space
temp1 = readlines(strcat(txt_files_in_txt_dir(i).folder,'\',txt_files_in_txt_dir(1).name));
if contains(temp1(1),"MNI") && strcmp(std_space,'TAL'), error("Mis-match in reference space:\nText File Reference Space: %s\nSelected Reference Space:%s\n","MNI",std_space);
elseif contains(temp1(1),"Talairach") && strcmp(std_space,'MNI'), error("Mis-match in reference space:\nText File Reference Space: %s\nSelected Reference Space:%s\n","TAL",std_space); end

% Report
fprintf('\nDirectory: \n%s\n',     txt_dir_s)
fprintf('.txt files found: %d\n',  txt_files_in_txt_dir_count)
fprintf('\nReference space: %s\n', std_space)
fprintf('Mask: %s\n',              mask_file)

% Run GingerALE on all the text files in the specified directory
temp_waitbar = waitbar((i-1)/txt_files_in_txt_dir_count,sprintf('Running GingerALE on text file %d/%d',1,txt_files_in_txt_dir_count));
for i = 1:txt_files_in_txt_dir_count
    waitbar((i-1)/txt_files_in_txt_dir_count,temp_waitbar,sprintf('Running GingerALE on text file %d/%d',i,txt_files_in_txt_dir_count));
    cur_text_file          = txt_files_in_txt_dir(i).name;
    cur_folder             = txt_files_in_txt_dir(i).folder;
    cur_text_file_fullPath = strcat(cur_folder,'\',cur_text_file);
    sys_command            = sprintf('java -cp "%s" org.brainmap.meta.getALE2 "%s" -mask="%s"',...
                                     gingerALE_fullPath,...
                                     cur_text_file_fullPath,...
                                     mask_file_fullPath);
    system(sys_command);
end
waitbar(1,temp_waitbar,sprintf('Finished running GingerALE on text files: %d/%d',txt_files_in_txt_dir_count,txt_files_in_txt_dir_count));
pause(2)
close(temp_waitbar)
fprintf('\nFinished running GingerALE on text files: %d/%d\n',txt_files_in_txt_dir_count,txt_files_in_txt_dir_count)

% Directories for sorting outputs
ale_folder               = 'ALE_niftis';
pVal_folder              = 'PVal_niftis';
z_folder                 = 'Z_niftis';
ale_folder_fullPath      = strcat(txt_dir_s,ale_folder);
pVal_folder_fullPath     = strcat(txt_dir_s,pVal_folder);
z_folder_fullPath        = strcat(txt_dir_s,z_folder);
if ~exist(ale_folder_fullPath, 'dir'),  mkdir(ale_folder_fullPath);  end
if ~exist(pVal_folder_fullPath, 'dir'), mkdir(pVal_folder_fullPath); end
if ~exist(z_folder_fullPath, 'dir'),    mkdir(z_folder_fullPath);    end
% General path to GingerALE outputs by type (i.e. ALE, PVal, and Z images)
output_ale_files_dir     = strcat(txt_dir_s,'*_ALE.nii');
output_pVal_files_dir    = strcat(txt_dir_s,'*_PVal.nii');
output_z_files_dir       = strcat(txt_dir_s,'*_Z.nii');

%move
movefile(output_ale_files_dir,  ale_folder_fullPath)
movefile(output_pVal_files_dir, pVal_folder_fullPath)
movefile(output_z_files_dir,    z_folder_fullPath)

end