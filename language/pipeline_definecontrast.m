clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

%% INITIALIZE

[subjects, num_sub] = streams_util_subjectstring(2:28, {'s01', 's06'});

for i = 1:num_sub
    
    subject = subjects{i};
    qsubfeval('streams_definecontrast', subject, ...
                  'memreq', 1024^3 * 4,...
                  'timreq', 30*60, ...
                  'matlabcmd', 'matlab2016b');
    
end