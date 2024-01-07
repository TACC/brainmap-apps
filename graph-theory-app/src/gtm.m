function gtm(gtm_folder_path,sleuth_text_file,gtm_radius,ale_thresh,filter_choice)
% Author: Jonathan Towne
% Email: townej@uthscsa.edu
%        jmt8@alumni.rice.edu
% Last edited: January 20th, 2023

%% 0. Define the GTM directory (full path) and the name of your Sletuh text file
% gtm_folder_path   = 'C:\Users\HP\Documents\xGTM_portal';	% Set the directory
% sleuth_text_file  = 'mtleExample_sleuthFile.txt';         % Set the name of your Sleuth text file
cd(gtm_folder_path)
%% 1. Create the unthresholded ALE image and save it to the GTM directory
mask_dir               = strcat(gtm_folder_path,'masks/');
jar_dir                = strcat(gtm_folder_path,'jars/');
cur_text_file_fullPath = strcat(gtm_folder_path,sleuth_text_file);
if ~exist(cur_text_file_fullPath,'file')
    error('Sleuth text file not found in the GTM directory. Please check the sleuth_text_file name and gtm_folder_path')
end
% Mask files
mni_mask               = 'MNI152_wb_dil.nii.gz';
tal_mask               = 'Tal_wb_dil.nii.gz';
temp1 = readlines(cur_text_file_fullPath);
if contains(temp1(1),"MNI")
    mask_file_fullPath = strcat(mask_dir,mni_mask);
elseif contains(temp1(1),"Talairach") 
    mask_file_fullPath = strcat(mask_dir,tal_mask);
else
    error('Image space not recognized')
end
% Jar files
gingerALE_jar          = 'GingerALE.jar';
gingerALE_fullPath     = strcat(jar_dir,gingerALE_jar);

sys_command            = sprintf('java -cp "%s" org.brainmap.meta.getALE2 "%s" -mask="%s"',...
                                     gingerALE_fullPath,...
                                     cur_text_file_fullPath,...
                                     mask_file_fullPath);
system(sys_command);

%% 2. Compute the peaks / roi clusters for your unthresholded ALE image
genName     = strsplit(sleuth_text_file,'.');
img_ale     = strcat(genName{1},'_ALE.nii');                              % Set the name of the unthresholded ALE image
%gtm_radius  = 6;                                                          % Set the ROI radius
fn_out      = strcat(genName{1},'_',num2str(gtm_radius),'mm_radius.nii'); % Set the output nifti file name
fn_out1     = strcat(genName{1},'_',num2str(gtm_radius),'mm_radius.mat'); % Set the output mat file name
%ale_thresh  = 75;                                                         % Set percentage %% ALE threshold
crea_roi_cluster(img_ale,gtm_radius,fn_out,fn_out1,ale_thresh);  

%% 3. Save the coordinates for later
coord_file_name = strcat(genName{1},'_',num2str(gtm_radius),'mm_radius_coordinates.txt');            % Set coordinate file name (this is not the Sleuth text file, it will be created and will contain just the coordinates)
coords          = load(fn_out1,'-ascii');
dlmwrite(coord_file_name, coords, 'delimiter', '\t')

%% 4. Create per-experiment .txt files
%filter_choice = 0;	% No filtering
%filter_choice = 1;	% Experiment-level filtering
%filter_choice = 2;	% Paper-level filtering
[outdir, std_space_in] = make_per_experiment_TXTfiles_for_GTM(sleuth_text_file, gtm_folder_path, filter_choice);

%% 5. Apply GingerALE to the text files
runALE_on_perExpTxtFile_dir(outdir,gtm_folder_path,std_space_in)

%% 6. Compute co-activation between your nodes
file_name_without_extension = strcat(genName{1},'_',num2str(gtm_radius),'mm_radius_creaCoact');		% Set the coactivation output file name
crea_coact_mat(fn_out,file_name_without_extension);

%% 7. Compute Patel's k
load(strcat(file_name_without_extension,'.mat'),'mat_coat')
output_file_name_dotmat = strcat(genName{1},'_',num2str(gtm_radius),'mm_radius_patel_struct.mat');   % Set the name of the .mat file that will store the struct containing your Patel statistics 
patel(mat_coat,output_file_name_dotmat);                    % Additional inputs can be provided to adjust montecarlo & patel metrics

%% 8. Plot the results
gtm_folder_path   = string(gtm_folder_path);
gtm_mat_file      = fn_out1;
coord_text_file   = coord_file_name;
coact_mat_file    = strcat(file_name_without_extension,'.mat');
patel_struct_file = output_file_name_dotmat;
plot_gtm_example(gtm_folder_path,gtm_mat_file,coord_text_file,coact_mat_file,patel_struct_file)
exit
end

