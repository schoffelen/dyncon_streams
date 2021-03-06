clear all;
datadir = '/home/language/jansch/projects/streams/data/corticoaudiocoherence';

% load in some data from an example subject
load(fullfile(datadir, 's04_corticoaudiocoherence'));

% plot a chunk of MEG-channels as an example
tmp = data.trial{2}(101:120,:);
tmp = tmp./std(tmp(:));
figure;plot(data.time{2}, tmp + (-9:10)'*(5.*ones(1,numel(data.time{2}))), 'k');
xlabel('time (s)','fontname','arial','fontsize',12);
set(gca,'tickdir','out','ytick',[],'box','off');
set(gcf,'color','w');

% plot a chunk of raw speech signal as an example
[speech, fs] = wavread('/home/language/jansch/projects/streams/audio/audio_stories/fn001078.wav');
tim          = (0:(numel(speech)-1))./fs + 0.058;
ix           = nearest(tim,7.5):nearest(tim,12.5);
figure;plot(tim(ix), speech(ix)./std(speech(ix)), 'k');
xlabel('time (s)','fontname','arial','fontsize',12);
set(gca,'tickdir','out','ytick',[],'box','off');
set(gcf,'color','w');

% add a version of the envelope
figure;hold on;
tmp1 = speech(ix)./std(speech(ix));
plot(tim(ix), tmp1, 'k');
tmp2 = data.trial{2}(286,:);
tmp2 = tmp2./max(tmp2);
tmp2 = tmp2.*max(tmp1);
plot(tim(ix), tmp1, 'k');
plot(data.time{2}, tmp2, 'color', [0.8 0 0], 'linewidth', 3);
xlabel('time (s)','fontname','arial','fontsize',12);
set(gca,'tickdir','out','ytick',[],'box','off');
set(gcf,'color','w');

% concatenate a bunch of continuous trials
dat1 = zeros(273,0);
dat2 = zeros(1,0);
tim  = zeros(1,0);
for k = 255:2:285
  dat1 = cat(2,dat1,data.trial{k}(1:273,:));
  dat2 = cat(2,dat2,data.trial{k}(286,:));
  tim  = cat(2,tim,data.time{k});
end

% compute the cross-correlation function
nlag = 400;
x = zeros(273,2*nlag+1);
for k = 1:size(dat1,1)
  [x(k,:),lag] = xcorr(dat1(k,:),dat2,nlag,'coeff');
end
tlck = [];
tlck.time = lag./200;
tlck.avg  = x;
tlck.label = data.label(1:273);
tlck.dimord = 'chan_time';

cfg = [];
cfg.layout = 'CTF275.lay';
figure;ft_multiplotER(cfg, tlck);

% compute the spectrum of the xcorr-functions
for k = 1:273
  [p(:,k),f] = pwelch(x(k,:)-mean(x(k,:)),[],[],[],200);
end
figure;
plot(f,sqrt(p));
xlim([0 30]);
xlabel('frequency (Hz)', 'fontsize', 12, 'fontname', 'arial');
set(gca,'tickdir','out','box','off');
set(gcf,'color','w');

freq = [];
freq.label = data.label(1:273);
freq.freq  = f(1:30)';
freq.powspctrm = sqrt(p(1:30,:))';
freq.dimord = 'chan_freq';
figure;ft_multiplotER(cfg, freq);

% do a coherence analysis (done) + visualize
sel=find(strcmp(coh.labelcmb(:,1),'audio_avg'));
figure;plot(coh.freq, coh.cohspctrm(sel,:));

cfg = [];
cfg.layout = 'CTF275.lay';
cfg.refchannel = 'audio_avg';
cfg.parameter  = 'cohspctrm';
figure;ft_multiplotER(cfg, coh);

% compare the spectrum with spectral features in the data
cfg = [];
cfg.method  = 'mtmfft';
cfg.taper   = 'hanning';
cfg.foilim  = [0 50];
cfg.channel = {'audio_avg';'MLP56'};
freq = ft_freqanalysis(cfg, data);

figure;plot(freq.freq,freq.powspctrm(1,:),'k');
xlim([0.5 30]);
xlabel('frequency (Hz)', 'fontsize', 12, 'fontname', 'arial');
set(gca,'tickdir','out','box','off');
set(gcf,'color','w');
title(freq.label(1),'fontsize',12,'fontname','arial');

figure;plot(freq.freq,freq.powspctrm(2,:),'k');
xlim([0.5 30]);
xlabel('frequency (Hz)', 'fontsize', 12, 'fontname', 'arial');
set(gca,'tickdir','out','box','off');
set(gcf,'color','w');
title(freq.label(2),'fontsize',12,'fontname','arial','interpreter','none');

figure;plot(coh.freq,coh.cohspctrm(sel(97),:),'k');
xlim([0 30]);
xlabel('frequency (Hz)', 'fontsize', 12, 'fontname', 'arial');
ylabel('coherence', 'fontsize', 12, 'fontname', 'arial');
set(gca,'tickdir','out','box','off');
set(gcf,'color','w');

% how does it look in source space?
load(fullfile(datadir, 's04_corticoaudiocoherence_source_0.8.mat'));
coh08 = coh;
load(fullfile(datadir, 's04_corticoaudiocoherence_source_3.6.mat'),'coh');
coh36 = coh;
load(fullfile(datadir, 's04_corticoaudiocoherence_source_4.2.mat'),'coh');
coh42 = coh;
load(fullfile(datadir, 's04_corticoaudiocoherence_source_7.mat'),'coh');
coh70 = coh;

source.avg.coh08 = coh08(:,13);
source.avg.coh36 = coh36(:,13);
source.avg.coh42 = coh42(:,13);
source.avg.coh70 = coh70(:,13);
source = rmfield(source, 'label');

cfg = [];
cfg.funparameter = 'avg.coh08';
cfg.funcolormap  = 'jet';
cfg.method       = 'slice';
ft_sourceplot(cfg, source);

% let's put a brain behind it
mri = ft_read_mri('templateMRI.nii');
load standard_sourcemodel3d5mm
source.pos = sourcemodel.pos;

cfg = [];
cfg.parameter = {'avg.coh08' 'avg.coh36' 'avg.coh42' 'avg.coh70'};
i1 = ft_sourceinterpolate(cfg, source, mri);

cfg = [];
cfg.funparameter = 'avg.coh08';
cfg.funcolormap  = 'jet';
cfg.method       = 'ortho';
cfg.maskparameter = 'avg.coh08';
ft_sourceplot(cfg, i1);

cfg.funparameter  = 'avg.coh08';
cfg.maskparameter = cfg.funparameter;
cfg.method        = 'slice';
ft_sourceplot(cfg, i1);

cfg.funparameter  = 'avg.coh36';
cfg.maskparameter = cfg.funparameter;
cfg.method        = 'slice';
ft_sourceplot(cfg, i1);

cfg.funparameter  = 'avg.coh42';
cfg.maskparameter = cfg.funparameter;
cfg.method        = 'slice';
ft_sourceplot(cfg, i1);

cfg.funparameter  = 'avg.coh70';
cfg.maskparameter = cfg.funparameter;
cfg.method        = 'slice';
ft_sourceplot(cfg, i1);

% the gamma stuff
load(fullfile(datadir, 's04_corticoaudiocoherence_source_gammaenv_35-45'));
source.coh = squeeze(source.coh(:,12,:));
source.freq = 0:0.2:30;
source = rmfield(source,'time');

cfg = [];
cfg.funparameter = 'coh';
cfg.funcolormap  = 'jet';
ft_sourceplot(cfg, source);

% now, finally some group stuff:
cd(datadir);
d = dir('s*source_*.mat');
n = {d.name}';
f = nan+zeros(numel(n),1);
for k = 1:numel(n)
  if ~isempty(strfind(n{k},'gamma'))
    % skip
  else
    tok = tokenize(n{k},'_');
    f(k) = str2num(tok{end}(1:end-4));
  end
end

sellow = find(f<1.5);
for k = 1:numel(sellow)
  if k==1,
    load(n{sellow(k)},'coh', 'source');
    source1 = rmfield(source, 'label');
    source1.avg.coh(:) = 0;
  else
    load(n{sellow(k)},'coh');
  end
  source1.avg.coh = source1.avg.coh + coh(:,13);
end

source2 = source1;
source2.avg.coh(:) = 0;
selmed = find(f>=3.5&f<=4.6);
for k = 1:numel(selmed)
  load(n{selmed(k)},'coh');
  source2.avg.coh = source2.avg.coh + coh(:,13);
end

source3 = source1;
source3.avg.coh(:) = 0;
selhigh = find(f>4.6);
for k = 1:numel(selhigh)
  load(n{selhigh(k)},'coh');
  source3.avg.coh = source3.avg.coh + coh(:,13);
end
