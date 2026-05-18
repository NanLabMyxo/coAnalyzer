function coSelectROI3(folder1,folder2,image_number,channel1,channel2,contrast1,contrast2)
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
    set(ht, 'fontname','Arial', 'fontname','Arial', 'fontsize', 16, 'Unit', 'normal');
    set(h,'position',[400 400 400 60])
    pause(2)
    close    
    error=1;
end
% if strcmp(channel1,channel3) || strcmp(channel2,channel3)
% else
%     h=msgbox('error, channels does not match');
%     ht=findobj(h,'Type','text');
%     set(ht, 'fontname','Arial', 'fontsize', 16, 'Unit', 'normal');
%     set(h,'position',[400 400 400 60])
%     pause(2)
%     close  
%     error=1;
% end

%%
if error==0
if ~exist([folder1 '/sum' file_name1],'dir') 
mkdir(folder1,['sum' file_name1]);
else
% delete([folder1 '/sum' file_name1 '/*.txt'])
% delete([folder1 '/sum' file_name1 '/*.tif'])
end

folder1s=[folder1 '/sum' file_name1];
img1=double(imread([folder1 '/' file_name1] ));
img2=double(imread([folder2 '/' file_name2] ));
%% plot
close
% set(gcf,'position',get(0,'screensize'));
subplot(1,2,1)
imshow(img1,'DisplayRange',[min(min(img1)),1+max(min(min(img1)),max(max(img1))*contrast1)],'InitialMagnification','fit');
title(channel1,'fontname','Arial', 'fontsize',18)
subplot(1,2,2)
imshow(img2,'DisplayRange',[min(min(img2)),1+max(min(min(img2)),max(max(img2))*contrast2)],'InitialMagnification','fit');
title([channel2 ' (Select ROI) ... "press F to terminate the selection"'],'fontname','Arial', 'fontsize',14)

    

% pause(2)
% close
%%%%%%%%%%%% select ROI regions
% if strcmp(channel1,channel3)
% set(gcf,'position',get(0,'screensize'));
% imshow(img1,'DisplayRange',[min(min(img1)),max(max(img1))],'InitialMagnification','fit');
% title(channel1,'fontname','Arial', 'fontsize',18)
p1=zeros(size(img1));
% else
% set(gcf,'position',get(0,'screensize'));
% imshow(img2,'DisplayRange',[min(min(img2)),max(max(img2))],'InitialMagnification','fit');
% title(channel2,'fontname','Arial', 'fontsize',18)
% p2=zeros(size(img2));
% end
button=1;
i=0;
while button==1
keydown = waitforbuttonpress;
if (keydown == 1)
break;
end
i=i+1;
[p,xi,yi]=roipoly;
p1=p1+p;
[k,w]=find(p==1);
hold on
text(w(1),k(1),num2str(i),'color','r','fontname','Arial', 'fontsize',40);
plot(xi,yi,'r','linewidth',2)
% imagesc(p)
% close
p=uint16(p);
imwrite(p,[folder1s '/mask' num2str(i) '.tif'],'tiff','WriteMode','overwrite' )
xy=[xi,yi];
save([folder1s '/mask' num2str(i) '.txt'],'-ascii','-TABS','xy');
end
saveas(gcf,[folder1s '/ROIplot.tif'])
%%
% pause(1)
% close
subplot(1,2,1)
p2=img1.*p1;
set(gcf,'position',[20 378 560 420]);
imshow(p2,'DisplayRange',[min(min(img1)),1+max(min(min(img1)),max(max(img1))*contrast1)],'InitialMagnification','fit')
title(channel1,'fontname','Arial', 'fontsize',18)
subplot(1,2,2)
p2=img2.*p1;
set(gcf,'position',get(0,'screensize'));
imshow(p2,'DisplayRange',[min(min(img2)),1+max(min(min(img2)),max(max(img2))*contrast2)],'InitialMagnification','fit')
title(channel2,'fontname','Arial', 'fontsize',18)
saveas(gcf,[folder1s '/ROIplot2.tif'])
pause(2)
close

%% save the mask
p1=uint16(p1);
imwrite(p1,[folder1s '/mask.tif'],'tiff','WriteMode','overwrite' )
% save([folder1s '/cell_num.txt'],'-ascii','-TABS','i');

end
end
