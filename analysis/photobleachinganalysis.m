% photo bleaching analysis
dirpath = 'C:\microscope_pics\08_18_2015\3\fov5_tot';
name = 'zstack_14_20_56';
% name = 'zstack_14_23_36';
load(fullfile(dirpath,[name,'.mat']));
%% find particles
img1=double(img3(:,:,1));
img2=double(img3(:,:,end));

se = strel('disk',10);
% img1bg = imgaussfilt(img1,20);%imopen(img1,se);
img1bg=imopen(img1,se);
img1 = img1 - img1bg;
img1 = bpass(img1,2,10);
pks=pkfnd(img1,200,11);
% pks=pkfnd(img1,500,11);
cnt=cntrd(img1,pks,11,0);
SI(double(img3(:,:,1)));hold on;
plot(cnt(:,1),cnt(:,2),'o');
savefig(['tracking_',name]);

%% calculating images
numparticles = size(cnt,1);
numframes = size(img3,3);
intensities = zeros(numframes,numparticles);

wz = 15;
for iframe =1:numframes
    img = double(img3(:,:,iframe));
%     imgbg = imgaussfilt(img,20);
    imgbg=imopen(img1,se);
    img = img - imgbg;
    for iparticle =1:numparticles
        pcnt = cnt(iparticle,1:2);
        pdcnt = pcnt - round(pcnt);
        [X,Y] = meshgrid((-wz:wz)+pdcnt(1),(-wz:wz)+pdcnt(2));
        mask = X.^2+Y.^2 < 12^2;
        wimg = img((-wz:wz)+round(pcnt(2)),(-wz:wz)+round(pcnt(1)));
        wimg = wimg.*mask;
        intensities(iframe,iparticle) = sum(wimg(:));
    end
end


%% fit to get tau
I0s=zeros(1,numparticles);
decays=zeros(1,numparticles);
t=(1:numframes)'*.1;
expfun = @(p) p(1)*exp(-t/p(2)) + p(3);
expfun2 = @(p,I) sum( (expfun(p)- I).^2);
ps=zeros(3,numparticles);
for iparticle=1:numparticles
% f = fit(t,intensities(:,iparticle),'exp1');
% I0s(iparticle)=f.a;
% decays(iparticle)=f.b;
p = fminunc(@(p)expfun2(p,intensities(:,iparticle)),[intensities(1,iparticle)-intensities(end,iparticle),20,intensities(end,iparticle)]);
ps(:,iparticle)=p;
end
hist(ps(2,:));
xlabel('tau')
savefig(['tau_',name]);

%% plot
colorhsv=hsv(numparticles);
for iparticle = 1:numparticles
    plot((1:numframes)*.1,intensities(:,iparticle),'.',...
        t,expfun(ps(:,iparticle)),'color',colorhsv(iparticle,:) ); hold on;
end
xlabel('seconds');
ylabel('total intensity for each particle')
savefig(['decaycurve_',name]);
%%



% photo bleaching analysis
dirpath = 'C:\microscope_pics\08_18_2015\mNeonGreen_4prime\photobleach';
name = 'zstack_17_31_47';
load(fullfile(dirpath,[name,'.mat']));
%% find particles
img1=double(img3(:,:,1));
img2=double(img3(:,:,end));

% se = strel('disk',8);
img1bg = imgaussfilt(img1,20);%imopen(img1,se);
img1 = img1 - img1bg;

img1 = bpass(img1,2,10);

pks=pkfnd(img1,10,11);
pks=pks(pks(:,1)<1100,:);
% pks=pkfnd(img1,500,11);
cnt=cntrd(img1,pks,11,0);
SI(double(img3(:,:,1)));hold on;
% SI(img1);hold on;
plot(cnt(:,1),cnt(:,2),'o');
savefig(['tracking_',name]);

%% calculating images
numparticles = size(cnt,1);
numframes = size(img3,3);
intensities = zeros(numframes,numparticles);

wz = 10;
for iframe =1:numframes
    img = double(img3(:,:,iframe));
    imgbg = imgaussfilt(img,20);
    img = img - imgbg;
    for iparticle =1:numparticles
        pcnt = cnt(iparticle,1:2);
        pdcnt = pcnt - round(pcnt);
        [X,Y] = meshgrid((-wz:wz)+pdcnt(1),(-wz:wz)+pdcnt(2));
        mask = X.^2+Y.^2 < 8^2;
        wimg = img((-wz:wz)+round(pcnt(2)),(-wz:wz)+round(pcnt(1)));
        wimg = wimg.*mask;
        intensities(iframe,iparticle) = sum(wimg(:));
    end
end
%% plot
for iparticle = 1:numparticles
    plot((1:numframes)*.1,intensities(:,iparticle)); hold on;
end
xlabel('seconds');
ylabel('total intensity for each particle')
savefig(['decaycurve_',name]);

%% fit to get tau
I0s=zeros(1,numparticles);
decays=zeros(1,numparticles);
t=(1:numframes)'*.1;
for iparticle=1:numparticles
f = fit(t,intensities(:,iparticle),'exp1');
I0s(iparticle)=f.a;
decays(iparticle)=f.b;
end
hist(-1./decays);
xlabel('tau')
savefig(['tau_',name]);

%%
dirpath = 'C:\microscope_pics\08_18_2015\mNeonGreen_4prime\photobleach';
name = 'zstack_17_33_55';
load(fullfile(dirpath,[name,'.mat']));
%%
img1=double(img3(:,:,1));
img2=double(img3(:,:,end));

% se = strel('disk',8);
img1bg = imgaussfilt(img1,20);%imopen(img1,se);
img1 = img1 - img1bg;

img1 = bpass(img1,2,10);

SI(double(img3(:,:,1)));hold on;
% SI(img1);hold on;
plot(cnt(:,1),cnt(:,2),'o');
savefig(['tracking_',name]);
%% calculating images
numparticles = size(cnt,1);
numframes = size(img3,3);
intensities = zeros(numframes,numparticles);

wz = 10;
for iframe =1:numframes
    img = double(img3(:,:,iframe));
    imgbg = imgaussfilt(img,20);
    img = img - imgbg;
    for iparticle =1:numparticles
        pcnt = cnt(iparticle,1:2);
        pdcnt = pcnt - round(pcnt);
        [X,Y] = meshgrid((-wz:wz)+pdcnt(1),(-wz:wz)+pdcnt(2));
        mask = X.^2+Y.^2 < 8^2;
        wimg = img((-wz:wz)+round(pcnt(2)),(-wz:wz)+round(pcnt(1)));
        wimg = wimg.*mask;
        intensities(iframe,iparticle) = sum(wimg(:));
    end
end
% plot
for iparticle = 1:numparticles
    plot((1:numframes)*.1,intensities(:,iparticle)); hold on;
end
xlabel('seconds');
ylabel('total intensity for each particle')
savefig(['decaycurve_',name]);


