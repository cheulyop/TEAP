function [BulkSig] = Bulk_load_eeglab(EEGV)
%Loads an EEGLab variable, into a TEAPhysio bulk signal, containing EEG, ECG,
%GSR, etc.
% Inputs:
%  EEGV: the variable given by EEGLab (ex: load A.mat; Bulk_load_eeglab(EEG))
% Outputs:
%  BulkSig: a TEAPhysio bulk signal vector
%
%Copyright Frank Villaro-Dixon Creative Commons BY-SA 4.0 2014

if(nargin ~= 1)
	error('Usage: BulkSig = Bulk_load_eeglab(EEGV)');
end


%Number of epochs:
nEpochs = length(EEGV.epoch);


%foreach epoch
for iEpoch = [1:nEpochs]
	Bulk = Bulk_new_empty();

	Bulk = addGSR(Bulk, iEpoch);
	Bulk = addHST(Bulk, iEpoch);
	Bulk = addRES(Bulk, iEpoch);
	Bulk = addBVP(Bulk, iEpoch);

	BulkSig(iEpoch) = Bulk;
	clear Bulk;
end



%GSR
function BulkSig = addGSR(BulkSig, iEpoch);
	GSRChannel = findMyChannel('GSR1');
	if(GSRChannel == 0)
		return;
	end

	data = EEGV.data(GSRChannel, :, iEpoch);
	reshaped = reshape(data, 1, length(data));

	GSRSig = GSR_aqn_variable(reshaped, EEGV.srate);
	BulkSig = Bulk_add_signal(BulkSig, GSR__get_signame(), GSRSig);
end

%Temp/HST
function BulkSig = addHST(BulkSig, iEpoch);
	HSTChannel = findMyChannel('Temp');
	if(HSTChannel == 0)
		return;
	end

	data = EEGV.data(HSTChannel, :, iEpoch);
	reshaped = reshape(data, 1, length(data));

	HSTSig = HST_aqn_variable(reshaped, EEGV.srate);
	BulkSig = Bulk_add_signal(BulkSig, HST__get_signame(), HSTSig);
end

%Respiration
function BulkSig = addRES(BulkSig, iEpoch);
	RESChannel = findMyChannel('Resp');
	if(RESChannel == 0)
		return;
	end

	data = EEGV.data(RESChannel, :, iEpoch);
	reshaped = reshape(data, 1, length(data));

	RESSig = RES_aqn_variable(reshaped, EEGV.srate);
	BulkSig = Bulk_add_signal(BulkSig, RES__get_signame(), RESSig);
end

%BVT/Plet
function BulkSig = addBVP(BulkSig, iEpoch);
	BVPChannel = findMyChannel('Plet');
	if(BVPChannel == 0)
		return;
	end

	data = EEGV.data(BVPChannel, :, iEpoch);
	reshaped = reshape(data, 1, length(data));

	BVPSig = BVP_aqn_variable(reshaped, EEGV.srate);
	BulkSig = Bulk_add_signal(BulkSig, BVP__get_signame(), BVPSig);
end


%Find my channel
function iChannel = findMyChannel(chanName)
	for iChannel = [1:length(EEGV.chanlocs)]
		if(strcmp(chanName, EEGV.chanlocs(iChannel).labels) == 1)
			return;
		end
	end
	iChannel = 0;
end


end

