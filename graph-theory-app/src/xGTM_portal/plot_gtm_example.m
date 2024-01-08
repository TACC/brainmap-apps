function plot_gtm_example(gtm_folder_path,gtm_mat_file,coord_text_file,coact_mat_file,patel_struct_file)
% Jonathan Towne
%        Email: townej@uthscsa.edu
%        jmt8@alumni.rice.edu
% Last edited: January 19th, 2023
% 
%write coordinates to text file
%dlmwrite('Default_GTM_coordinates.txt', Output2, 'delimiter', '\t');

%convert MNI to Talairach in GingerALE 
%need command line for this

%get talairach daemon labels stored as filename.td
%java -cp talairach.jar org.talairach.ExcelToTD 2, Default_GTM_coordinates_TD.txt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
coord_file_name = coord_text_file;
load(coact_mat_file)
TLE_exp_ans  = mat_coat;
coords       = load(gtm_mat_file,'-ascii');

%% load Tailarach td output as text
opts = delimitedTextImportOptions("NumVariables", 8);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";
% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "LeftCerebrum", "Sublobar", "ExtraNuclear", "WhiteMatter", "OpticTract"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Specify variable properties
opts = setvaropts(opts, ["VarName1", "VarName2", "VarName3", "LeftCerebrum", "Sublobar", "ExtraNuclear", "WhiteMatter", "OpticTract"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VarName1", "VarName2", "VarName3", "LeftCerebrum", "Sublobar", "ExtraNuclear", "WhiteMatter", "OpticTract"], "EmptyFieldRule", "auto");
% Import the data
DefaultGTMcoordinates = readmatrix(strcat(gtm_folder_path, coord_file_name), opts);
%Clear temporary variables
clear opts

%%
%TLE_exp_ans=mat_coat;
% load('TLE_exp_ans.mat')
% load(patel_struct_file);
% coords       = load(gtm_mat_file,'-ascii');
% k            = patel_struct.k;
% tao          = patel_struct.tao;
%% dont run (only as function)
% if size(k,1)~=size(tao,1) || size(k,1)~=size(tao,2) || size(k,1)~=size(k,2) || size(k,1)~=size(coords,1) || size(coords,2)~=3
%     error("Input Dimensionality Error. patel_struct_file should contain two fields, k & tao, both of n x n dimensions, and gtm_mat_file should be n x 3.")
% end
%%
scale_vox_2x2x2=2;

load(patel_struct_file)
k = patel_struct.k;
tao = patel_struct.tao;

connected_coord_indices = union(find(~all(k==0,1)),find(~all(k==0,2)));
connected_coord_indices_tau = union(find(~all(tao==0,1)),find(~all(tao==0,2)));

plot_k_mat = k(connected_coord_indices,connected_coord_indices) | k(connected_coord_indices,connected_coord_indices)';

G1=graph(k | k');

coord_txt_File = DefaultGTMcoordinates;

x=str2num(char(coord_txt_File(:,1)));
y=str2num(char(coord_txt_File(:,2)));
z=str2num(char(coord_txt_File(:,3)));
%% no brain surface
% figure(3)
% title('MTLE example nodes and edges')
% plot(G1,'XData',x*scale_vox_2x2x2,'YData',y*scale_vox_2x2x2,'ZData',z*scale_vox_2x2x2);%,'EdgeLabel',G.Edges.Weight
% axis([-65 65 -90 70 -60 80])
% xlabel("X-Axis")
% ylabel("Y-Axis")
% zlabel("Z-Axis")
% view(-105,10)
%% brain surface
figure(1)
G1_temp   = graph(k | k');
temp_surf = simpleBrainSurface;
hold on
plot(G1_temp,'XData',x*scale_vox_2x2x2,'YData',y*scale_vox_2x2x2,'ZData',z*scale_vox_2x2x2);

xlabel("X-Axis")
ylabel("Y-Axis")
zlabel("Z-Axis")

hold off

%% export
%https://www.mathworks.com/help/compiler_sdk/java/plot-example.html
%export_hack();
%Vertices1
%Faces1
%FaceVertexCData1
%g1
%ZData1
%YData1
%XData1

Vertices1        = temp_surf.Vertices;
Faces1           = temp_surf.Faces;
FaceVertexCData1 = temp_surf.FaceVertexCData;
g1               = G1_temp;
ZData1           = z*scale_vox_2x2x2;
YData1           = y*scale_vox_2x2x2;
XData1           = x*scale_vox_2x2x2;









return
