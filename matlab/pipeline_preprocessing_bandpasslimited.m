clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
bpfreqs   = [04 08; 09 12];


% MEG: Subject, story and freq loops
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		
    audiofile = audiofiles{k};
	tmp       = strfind(audiofile, 'fn');
	audiofile = audiofile(tmp+(0:7));
    
    for h = 1:size(bpfreqs, 1)
      
      bpfreq = bpfreqs(h,:);
    
      qsubfeval('pipeline_preprocessing_bandpasslimited_qsub', subject, audiofile, bpfreq, ...
                      'memreq', 1024^3 * 12,...
                      'timreq', 240*60,...
                      'batchid', 'streams_preproc');
    end
    
  end

end