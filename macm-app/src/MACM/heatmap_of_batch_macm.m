% function heatmap_of_batch_macm

%% Import fMACM ALE
% filename: C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\fMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_fMACM_macm-ale-samples.txt
opts = delimitedTextImportOptions("NumVariables", 11);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";
% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Import the data
covidHypofMACMmacmalesamples = readtable("C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\fMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_fMACM_macm-ale-samples.txt", opts);
% Clear temporary variables
clear opts

%% Import fMACM PVal
% filename: C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\fMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_fMACM_macm-Pval-samples.txt
opts = delimitedTextImportOptions("NumVariables", 11);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";
% Specify column names and types
opts.VariableNames = ["e34", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "e06"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Import the data
covidHypofMACMmacmPvalsamples = readtable("C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\fMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_fMACM_macm-Pval-samples.txt", opts);
% Clear temporary variables
clear opts

%% Import fMACM Z
% filename: C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\fMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_fMACM_macm-Z-samples.txt
% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 11);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";
% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "nan", "nan1", "nan2", "nan3", "VarName9", "VarName10", "VarName11"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Import the data
covidHypofMACMmacmZsamples = readtable("C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\fMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_fMACM_macm-Z-samples.txt", opts);
% Clear temporary variables
clear opts

%% Import sMACM ALE
% filename: C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\sMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_sMACM_macm-ale-samples.txt
% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 11);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";
% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Import the data
covidHyposMACMmacmalesamples = readtable("C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\sMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_sMACM_macm-ale-samples.txt", opts);
% Clear temporary variables
clear opts

%% Import sMACM PVal
% filename: C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\sMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_sMACM_macm-Pval-samples.txt
% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 11);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";
% Specify column names and types
opts.VariableNames = ["e17", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Import the data
covidHyposMACMmacmPvalsamples = readtable("C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\sMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_sMACM_macm-Pval-samples.txt", opts);
% Clear temporary variables
clear opts

%% Import sMACM Z
% filename: C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\sMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_sMACM_macm-Z-samples.txt
% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 11);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";
% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Import the data
covidHyposMACMmacmZsamples = readtable("C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\sMACM\COVID_hypo\make_sampleNiftis_byRois\covidHypo_sMACM_macm-Z-samples.txt", opts);
% Clear temporary variables
clear opts

%%
temp={covidHypofMACMmacmalesamples,covidHypofMACMmacmPvalsamples,...
    covidHypofMACMmacmZsamples,covidHyposMACMmacmalesamples,...
    covidHyposMACMmacmPvalsamples,covidHyposMACMmacmZsamples};
hypo_coords = csvread("C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\ALEs\COVID hypo\aaaa_vbp_9pap_568sub_24exp_114loc_mni_experiments_manualFILTER_HYPO3_C05_1k_peaks_coordinatesOnly.txt");
hypohyper_coords = csvread("C:\Users\HP\Documents\UTHSCSA\Grad_School\Side_Projects\COVID\0_Sub3_Nature_Neuroscience_v2\ALEs\COVID hypo + hyper\vbp_9pap_568sub_24exp_114loc_mni_experiments_manualFILTER_HYPO3hyper_C05_1k_peaks_coordinatesOnly.txt");

% figure
% heatmap(temp{1}{:,:})
% title('fMACM: ALE Scores'); ylabel('Seed'); xlabel('Target')
% % saveas(gcf,'covid_fMACM_heatmap-ALE_test.png')
% figure
% heatmap(temp{2}{:,:})
% title('fMACM: P Values'); ylabel('Seed'); xlabel('Target')
% % saveas(gcf,'covid_fMACM_heatmap-PVal_test.png')
% figure
% heatmap(temp{3}{:,:})
% title('fMACM: Z Scores'); ylabel('Seed'); xlabel('Target')
% % saveas(gcf,'covid_fMACM_heatmap-Z_test.png')
% figure
% heatmap(temp{4}{:,:})
% title('sMACM: ALE Scores'); ylabel('Seed'); xlabel('Target')
% % saveas(gcf,'covid_sMACM_heatmap-ALE_test.png')
% figure
% heatmap(temp{5}{:,:})
% title('sMACM: P Values'); ylabel('Seed'); xlabel('Target')
% % saveas(gcf,'covid_sMACM_heatmap-PVal_test.png')
% figure
% heatmap(temp{6}{:,:})
% title('sMACM: Z Scores'); ylabel('Seed'); xlabel('Target')
% % saveas(gcf,'covid_sMACM_heatmap-Z_test.png')

%%
%figure
%To-do
% 1. Threshold the matrices stored in temp (and rename that variable...)
%       consider writing a function that you give it the 
%            - matrix
%            - threshold to determine node-node connectivity 
%            - binary input of whether threshold is > or <
%            - coordinates (one in each row of a matrix)
%            - coordinate labels
%            - binary input of whether or not to plot spheres at the coordinates

%% f and s MACM side by side
stat_cell_ind=3;
%stat_cell_ind=6;
thresh_for_stat=1.645;
% thresh_for_stat=1.96;
connect_if_less_than=0;

node_coords = hypo_coords;
scale_vox_2x2x2=1;
sphere_radius = 6;
plt_facecol = [0, 1, 0];

hypo_names={'STG',...
'Hippo.',...
'OFC',...
'OFC',...
'OFC',...
'OFC',...
'ACC',...
'ACC',...
'Amyg.',...
'Parahippo.',...
'STG'};

if connect_if_less_than
    temp_matrix = temp{stat_cell_ind}{:,:}<thresh_for_stat;
else
    temp_matrix = temp{stat_cell_ind}{:,:}>thresh_for_stat;
end

no_auto_edge = ones(size(temp_matrix,1))-eye(size(temp_matrix,1));
plot_k_mat = (temp_matrix | temp_matrix').*no_auto_edge;

macm_fig = figure;
subplot(1,2,1)
%subplot(1,2,2)

G1_temp = graph(plot_k_mat,'omitselfloops');

addpath("C:\Users\HP\Documents\UTHSCSA\Grad_School\Eslami files\xGTMready_from_Jodie\xGTM\")
simpleBrainSurface

hold on
plot(G1_temp,'XData',node_coords(:,1)*scale_vox_2x2x2,...
             'YData',node_coords(:,2)*scale_vox_2x2x2,...
             'ZData',node_coords(:,3)*scale_vox_2x2x2,...
             'NodeLabel',hypo_names);
xlabel("X-Axis")
ylabel("Y-Axis")
zlabel("Z-Axis")

title({'fMACM: Post-COVID Hypometabolism',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})
%title({'sMACM: Post-COVID Hypometabolism',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})

[x_sphere,y_sphere,z_sphere] = sphere;
% sphere_radius = 1.5;
x_sphere2 = x_sphere*sphere_radius;
y_sphere2 = y_sphere*sphere_radius;
z_sphere2 = z_sphere*sphere_radius;

hold off

stat_cell_ind=6;
thresh_for_stat=1.645;
% thresh_for_stat=1.96;
connect_if_less_than=0;

node_coords = hypo_coords;
scale_vox_2x2x2=1;
sphere_radius = 6;
plt_facecol = [0, 1, 0];

if connect_if_less_than
    temp_matrix = temp{stat_cell_ind}{:,:}<thresh_for_stat;
else
    temp_matrix = temp{stat_cell_ind}{:,:}>thresh_for_stat;
end

no_auto_edge = ones(size(temp_matrix,1))-eye(size(temp_matrix,1));
plot_k_mat = (temp_matrix | temp_matrix').*no_auto_edge;

%subplot(1,2,1)
subplot(1,2,2)

G1_temp = graph(plot_k_mat,'omitselfloops');

addpath("C:\Users\HP\Documents\UTHSCSA\Grad_School\Eslami files\xGTMready_from_Jodie\xGTM\")
simpleBrainSurface

hold on
plot(G1_temp,'XData',node_coords(:,1)*scale_vox_2x2x2,...
             'YData',node_coords(:,2)*scale_vox_2x2x2,...
             'ZData',node_coords(:,3)*scale_vox_2x2x2,...
             'NodeLabel',hypo_names);
xlabel("X-Axis")
ylabel("Y-Axis")
zlabel("Z-Axis")

title({'sMACM: Post-COVID Hypometabolism',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})

[x_sphere,y_sphere,z_sphere] = sphere;
% sphere_radius = 1.5;
x_sphere2 = x_sphere*sphere_radius;
y_sphere2 = y_sphere*sphere_radius;
z_sphere2 = z_sphere*sphere_radius;

hold off

%% combo fMACM and sMACM edges on one plot
thresh_for_stat=1.645;
connect_if_less_than=0;
node_coords = hypo_coords;
scale_vox_2x2x2=1;
sphere_radius = 6;
plt_facecol = [0, 1, 0];

stat_cell_ind=3;
if connect_if_less_than
    temp_matrix = temp{stat_cell_ind}{:,:}<thresh_for_stat;
else
    temp_matrix = temp{stat_cell_ind}{:,:}>thresh_for_stat;
end
no_auto_edge = ones(size(temp_matrix,1))-eye(size(temp_matrix,1));
plot_k_mat_fMACM = (temp_matrix | temp_matrix').*no_auto_edge;
plot_k_mat_fMACM_dir = (temp_matrix).*no_auto_edge;


stat_cell_ind=6;
if connect_if_less_than
    temp_matrix = temp{stat_cell_ind}{:,:}<thresh_for_stat;
else
    temp_matrix = temp{stat_cell_ind}{:,:}>thresh_for_stat;
end
no_auto_edge = ones(size(temp_matrix,1))-eye(size(temp_matrix,1));
plot_k_mat_sMACM = (temp_matrix | temp_matrix').*no_auto_edge;
plot_k_mat_sMACM_dir = (temp_matrix).*no_auto_edge;

plot_k_mat = (plot_k_mat_fMACM | plot_k_mat_sMACM).*no_auto_edge;
plot_k_mat_dir = plot_k_mat_fMACM_dir | plot_k_mat_sMACM_dir;

figure
G1_temp = graph(plot_k_mat);

addpath("C:\Users\HP\Documents\UTHSCSA\Grad_School\Eslami files\xGTMready_from_Jodie\xGTM\")
simpleBrainSurface
hypo_names={'STG',...
'Hippo.',...
'OFC',...
'OFC',...
'OFC',...
'OFC',...
'ACC',...
'ACC',...
'Amyg.',...
'Parahippo.',...
'STG'};

hold on
phot_temp = plot(G1_temp,'XData',node_coords(:,1)*scale_vox_2x2x2,...
             'YData',node_coords(:,2)*scale_vox_2x2x2,...
             'ZData',node_coords(:,3)*scale_vox_2x2x2,...
             'NodeLabel',hypo_names);
xlabel("X-Axis")
ylabel("Y-Axis")
zlabel("Z-Axis")

%title({'fMACM: Post-COVID Hypometabolism',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})
%title({'sMACM: Post-COVID Hypometabolism',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})

[x_sphere,y_sphere,z_sphere] = sphere;
% sphere_radius = 1.5;
x_sphere2 = x_sphere*sphere_radius;
y_sphere2 = y_sphere*sphere_radius;
z_sphere2 = z_sphere*sphere_radius;

plot_k_mat_sMACM_notF = plot_k_mat_sMACM & ~plot_k_mat_fMACM;
plot_k_mat_fMACM_notS = plot_k_mat_fMACM & ~plot_k_mat_sMACM;
plot_k_mat_fANDs_MACM = plot_k_mat_fMACM & plot_k_mat_sMACM;

G1_temp_s  = graph(plot_k_mat_sMACM_notF);
G1_temp_f  = graph(plot_k_mat_fMACM_notS);
G1_temp_sf = graph(plot_k_mat_fANDs_MACM);

highlight(phot_temp,G1_temp_s,'EdgeColor','b','LineWidth',1.5)
highlight(phot_temp,G1_temp_f,'EdgeColor','r','LineWidth',1.5)
highlight(phot_temp,G1_temp_sf,'EdgeColor','k','LineWidth',2.5)

hold off

figure
G1_temp_dir = digraph(plot_k_mat_dir);

addpath("C:\Users\HP\Documents\UTHSCSA\Grad_School\Eslami files\xGTMready_from_Jodie\xGTM\")
simpleBrainSurface
hypo_names={'STG',...
'Hippo.',...
'OFC',...
'OFC',...
'OFC',...
'OFC',...
'ACC',...
'ACC',...
'Amyg.',...
'Parahippo.',...
'STG'};

hold on
plot(G1_temp_dir,'XData',node_coords(:,1)*scale_vox_2x2x2,...
             'YData',node_coords(:,2)*scale_vox_2x2x2,...
             'ZData',node_coords(:,3)*scale_vox_2x2x2,...
             'NodeLabel',hypo_names);
xlabel("X-Axis")
ylabel("Y-Axis")
zlabel("Z-Axis")

%title({'fMACM: Post-COVID Hypometabolism',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})
%title({'sMACM: Post-COVID Hypometabolism',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})

[x_sphere,y_sphere,z_sphere] = sphere;
% sphere_radius = 1.5;
x_sphere2 = x_sphere*sphere_radius;
y_sphere2 = y_sphere*sphere_radius;
z_sphere2 = z_sphere*sphere_radius;

hold off


%% single macm plot
% stat_cell_ind=2;
% stat_cell_ind=5;
% thresh_for_stat=0.05;
% connect_if_less_than=1;

% stat_cell_ind=1;
% stat_cell_ind=4;
% thresh_for_stat=0.01;
% thresh_for_stat=0.02;
% connect_if_less_than=0;

stat_cell_ind=3;
stat_cell_ind=6;
thresh_for_stat=1.645;
% thresh_for_stat=1.96;
connect_if_less_than=0;

node_coords = hypo_coords;
scale_vox_2x2x2=1;
sphere_radius = 6;
plt_facecol = [0, 1, 0];

if connect_if_less_than
    temp_matrix = temp{stat_cell_ind}{:,:}<thresh_for_stat;
else
    temp_matrix = temp{stat_cell_ind}{:,:}>thresh_for_stat;
end

plot_k_mat = temp_matrix | temp_matrix';

figure
subplot(1,2,1)
%subplot(1,2,2)

%temp_discon_nodes=[];
%temp_con_nodes = setdiff(1:size(plot_k_mat,1),temp_discon_nodes);
%temp_node_labels = repmat({''},length(temp_con_nodes),1);
%G1_temp = graph(k | k');
G1_temp = graph(plot_k_mat);

addpath("C:\Users\HP\Documents\UTHSCSA\Grad_School\Eslami files\xGTMready_from_Jodie\xGTM\")
simpleBrainSurface

hold on
%plot(G1_temp,'XData',x*scale_vox_2x2x2,'YData',y*scale_vox_2x2x2,'ZData',z*scale_vox_2x2x2);
plot(G1_temp,'XData',node_coords(:,1)*scale_vox_2x2x2,...
             'YData',node_coords(:,2)*scale_vox_2x2x2,...
             'ZData',node_coords(:,3)*scale_vox_2x2x2);

xlabel("X-Axis")
ylabel("Y-Axis")
zlabel("Z-Axis")

%title({'fMACM: Post-COVID Hypometabolism',sprintf('Connectivity: ALE > %s',num2str(thresh_for_stat))})
%title({'sMACM: Post-COVID Hypometabolism',sprintf('Connectivity: ALE > %s',num2str(thresh_for_stat))})
%title({'fMACM: Post-COVID Metabolopathy',sprintf('Connectivity: ALE > %s',num2str(thresh_for_stat))})
%title({'sMACM: Post-COVID Metabolopathy',sprintf('Connectivity: ALE > %s',num2str(thresh_for_stat))})

%title({'fMACM: Post-COVID Hypometabolism',sprintf('Connectivity: p < %s',num2str(thresh_for_stat))})
%title({'sMACM: Post-COVID Hypometabolism',sprintf('Connectivity: p < %s',num2str(thresh_for_stat))})
%title({'fMACM: Post-COVID Metabolopathy',sprintf('Connectivity: p < %s',num2str(thresh_for_stat))})
%title({'sMACM: Post-COVID Metabolopathy',sprintf('Connectivity: p < %s',num2str(thresh_for_stat))})

%title({'fMACM: Post-COVID Hypometabolism',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})
%title({'sMACM: Post-COVID Hypometabolism',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})
%title({'fMACM: Post-COVID Metabolopathy',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})
%title({'sMACM: Post-COVID Metabolopathy',sprintf('Connectivity: Z > %s',num2str(thresh_for_stat))})

[x_sphere,y_sphere,z_sphere] = sphere;
% sphere_radius = 1.5;
x_sphere2 = x_sphere*sphere_radius;
y_sphere2 = y_sphere*sphere_radius;
z_sphere2 = z_sphere*sphere_radius;

%
% %ALE coordinates for GTM
% Hippocamps_node_MNI = [-32	-16	-18];%.*scaley+scaley_minvec;
% MDNThalams_node_MNI = [-4	-16	8];%.*scaley+scaley_minvec;
% PulvinarTh_node_MNI = [-10	-26	10];%.*scaley+scaley_minvec;%[-11, -19, 4];
% SupTempGyr_node_MNI = [-40	4	-32];%.*scaley+scaley_minvec;%[-40, 4, -32];    -36.0	-14.0	-3.0
% Cerebellar_node_MNI = [32	-64	-34];%.*scaley+scaley_minvec;
% Caudate_BG_node_MNI = [-6	16	6];%.*scaley+scaley_minvec;% [-15, 20, 6];
% 
% Hippocamps_sphere_MNI = surf(Hippocamps_node_MNI(1)+x_sphere2,Hippocamps_node_MNI(2)+y_sphere2,Hippocamps_node_MNI(3)+z_sphere2,'edgecolor','none','facecolor',plt_facecol);
% MDNThalams_sphere_MNI = surf(MDNThalams_node_MNI(1)+x_sphere2,MDNThalams_node_MNI(2)+y_sphere2,MDNThalams_node_MNI(3)+z_sphere2,'edgecolor','none','facecolor',plt_facecol);
% PulvinarTh_sphere_MNI = surf(PulvinarTh_node_MNI(1)+x_sphere2,PulvinarTh_node_MNI(2)+y_sphere2,PulvinarTh_node_MNI(3)+z_sphere2,'edgecolor','none','facecolor',plt_facecol);
% SupTempGyr_sphere_MNI = surf(SupTempGyr_node_MNI(1)+x_sphere2,SupTempGyr_node_MNI(2)+y_sphere2,SupTempGyr_node_MNI(3)+z_sphere2,'edgecolor','none','facecolor',plt_facecol);
% Cerebellar_sphere_MNI = surf(Cerebellar_node_MNI(1)+x_sphere2,Cerebellar_node_MNI(2)+y_sphere2,Cerebellar_node_MNI(3)+z_sphere2,'edgecolor','none','facecolor',plt_facecol);
% Caudate_BG_sphere_MNI = surf(Caudate_BG_node_MNI(1)+x_sphere2,Caudate_BG_node_MNI(2)+y_sphere2,Caudate_BG_node_MNI(3)+z_sphere2,'edgecolor','none','facecolor',plt_facecol);

hold off

%%
% 
% end
% 
% %%
% function h = simpleBrainSurface(par)
% % simpleBrainSurface
% % Simple function to render a brain in 3D in MNI coordinates.
% % Addapted from surfPlot of the MRtools collection from:
% % http://mrtools.mgh.harvard.edu/index.php/Main_Page
% %
% % Initial surface data comes from FreeSurfer template which apparently comes from:
% % Fischl, B., Sereno, M. I., Tootell, R. B.H. and Dale, A. M. (1999),
% % High-resolution intersubject averaging and a coordinate system for the 
% % cortical surface. Hum. Brain Mapp., 8: 272–284.
% % doi: 10.1002/(SICI)1097-0193(1999)8:4<272::AID-HBM10>3.0.CO;2-4
% %
% % INPUT:
% % par = specs object and specification object
% % range = 2D vector graycolor range [darkest brightest] 
% %           { default [0.1 0.7] }
% % OUTPUT:
% % h = handle to the surface patch.
% % SIDEEFFECTS:
% % A brain surface plot is generated.
% %
% %
% % Original:
% %%% Written by Aaron P. Schultz - aschultz@martinos.org
% %%%
% %%% Copyright (C) 2014,  Aaron P. Schultz
% %%%
% %%% Supported in part by the NIH funded Harvard Aging Brain Study (P01AG036694) and NIH R01-AG027435 
% %%%
% %%% This program is free software: you can redistribute it and/or modify
% %%% it under the terms of the GNU General Public License as published by
% %%% the Free Software Foundation, either version 3 of the License, or
% %%% any later version.
% %%% 
% %%% This program is distributed in the hope that it will be useful,
% %%% but WITHOUT ANY WARRANTY; without even the implied warranty of
% %%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% %%% GNU General Public License for more details.
% %%%
% % Copyright (C) 2015, Robert Rein
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% if nargin == 0
%     range = [0.1 0.7];
% else
%     if isstruct(par)
%         if isfield(par,'range')
%             range = par.range;
%         end
%     else
%         range = par;
%     end
% end
% 
% 
% 
% % get vertex data
% load('simple_brain_surface.mat');
% 
% % figure background color
% %set(gcf,'renderer','opengl','Color','k');
% set(gcf,'renderer','opengl','Color','w');
% 
% tmp_shading_color = brain.shading_pre * diff(range);
% tmp_shading_color = tmp_shading_color - min(tmp_shading_color) + range(1);
% shading_color = repmat(tmp_shading_color,1,3);
% 
% h = patch('vertices',brain.vertices, ...
%     'faces', brain.faces, ...
%     'FaceVertexCdata',shading_color,...
%     'FaceAlpha',0.1,...
%     'EdgeAlpha',0.1);
% 
% set(h,'edgecolor','none','facecolor','interp');
% set(gca,'dataaspectratio',ones(1,3),'visible','off');
% axis tight;
% % view(159,6);
% view(270,0);
% end