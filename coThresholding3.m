function coThresholding3(folder1,folder2,image_number,channel1,channel2,ROI_number,threshold1,threshold2,contrast1,contrast2)
%%
clc
close
folder1=folder1{1};
folder2=folder2{1};
image_number=str2double(image_number);
contrast1=str2double(contrast1);
contrast2=str2double(contrast2);
d1=dir(folder1);
d2=dir(folder2);

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
%%
error=0;
if k1==image_number && k2==image_number
else
    h=msgbox(['error, image ' num2str(image_number) ' does not exist']);
    ht=findobj(h,'Type','text');
    set(ht, 'fontname','Arial', 'fontsize', 16, 'Unit', 'normal');
    set(h,'position',[400 400 400 60])
    pause(2)
    close   
    error=1;
end

%%
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
mask11=mask1(row_low:row_high,col_low:col_high);
imgr1=img1(row_low:row_high,col_low:col_high);
imgr2=img2(row_low:row_high,col_low:col_high);
img11=imgr1.*mask11;
img22=imgr2.*mask11;
%% thresholding
bw1=imbinarize(img11,threshold1*max(max(img11)));
bw2=imbinarize(img22,threshold2*max(max(img22)));
bw1s=uint16(bw1);
bw2s=uint16(bw2);
if strcmp(channel1,channel2) 
imwrite(bw1s,[folder1s '/bw' channel1 '1' ROI_number '.tif'],'tiff','WriteMode','overwrite' )
imwrite(bw2s,[folder1s '/bw' channel2 '2' ROI_number '.tif'],'tiff','WriteMode','overwrite' )
else
imwrite(bw1s,[folder1s '/bw' channel1 ROI_number '.tif'],'tiff','WriteMode','overwrite' )
imwrite(bw2s,[folder1s '/bw' channel2 ROI_number '.tif'],'tiff','WriteMode','overwrite' )
end
%%
close
% set(gcf,'position',get(0,'screensize'));
[m,n]=size(img11);
k=m/n;
set(gcf,'position',[20 200 300 300*k+60]);
subplot(2,2,1)
set(gca,'positio',[0,1/2,0.97/2,0.97*300*k/(300*k+60)/2])
imshow(img11,'DisplayRange',[min(min(imgr1)),1+max(min(min(imgr1)),max(max(imgr1))*contrast1)],'InitialMagnification','fit');
title([channel1 ' (ROI)'],'fontname','Arial', 'fontsize',16)
subplot(2,2,2)
set(gca,'positio',[1/2,1/2,0.97/2,0.97*300*k/(300*k+60)/2])
imshow(img22,'DisplayRange',[min(min(imgr2)),1+max(min(min(imgr2)),max(max(imgr2))*contrast2)],'InitialMagnification','fit');
title([channel2 ' (ROI)'],'fontname','Arial', 'fontsize',16)
%%
[i1,j1]=find(bw1==1);
[i2,j2]=find(bw2==1);
% set(gcf,'position',[20 250 2*n 2*m]);
% set(gcf,'position',[20 250 550 550]);
subplot(2,2,3)
set(gca,'positio',[0,0,0.97/2,0.97*300*k/(300*k+60)/2])
imshow(img11,'DisplayRange',[min(min(imgr1)),1+max(min(min(imgr1)),max(max(imgr1))*contrast1)],'InitialMagnification','fit');
title([channel1 ' (TH)'],'fontname','Arial', 'fontsize',16)
hold on
plot(j1,i1,'r.')
subplot(2,2,4)
set(gca,'positio',[1/2,0,0.97/2,0.97*300*k/(300*k+60)/2])
imshow(img22,'DisplayRange',[min(min(imgr2)),1+max(min(min(imgr2)),max(max(imgr2))*contrast2)],'InitialMagnification','fit');
title([channel2 ' (TH)'],'fontname','Arial', 'fontsize',16)
hold on
plot(j2,i2,'r.')
saveas(gcf,[folder1s '/Thresholdingplot' ROI_number '.tif'])
end
end
end
