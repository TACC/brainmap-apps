% turn off local mpi to get parpool to work
distcomp.feature( 'LocalUseMpiexec', false )

% Add paths to functions specific to author-topic model
CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'stable_projects', 'meta-analysis', 'Ngo2019_AuthorTopic', 'utilities', 'preprocessing'));
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'stable_projects', 'meta-analysis', 'Ngo2019_AuthorTopic', 'utilities', 'inference'));
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'stable_projects', 'meta-analysis', 'Ngo2019_AuthorTopic', 'utilities', 'BIC'));
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'stable_projects', 'meta-analysis', 'Ngo2019_AuthorTopic', 'utilities', 'visualization'));
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'utilities', 'matlab', 'transforms'));
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'utilities', 'matlab', 'surf'));
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'utilities', 'matlab', 'fslr_matlab'));
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'utilities', 'matlab', 'figure_utilities', 'draw_surface_data_as_annotation', 'colorscale'));
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'external_packages', 'SD', 'SDv1.5.1-svn593', 'BasicTools'));
addpath(fullfile(getenv('CBIG_CODE_DIR'), 'external_packages', 'SD', 'SDv1.5.1-svn593', 'kd_tree'));
%addpath(fullfile(getenv('CBIG_CODE_DIR'), 'external_packages', 'matlab', 'default_packages', 'cifti-matlab', '@gifti'));
addpath(fullfile('/opt', 'freesurfer', 'matlab'));


% Pre-process MNI152 coordinates of activation foci in raw text input data
textFilePath = fullfile(pwd, getenv('foci_text'));
[data_file, data_name, data_ext] = fileparts(textFilePath);
dataDirPath = fullfile(pwd, 'data');
dataFileName = strcat(data_name, '_CVBData.mat');
mkdir ( [ dataDirPath '/ActivationVolumes' ] );
mkdir ( [ dataDirPath '/BinarySmoothedVolumes' ] );
mkdir ( [ dataDirPath '/mask' ] );
CBIG_AuthorTopic_GenerateCVBDataFromText(textFilePath, dataDirPath, dataFileName);


% Inference
alpha = 100;
eta = 0.01;
doSmoothing = 1;
workDir = pwd;
cvbData = fullfile(dataDirPath, dataFileName);
seeds = 1:1000;
parpool(64);
for K = 1:4
  parfor (seed = 1:1000,64)
    CBIG_AuthorTopic_RunInference(seed, K, alpha, eta, doSmoothing, workDir, cvbData);
  end
end

 
% Get the best model estimates
outputsDir = fullfile(workDir, 'outputs');
parfor (K = 1:4,4)
  CBIG_AuthorTopic_ComputeBestSolution(outputsDir, K, seeds, alpha, eta);
end


% Visualize the cognitive components
%figuresDir = fullfile(workDir, 'figures');
%mkdir ( [ figuresDir, '/clear_brain_min1e-5_max5e-5' ] );
%inputFile = fullfile(workDir, 'outputs', 'bestSolution', 'alpha100_eta0.01', 'BestSolution_K002.mat');
%CBIG_AuthorTopic_VisualizeComponentsOnBrainSurface(inputFile, figuresDir);    %%% giving gifti errors


% Compute bayesian information criterion
maskPath = fullfile(dataDirPath, 'mask', 'expMask.nii');
bestSolutionDir = fullfile(workDir, 'outputs', 'bestSolution', 'alpha100_eta0.01');
bicDir = fullfile(workDir, 'BIC');
CBIG_AuthorTopic_ComputeBIC(1:4, maskPath, bestSolutionDir, bicDir);


