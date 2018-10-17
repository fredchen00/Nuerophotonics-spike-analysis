function features=waveFeatures(MEAdata,spikeStart,spikeEnd,method)
    %can only handle single channel

    numSpikes = size(spikeStart,1);
    spikeLen = spikeEnd(1)-spikeStart(1);
    pvalue=[];
    %defined params
    waveletScales=4;
    numberPCA=5;
    maxInput=ceil(spikeLen*0.5);
    %maxInput=25;
    if method=='pca'
         for i=1:numSpikes
            spikes(i,:)=MEAdata(spikeStart(i):spikeEnd(i));
         end
        [C,S,~,~,explained] = pca(spikes);
        cc = S;
        
        accsum=0;
        for i=1:size(spikes,2)
            accsum=accsum+explained(i);
            if accsum>95
                inputs=i;
                break;
            end
        end
        
  
        features= cc(:,1:inputs);
        
    elseif method=='wav'
        for i=1:numSpikes
            spike=MEAdata(spikeStart(i):spikeEnd(i));
            [c,l] = wavedec(spike,waveletScales,'haar');
            cc(i,1:spikeLen) = c(1:spikeLen);
            [~,maxIndex]=max(abs(spike));
            maxvalFeature(i)=spike(maxIndex);
        end


        for i=1:spikeLen
            thr_dist = std(cc(:,i)) * 3;
            thr_dist_min = mean(cc(:,i)) - thr_dist;
            thr_dist_max = mean(cc(:,i)) + thr_dist;
            aux = cc(find(cc(:,i)>thr_dist_min & cc(:,i)<thr_dist_max),i);


            %KS test to find the optimal coefficients
            if length(aux) > 10
                [h,p] = lillietest(aux);
                if h==1
                    pvalue(i)=p;
                else
                    %set data that fails to reject hypothesis having pvalue =1
                    %so they wont be considered for later sorting
                    pvalue(i)=1;
                end
            end
        end

        [pvalueSorted,ind] = sort(pvalue);

        coeff=ind(pvalue<=0.05);


        inputs=min(maxInput,numel(coeff));
        features=zeros(numSpikes,inputs);
        for i=1:numSpikes
            for j=1:inputs
                features(i,j)= cc(i,coeff(j));
            end
        end
        %features = tsne(features,'Algorithm','barneshut','NumPCAComponents',size(features,2),'NumDimensions',numberPCA);
    end
    
    
    

end