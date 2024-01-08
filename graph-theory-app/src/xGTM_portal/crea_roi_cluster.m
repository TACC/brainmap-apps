function p=crea_roi_cluster(img_ale,gtm_radius,fn_out,fn_out1,ale_thresh)
% function to create a nii file with equidistant node
% obtained from an ale nii image
% input: img_ale, nii image of the ale as obtaine from ginger ale
%        fn_out, output file name of the node in nii format
%        fn_out1 output file name of coordinate of the node in mat format
% output: p value of control if p=1 success
% by
% Tommaso Costa
% Dipartimento di Psicologia
% Università di Torino

% EDITED BY
% Jonathan Towne
%        Email: townej@uthscsa.edu
%        jmt8@alumni.rice.edu
% Last edited: January 19th, 2023
% 

% load file cluster
nii=load_nii(img_ale);
% creo image ALE e destination image
img=nii.img;
img_out=img;
img_out(:)=0;
img_dum=img;

% fixes the hard codeing
jon_im_size = size(img_out);
jon_x = jon_im_size(1);
jon_y = jon_im_size(2);
jon_z = jon_im_size(3);

% create 3D mesh equal to the nii file
%%%%original hard-code%%%%[xx yy zz] = ndgrid(1:80,1:96,1:70);
[xx yy zz] = ndgrid(1:jon_x,1:jon_y,1:jon_z); %softer code

% find the number of theoretical peaks
nui=find(img(:));
N=round(length(nui)*((100-ale_thresh)/100));
%N=21717;%round(length(nui));

% starting color node
COL=1;
%     find peaks
[pks coord]=findpeaks(double(img_dum(:)));
% sorts peaks in descendig order
[Y,I] = sort(pks,'descend');
%     convert coordinate
%%%%original hard-code%%%%[X1,Y1,Z1] = ind2sub([80 96 70],coord(I));
[X1,Y1,Z1] = ind2sub([jon_x jon_y jon_z],coord(I));%softer code
duff=[X1,Y1,Z1];

%%%%%%%%%%%%%%%%%%%
N=size(duff,1);
%%%%%%%%%%%%%%%%%%%

duff=duff(1:N,:);
DF=0;
while(DF==0)
    % distance peaks calculation
    p=pdist(duff,'euclidean');
    %         square form transormation
    d=squareform(p);
    %         create loginal matrix
    % op=(d>0 & d<5);     
    op=(d>0 & d<(2*gtm_radius));                                                        % adjust bound for distance correction
    %     near points control and elimination
    if(length(op)>0)
        [NK dum]=size(duff);
        KK=0;
        K1=0;
        for j=1:NK
            jj=find(op(j,:));
            if(jj>0 & K1==0)
                duff(jj,:)=[];
                KK=KK+1;
                K1=1;
            end
        end
        if(KK==0)
            DF=1;
        end
    else
        DF=0;
        disp('no cluster level');
        zeroFLAG=1;
        break
    end
end
Nvox=size(duff,1);
%     creation of the image in tal coordnate
for jl=1:Nvox
    S = sqrt((xx-duff(jl,1)).^2+(yy-duff(jl,2)).^2+(zz-duff(jl,3)).^2)<2.5;
    img_out=img_out+2.*jl.*single(S);
end
nii.img=img_out;
save_nii(nii,fn_out);
clear duff6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
duff6(:,1)=duff(:,1)-nii.hdr.hist.originator(1);
duff6(:,2)=duff(:,2)-nii.hdr.hist.originator(2);
duff6(:,3)=duff(:,3)-nii.hdr.hist.originator(3);
save(fn_out1,'duff6','-ascii');
p=1;
return