function classes=spikeCluster(spikeFeatures)
	par = set_parameters(); 
    par.inputs = size(spikeFeatures,2);                       % number of inputs to the clustering
    numSpikes=size(spikeFeatures,1);
    
    par.fname_in = 'tmp_data_wc_1';                       % temporary filename used as input for SPC
    par.fname = 'data_1';
    par.nick_name = 'data_fred';
    par.fnamespc = 'data_wc1';
	par.filename = 'temp_cluster';
    
    if par.permut == 'n'
        % GOES FOR TEMPLATE MATCHING IF TOO MANY SPIKES.
        if numSpikes> par.max_spk
            % take first 'par.max_spk' spikes as an input for SPC
            inspk_aux = spikeFeatures(1:par.max_spk,:);
        else
            inspk_aux = spikeFeatures;
        end
	else
        % GOES FOR TEMPLATE MATCHING IF TOO MANY SPIKES.
        if numSpikes> par.max_spk
            % random selection of spikes for SPC
            ipermut = randperm(length(spikeFeatures));
            ipermut(naux+1:end) = [];
            inspk_aux = spikeFeatures(ipermut,:);
        else
            ipermut = randperm(size(spikeFeatures,1));
            inspk_aux = spikeFeatures(ipermut,:);
        end
    end
    %INTERACTION WITH SPC
    save(par.fname_in,'inspk_aux','-ascii');
    [clu, tree] = run_cluster(par,true);
    try
		if exist([par.fnamespc '.dg_01.lab'],'file')
			movefile([par.fnamespc '.dg_01.lab'], [par.fname '.dg_01.lab'], 'f');
			movefile([par.fnamespc '.dg_01'], [par.fname '.dg_01'], 'f');
        end
        
    catch
        warning('MyComponent:ERROR_SPC', 'Error in SPC');
        return
    end

    
%     [clust_num temp auto_sort] = find_temp_origin(tree,clu,par);
%     current_temp = max(temp);
%     classes = zeros(1,size(clu,2)-2);
%     for c =1: length(clust_num)
%         aux = clu(temp(c),3:end) +1 == clust_num(c);
%         classes(aux) = c;
%     end

    [temp,numClasses] = find_temp(tree,clu,par);
    classes=clu(temp,3:end)+1;
    classes(classes>(numClasses))=0;





end