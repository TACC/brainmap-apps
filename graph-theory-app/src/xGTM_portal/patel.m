function [k tao]=patel(A,output_file_name_dotmat,e,th, Nsample)

% 1) make/send ROIs, 2) convert to talairach coordinates ; 

% input
% A: binary matrix row (Map Activation) x row (brain node)

% optional
% e: threshold of montecarlo for the k metrics
% th: threshold of k and tao metrics
% Nsample: number of montecarlo
% output
% two metrics: k and tao

% algorithm build from
% 
% A Bayesian Approach to Determining
% Connectivity of the Human Brain
% Rajan S. Patel et al.
% Human Brain Mapping 27:267?276(2006)
% 
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

% check for optional input
if nargin < 5, Nsample=1000; end
if nargin < 4, th=0.05; end
if nargin < 3, e=0.1; end;

% create matrix with zeros for 
% calculation of the probabilities and metrics
[N,M]=size(A);
z1=zeros(M,M);
z2=zeros(M,M);
z3=zeros(M,M);
z4=zeros(M,M);
k=zeros(M,M);
tao=zeros(M,M);

% calculation of the bivariate bernoulli model
% seq eq (3) in the paper
% cicle between the various node 
for i=1:M-1
    for j=i+1:M
        nodoA=A(:,i);
        nodoB=A(:,j);
        z1(i,j)=length(find(nodoA==1 & nodoB==1));
        z2(i,j)=length(find(nodoA==1 & nodoB==0));
        z3(i,j)=length(find(nodoA==0 & nodoB==1));
        z4(i,j)=length(find(nodoA==0 & nodoB==0));
        
%   eq(5) calculation
        teta1=z1(i,j)/N;
        teta2=z2(i,j)/N;
        teta3=z3(i,j)/N;
        teta4=z4(i,j)/N;
        
%         intermediate calculation for the metrics k
        E=(teta1+teta2).*(teta1+teta3);
        maxteta1=min((teta1+teta2),(teta1+teta3));
        minteta1=max(0,2.*teta1+teta2+teta3-1);
        
%         eq(8)
        if(teta1>=E)
            D=((teta1-E)./(2.*maxteta1-2*E))+0.5;
        else
            D=0.5-((teta1-E)./(2.*E-2*minteta1));
        end
        
%         eq (7)
        k(i,j)=(teta1-E)./(D.*(maxteta1-E)+(1-D).*(E-minteta1));
        
% %         eq(9) tao metrics
        if(teta2>=teta3)
            tao(i,j)=1-((teta1+teta3)./(teta1+teta2));
        else
            tao(i,j)=((teta1+teta2)./(teta1+teta3))-1;
        end
    end
end

% deal with NaN and/or missing data
i=find(isnan(k));
k(i)=0;
i=find(isnan(tao));
tao(i)=0;

% Nsample=1000;
% 
% % Montecarlo simulation for significativity threshold
% here we recalculate each metrics using a parametric montecarlo simulation
% using a dirichlet distribution see eq(6) in the paper
sk=zeros(M,M);

Z=(z1-1).*(z2-1).*(z3-1).*(z4-1);
[r c]=find(Z);
N1=length(r);
for i=1:N1
    alfa(1)=z1(r(i),c(i))-1;
    alfa(2)=z2(r(i),c(i))-1;
    alfa(3)=z3(r(i),c(i))-1;
    alfa(4)=z4(r(i),c(i))-1;
    if(alfa(1)>0 & alfa(2)>0 & alfa(3)>0 & alfa(4)>0)
        teta=sample_dirichlet(alfa,Nsample);
        for l=1:Nsample
            teta1=teta(l,1);
            teta2=teta(l,2);
            teta3=teta(l,3);
            E=(teta1+teta2).*(teta1+teta3);
            maxteta1=min((teta1+teta2),(teta1+teta3));
            minteta1=max(0,2.*teta1+teta2+teta3-1);
            if(teta1>=E)
                D=((teta1-E)./(2.*maxteta1-2*E))+0.5;
            else
                D=0.5-((teta1-E)./(2.*E-2*minteta1));
            end
            ks(l)=(teta1-E)./(D.*(maxteta1-E)+(1-D).*(E-minteta1));
        end
        
% deal with NaN and/or missing data
        mm=find(isnan(ks));
        ks(mm)=0;
%         find the threshold value 
        j=find(ks>=e);
        k95=length(j)/Nsample;
        sk(r(i),c(i))=k95;
    end
end

% threshold
tao1=tao;
i=find(sk<th);
k(i)=0;
% tao thresholded with the threshold of k
tao(i)=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
patel_struct.k=k;
patel_struct.tao=tao;
%output_file_name_dotmat = 'mtleExample_patel_struct.mat'; % set the output file name
save(output_file_name_dotmat,'patel_struct')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return