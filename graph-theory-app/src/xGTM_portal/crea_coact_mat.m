function mat_coat=crea_coact_mat(img_nodi,file_name_without_extension)
% create a coactivation matrix from meta-analitic data
% input: img_nodi, a nii imge with node
% output: mat_coat, a binary coactivation matrix
% by
% Tommaso Costa
% Dipartimento di Psicologia
% Università di Torino

% here read in a fixed directory MA_Z the MA in z point obtained from 
% the ginger ale library with the following commnad
% java -cp GingerALE.jar org.brainmap.meta.getALE2 foci.txt

% EDITED BY
% Jonathan Towne
%        Email: townej@uthscsa.edu
%        jmt8@alumni.rice.edu
% Last edited: January 19th, 2023
% 

d=dir('MA_Z/*_Z.nii');

N=length(d);
nii=load_nii(img_nodi);
mask=nii.img;
i=find(mask);
a=mask(i);
aa=unique(a);
M=length(aa);
mat_coat=zeros(N,M);   % N is the # of items (timepoints or experiments ... or subjects?) in the series ... M is # of ROIs (coordinates = 118)
folder='MA_Z';
for i=1:N              % loop through the items in the series 
    fn=strcat(folder,'/',d(i).name);
    nii=load_nii(fn);
    img=nii.img;
    k=find(img(:)<2.1);
    img(k)=0;
    k=find(img(:));
    img(k)=1;
    dum=double(img).*double(mask);
    k=find(dum);
    kk=dum(k);
    kkk=unique(kk);
    M=length(kkk);
    for j=1:M
        jj=find(dum(:)==kkk(j));
        nv=length(jj);
        jj=find(double(mask(:))==kkk(j));
        nv1=length(jj);
        if((nv/nv1)*100>20)
            nj=kkk(j);
            njj=find(aa==nj);
            mat_coat(i,njj)=1;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(strcat(file_name_without_extension,'.mat'),'mat_coat')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return