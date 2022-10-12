function [Test_Results,z,H,W] = RAIM_Subset(z,x,H,W)
%
% RAIM_Subset function implements the RAIM subset technique
%
%in input:
%        - "z" measurements
%        - "x" state vector
%        - "H" design matrix
%        - "W" weitghing matrix
%
%in output:
%        - "Test_Results", Test_Results=[Sol_Rel;nr_rej] 
%               "Sol_Rel" solution reliability flag (Sol_Rel=0 no redundancy)(Sol_Rel=1 solution reliable)(Sol_Rel=2 GT not OK, but impossible to indentify the blunder)
%               "nr_rej" number of rejections
%        - "z" measurements without blunders
%        - "H" design matrix without blunders
%        - "W" weitghing matrix without blunders
%
%note: for RAIM subset technique refer to 
%        - Kuusniemi H. 2005, User-level reliability and quality monitoring in satellite-based personal navigation, PhD thesis, Tampere University of Technology
%
%function called:
%        - RAIM_GT
%
%version 0.002 2016/05/02
%


global T_Global


[Gt,~,~,~] = RAIM_GT(z,x,H,W);

redundancy=length(z)-length(x);


if Gt==0
    
    Sol_Rel=0;
    nr_rej=0;
    
elseif Gt==1
    
    Sol_Rel=1;
    nr_rej=0;
    
elseif Gt==2
    
    Sol_Rel=2;
    nr_rej=0;
    
    for i=1:min([redundancy-1,fix(length(z)/2)]) %(o fino a numero massimo di scarti desiderati)
        
        index=nchoosek(1:length(z),length(z)-i);
        D_sub=nan(size(index,1),1);
        for k=1:size(index,1)
            z_sub = z(index(k,:));
            H_sub = H(index(k,:),:);
            if rank(H)==rank(H_sub)
                W_sub= W(index(k,:),index(k,:));
                x_sub=(H_sub'*W_sub*H_sub)\(H_sub'*W_sub*z_sub);
                
                %redundancy
                redundancy_sub=length(z_sub)-length(x_sub);
                
                %residuals
                r_sub= z_sub -H_sub*x_sub;
                
                %statistic test
                D_sub(k)=r_sub'*W_sub*r_sub;
            end
        end
        
        [~,k_exclu] = min(D_sub);
        
        %subset theshold
        T_global_sub=T_Global(redundancy_sub);
        if D_sub(k_exclu)<T_global_sub && sum(D_sub<T_global_sub)==1 %
            
            HH=H(index(k_exclu,:),:);
            WW=W(index(k_exclu,:),index(k_exclu,:));
            zz=z(index(k_exclu,:)');

            Sol_Rel=1;
            nr_rej=length(z)-length(zz);
            
            z=zz;
            H=HH;
            W=WW;

            break
        
        elseif D_sub(k_exclu)<T_global_sub && sum(D_sub<T_global_sub)>1
            
            Sol_Rel=2;
            
        end
        
    end
    
end


Test_Results=[Sol_Rel; nr_rej];


