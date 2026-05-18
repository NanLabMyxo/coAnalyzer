function coMerge3(folder1,folder2,image_number,channel1,channel2,contrast1,contrast2,checkbox,ROI_number,color1,index1,color2,index2,contrast3,contrast4)
%%
close
clc
folder1=folder1{1};
folder2=folder2{1};
image_number=str2double(image_number);
contrast1=str2double(contrast1);
contrast2=str2double(contrast2);
d1=dir(folder1);
d2=dir(folder2);
%% color map [R G B]
cmap1=[1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 1 0; 1 0 1; 1 1 1];
cmap2=[{'Red'},{'Green'},{'Blue'},{'Cyan'},{'Yellow'},{'Magenta'},{'Gray'}];
% red	[1 0 0]
% green	[0 1 0]
% blue	[0 0 1]
% cyan	[0 1 1]
% yellow	[1 1 0]
% magenta	[1 0 1]
% white	[1 1 1] 
% black	[0 0 0]


%%
k1=0;
for i=1:1:length(d1)
    if d1(i).isdir==0
file_name1=d1(i).name;
k1=k1+1;
if k1==image_number
    break
end
    end
end

k2=0;
for i=1:1:length(d2)
     if d2(i).isdir==0
file_name2=d2(i).name;
k2=k2+1;
if k2==image_number
break;
end
    end
end
error=0;
if k1==image_number && k2==image_number
else
    h=msgbox(['error, image ' num2str(image_number) ' does not exist']);
    ht=findobj(h,'Type','text');
    set(ht,'fontname','Arial', 'fontsize', 16, 'Unit', 'normal');
    set(h,'position',[400 400 400 60])
    pause(2)
    close    
    error=1;
end

if error==0
if ~exist([folder1 '/sum' file_name1],'dir') 
mkdir(folder1,['sum' file_name1]);
end
folder1s=[folder1 '/sum' file_name1];


%% roi for the spot
try
xy=load([folder1s '/mask' ROI_number '.txt']);
mask1=double(imread([folder1s '/mask' ROI_number '.tif']));
catch me
    error=1;
    h=msgbox(['error, ROI number ' ROI_number ' does not exist']);
    ht=findobj(h,'Type','text');
    set(ht, 'fontname','Arial', 'fontsize', 16, 'Unit', 'normal');
    set(h,'position',[400 400 400 60])
    pause(2)
    close  
end

if error==0
img1=double(imread([folder1 '/' file_name1] ));
img2=double(imread([folder2 '/' file_name2] ));
row_low=round(min(xy(:,2)));
col_low=round(min(xy(:,1)));
row_high=round(max(xy(:,2)));
col_high=round(max(xy(:,1)));
% mask11=mask1(row_low:row_high,col_low:col_high);
imgr1=img1(row_low:row_high,col_low:col_high);
imgr2=img2(row_low:row_high,col_low:col_high);
% img1=imgr1.*mask11;
% img2=imgr2.*mask11;
img11=imgr1;
img22=imgr2;
i1=find(imgr1<max(max(imgr1))*contrast3);
imgr1(i1)=0;
i2=find(imgr2<max(max(imgr2))*contrast4);
imgr2(i2)=0;
img1=imgr1;
img2=imgr2;
%% assign the color for each channel
for i=1:1:length(cmap2)
if strcmp(color1{index1},cmap2{i})
    cmapc1=cmap1(i,:);
end
if strcmp(color2{index2},cmap2{i})
    cmapc2=cmap1(i,:);
end
end
% cmapc3=cmapc1+cmapc2;
img1c = imfuse(img1,img1,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
img1c2=img1c;
img1c(:,:,1)=cmapc1(1)*img1c2(:,:,1)/contrast1;
img1c(:,:,2)=cmapc1(2)*img1c2(:,:,1)/contrast1;
img1c(:,:,3)=cmapc1(3)*img1c2(:,:,1)/contrast1;
img2c = imfuse(img2,img2,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
img2c2=img2c;
img2c(:,:,1)=cmapc2(1)*img2c2(:,:,1)/contrast2;
img2c(:,:,2)=cmapc2(2)*img2c2(:,:,1)/contrast2;
img2c(:,:,3)=cmapc2(3)*img2c2(:,:,1)/contrast2;
img3c = imfuse(img1,img2,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
img3c(:,:,1)=cmapc1(1)*img1c2(:,:,1)/contrast1+cmapc2(1)*img2c2(:,:,1)/contrast2;
img3c(:,:,2)=cmapc1(2)*img1c2(:,:,1)/contrast1+cmapc2(2)*img2c2(:,:,1)/contrast2;
img3c(:,:,3)=cmapc1(3)*img1c2(:,:,1)/contrast1+cmapc2(3)*img2c2(:,:,1)/contrast2;
%% plot
close
[m,n]=size(img1);
k=m/n;
set(gcf,'position',[20 200 450 150*k+30]);
subplot(1,3,1)
set(gca,'position',[0 0 0.97/3 0.97*200*k/(200*k+30)])
imshow(img1c)
title(channel1,'fontname','Arial', 'fontsize',16)

subplot(1,3,2)
set(gca,'position',[1/3 0 0.97/3 0.97*200*k/(200*k+30)])
imshow(img2c)
title(channel2,'fontname','Arial', 'fontsize',16)

subplot(1,3,3)
set(gca,'position',[2/3 0 0.97/3 0.97*200*k/(200*k+30)])
imshow(img3c)
title('Merged','fontname','Arial', 'fontsize',16)
saveas(gcf,[folder1s '/Merged' ROI_number '.tif'])

if checkbox==1
h = imline;
position = wait(h);
hold on
x0=position(:,1);
y0=position(:,2);
x=fix(x0-0.5)+1;
y=fix(y0-0.5)+1;
plot(x,y,'r','linewidth',2)
delete(h)
saveas(gcf,[folder1s '/MergedWithLine' ROI_number '.tif'])
%%
if x(2)==x(1)
lineint1=img11(min(y):max(y),x(1));
lineint2=img22(min(y):max(y),x(1));
end
if y(2)==y(1)
lineint1=img11(y(1),min(x):max(x));
lineint2=img22(y(1),min(x):max(x));
end
%%
if x(2)==x(1) || y(2)==y(1)
else
k0=(y0(2)-y0(1))/(x0(2)-x0(1));
if diff(x)>=diff(y)
x1=min(x):max(x);
yi=k0*(x1-x0(1))+y0(1);
y1=fix(yi-0.5)+1;
end

if diff(x)<diff(y)
y1=min(y):max(y);
xi=(y1-y0(1))/k0+x0(1);
x1=fix(xi-0.5)+1;
end
%%
lineinti1=[];
lineinti2=[];
for j=1:1:length(y1)
lineinti1(j)=img11(y1(j),x1(j));
lineinti2(j)=img22(y1(j),x1(j));
end
lineint1=lineinti1;
lineint2=lineinti2;
end
lineint1n=lineint1*255/max(lineint1);
lineint2n=lineint2*255/max(lineint2);
%%
if strcmp(color1{index1},'Gray')
    color1{index1}='Black';
end
if strcmp(color2{index2},'Gray')
    color2{index2}='Black';
end
pause(1)
close
hold on
plot(1:length(lineint1n),lineint1n,color1{index1},'linewidth',2)
plot(1:length(lineint2n),lineint2n,color2{index2},'linewidth',2)
axis square
xlim([0,length(lineint1n)])
ylim([0,max(max(lineint1n),max(lineint2n))*1.32])
px=length(lineint1n);
py=max(max(lineint1n),max(lineint2n));
plot(px*0.1:1:px*0.2,1.3*py*ones(1,length(px*0.1:1:px*0.2)),color1{index1},'linewidth',2);
plot(px*0.1:1:px*0.2,1.1*py*ones(1,length(px*0.1:1:px*0.2)),color2{index2},'linewidth',2);
text(px*0.25, 1.32*py,channel1,'fontname','Arial', 'fontsize',28,'color',color1{index1});
text(px*0.25, 1.11*py,channel2,'fontname','Arial', 'fontsize',28,'color',color2{index2});
set(gca,'fontname','Arial', 'fontsize',28,'LineWidth',1.5,'TickLength',[0.015 0.015])
xlabel('Position (pixel)','fontname','Arial', 'fontsize',28)
ylabel('Pixel intensity','fontname','Arial', 'fontsize',28)
saveas(gcf,[folder1s '/LineScan' ROI_number '.tif'])
saveas(gcf,[folder1s '/LineScan' ROI_number '.eps'])
pause(2)
close
%%
plot(lineint1n,lineint2n,'b.','MarkerSize',15)
box off
axis square
xlim([0,max(lineint1n)])
ylim([0,max(lineint2n)*1.32])
set(gca,'fontname','Arial', 'fontsize',28,'LineWidth',1.5,'TickLength',[0.015 0.015])
xlabel([channel1 ' pixel intensity'],'fontname','Arial', 'fontsize',28)
ylabel([channel2 ' pixel intensity'],'fontname','Arial', 'fontsize',28)
% title('Line','fontname','Arial')
%% fitting to a line
p=polyfit(lineint1n,lineint2n,1);
x=min(lineint1n):0.1:max(lineint1n);
y=polyval(p,x);
hold on
plot(x,y,'r','linewidth',2);
r1=corrcoef(lineint1n,lineint2n); %% correlation coefficient
r2=num2str(r1(2,1)^2);
r=r2(1:4);
%%
s1=max(lineint1n)*0.1;
s2=max(lineint2n)*1.2;
text(s1, s2,['R^2 = ' r],'fontname','Arial', 'fontsize',28)
saveas(gcf,[folder1s '/LineTwoColor' ROI_number '.tif'])
saveas(gcf,[folder1s '/LineTwoColor' ROI_number '.eps'])
lineint1=lineint1';
lineint2=lineint2';
if strcmp(channel1,channel2) 
save([folder1s '/' channel1 '1 LineInt' ROI_number '.txt'],'-ascii','-TABS','lineint1');
save([folder1s '/' channel2 '2 LineInt' ROI_number '.txt'],'-ascii','-TABS','lineint2');
else
save([folder1s '/' channel1 ' LineInt' ROI_number '.txt'],'-ascii','-TABS','lineint1');
save([folder1s '/' channel2 ' LineInt' ROI_number '.txt'],'-ascii','-TABS','lineint2');
end

end
end
end