function pipeline_preprocessing_broadband_qsub(subject, audiofile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

savedir = '/project/3011044.02/preproc/meg';

% preprocessing options
fsample = 150;
lpfreq = 150;
hpfreq = 1;

%% Preprocessing, band-pass filtering, complex hilbert and downsampling
                        
[data, ~] = streams_preprocessing(subject, ...
                            'audiofile', audiofile, ...
                            'lpfreq', lpfreq, ...
                            'hpfreq', hpfreq, ...
                            'docomp', 1, ...
                            'dohilbert', 0, ...
                            'doabs', 0,  ...
                            'fsample', fsample);

%% Saving

% construct naming variable
lowpassfreq = sprintf('%02d', lpfreq);
highpassfreq = sprintf('%02d', hpfreq);
frequency_band = [highpassfreq, '-', lowpassfreq];

filename = [subject.name '_' audiofile(5:end) '_' frequency_band '_' num2str(fsample) 'Hz'];
filename = fullfile(savedir, filename);

pipelinefilename = '/project/3011044.02/preproc/meg/s01_1078_01-150_150Hz';

% save the pipeline if not yet saved
if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = filename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, data);
end
    
save(filename, 'data');


end
