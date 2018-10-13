function [idealTemp,numClasses] = find_temp(tree,clu,par) %,spikes,ipermut)


    min_clus = par.min_clus;
    max_clus_size=par.max_clus;
    c_ov = par.c_ov;
    elbow_min = par.elbow_min;
    thresBorder=0.6;
    thresJaccard=0.9;
    incr_thres_coeff=0.1;
    
    
    numTemp=size(clu,1);
    numSpikes=size(clu,2)-2;
    clus_inc_thres=round(numSpikes*incr_thres_coeff);
    %clus_inc_thres=10;
    %tree structure element 4 is indicating  number of cluster group and
    %element 5 till the end represent the number of the first 12 groups
    treeCropped=tree(:,5:end);
    clu = clu(:,3:end); %crop out the first four elements
    
    treeCropped(treeCropped <min_clus)=0;
    diffClus=diff(treeCropped,1,1);
    
    thresTemp=numTemp;
%     for i=2:numTemp
%         LI=max(diffClus(i-1,2:end));
%         
%         crtParam=(treeCropped(i,1)+LI)/treeCropped(i-1,1)
%         if crtParam<thresBorder
%             thresTemp=i;
%             break;
%         end
%         
%     end
    thresTemp=2;
    for i=2:numTemp
        increSum=sum(diffClus(i-1,diffClus(i-1,:)>0));
        decreSum=abs(diffClus(i-1,diffClus(i-1,:)<0));
        
        
        if increSum>(decreSum*thresBorder)
           thresTemp=i; 
        end
    end
    
    %threshold test to verify temperature that would cause a huge cluster
    %shift
    for i=1:numTemp
        if i<=thresTemp
            if i==1
                interestPoint(1,:)=zeros(1,max_clus_size-1);
                interestPoint(1,1)=1;
            else
                interestPoint(i,:)=(abs(diffClus(i-1,:))>=clus_inc_thres);
            end
        else
            interestPoint(i,:)=zeros(1,max_clus_size-1); %#ok<AGROW>
        end
    end
    
    
    [row,col]=find(interestPoint==1);
    [row,order]=sort(row);
    col=col(order);
    col=col-1;
    idealTemp=1;
    %inclusion test
    for n=1:numel(row)
        for m=(n+1):numel(row)
            if((row(n)~=row(m))&&(col(n)~=col(m)))
                gp1=find(clu(n,:)==col(n));
                gp2=find((clu(m,:)==col(m)));
                totalgp=horzcat(gp1,gp2);
                numIntersect=sum(diff(sort(totalgp))==0);

                coeffJaccard=numIntersect/min([numel(gp1),numel(gp2)]);
                
                
                if coeffJaccard >thresJaccard
                    idealTemp=row(m);
                end
            end
        end
    end
    numClasses=sum(treeCropped(idealTemp,:)~=0);
    
    
    
end
    


