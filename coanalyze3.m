function coanalyze3(folder1,folder2,image_number,channel1,channel2,ROI_number)
%%
close
clc
folder1=folder1{1};
folder2=folder2{1};
image_number=str2double(image_number);
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

img1=double(imread([folder1 '/' file_name1] ));
img2=double(imread([folder2 '/' file_name2] ));
%%
error=0;
try
mask1=double(imread([folder1s '/mask' ROI_number '.tif']));
if strcmp(channel1,channel2) 
bw1=double(imread([folder1s '/bw' channel1 '1' ROI_number '.tif']));
bw2=double(imread([folder1s '/bw' channel2 '2' ROI_number '.tif']));
else
bw1=double(imread([folder1s '/bw' channel1 ROI_number '.tif']));
bw2=double(imread([folder1s '/bw' channel2 ROI_number '.tif']));
end
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
%% roi for the spot
xy=load([folder1s '/mask' ROI_number '.txt']);
row_low=round(min(xy(:,2)));
col_low=round(min(xy(:,1)));
row_high=round(max(xy(:,2)));
col_high=round(max(xy(:,1)));
mask11=mask1(row_low:row_high,col_low:col_high);
imgr1=img1(row_low:row_high,col_low:col_high);
imgr2=img2(row_low:row_high,col_low:col_high);
img11=imgr1.*mask11;
img22=imgr2.*mask11;
%% orginal intensity
[m0,n0]=size(img11);
x01=reshape(img11,[m0*n0,1]);
x02=reshape(img22,[m0*n0,1]);
[w1,k1]=find(x01>0);
x11=x01(w1);
x22=x02(w1);
%% binarized intensity (0,1) after thresholding
x1=reshape(bw1,[m0*n0,1]);
x2=reshape(bw2,[m0*n0,1]);
x3=x1.*x2;  %% overlap region (both channels are 1 simultaneous)
x111=x01.*x1;
x222=x02.*x2;
x11c=x01.*x3;
x22c=x02.*x3;
%% calculate the Manders' Colocalization Coefficients (MCC)
M1=sum(x11c)/sum(x111);
M2=sum(x22c)/sum(x222);
%% calculate the Manders' Overlap Coefficients (MOC)using thresholding
fenzi=sum((x111.*x222));
fenmu=sqrt(sum(x111.^2)*sum(x222.^2));
MOC1=fenzi/fenmu;
%% calculate the Pearson Correlation Coefficient (PCC)using thresholding
fenzi=sum((x111-mean(x111)).*(x222-mean(x222)));
fenmu=sqrt(sum((x111-mean(x111)).^2)*sum((x222-mean(x222)).^2));
PCC1=fenzi/fenmu;

%% calculate the Manders' Overlap Coefficients (MOC) using ROI
fenzi=sum((x11.*x22));
fenmu=sqrt(sum(x11.^2)*sum(x22.^2));
MOC=fenzi/fenmu;

%% calculate the Pearson Correlation Coefficient (PCC)using ROI
fenzi=sum((x11-mean(x11)).*(x22-mean(x22)));
fenmu=sqrt(sum((x11-mean(x11)).^2)*sum((x22-mean(x22)).^2));
PCC=fenzi/fenmu;
%%
close
x11n=x11*255/max(x11);
x22n=x22*255/max(x22);

plot(x11n,x22n,'b.','MarkerSize',15)
box off
axis square
xlim([0 max(x11n)])
ylim([0 max(x22n)])
set(gca,'fontname','Arial', 'fontsize',28,'LineWidth',1.5,'TickLength',[0.015 0.015])
xlabel('Position (pixel)','fontname','Arial', 'fontsize',28)
ylabel('Pixel intensity','fontname','Arial', 'fontsize',28)
% x_formatstring = '%6.0f';
% x_formatstring0 = '%1.0f';
% xtick = get(gca, 'xtick');
% xticklabel={};
% if max(xtick)>=10000 && length(xtick)>2
% xtick2=[xtick(1),xtick(3)];
% xticklabel{1} = sprintf(x_formatstring0, xtick(1));
% xticklabel{2} = sprintf(x_formatstring, xtick(3));
% set(gca, 'xtick',xtick2, 'xticklabel', xticklabel); 
% else
% for i = 1:length(xtick)
% xticklabel{i} = sprintf(x_formatstring, xtick(i));
% set(gca, 'xticklabel', xticklabel); 
% end
% end

% y_formatstring = '%6.0f';
% ytick = get(gca, 'ytick');
% yticklabel={};
% for i = 1:length(ytick)
%     yticklabel{i} = sprintf(y_formatstring, ytick(i));
% end
% set(gca, 'yticklabel', yticklabel); 
xlabel([channel1 ' pixel intensity'],'fontname','Arial', 'fontsize',28)
ylabel([channel2 ' pixel intensity'],'fontname','Arial', 'fontsize',28)
% title('ROI','fontname','Arial','fontsize',20)
saveas(gcf,[folder1s '/Scatterplot' ROI_number '.tif'])
saveas(gcf,[folder1s '/Scatterplot' ROI_number '.eps'])
pause(1)
close


% plot(x111,x222,'b.','MarkerSize',15)
% box off
% axis square
% xlim([0 max(x111)])
% ylim([0 max(x222)])
% set(gca,'fontname','Arial', 'fontsize',28,'LineWidth',1.5,'TickLength',[0.015 0.015])
% x_formatstring = '%6.0f';
% x_formatstring0 = '%1.0f';
% xtick = get(gca, 'xtick');
% xticklabel={};
% if max(xtick)>=10000 && length(xtick)>2
% xtick2=[xtick(1),xtick(3)];
% xticklabel{1} = sprintf(x_formatstring0, xtick(1));
% xticklabel{2} = sprintf(x_formatstring, xtick(3));
% set(gca, 'xtick',xtick2, 'xticklabel', xticklabel); 
% else
% for i = 1:length(xtick)
% xticklabel{i} = sprintf(x_formatstring, xtick(i));
% set(gca, 'xticklabel', xticklabel); 
% end
% end
% y_formatstring = '%6.0f';
% ytick = get(gca, 'ytick');
% yticklabel={};
% for i = 1:length(ytick)
%     yticklabel{i} = sprintf(y_formatstring, ytick(i));
% end
% set(gca, 'yticklabel', yticklabel); 
% % set(gca,'position',[0.2 0.3 0.6 0.6])
% % vec_pos = get(get(gca, 'XLabel'), 'Position');
% % set(get(gca, 'XLabel'), 'Position', vec_pos+[0 -2500 0] );
% xlabel([channel1 ' pixel intensity'],'fontname','Arial', 'fontsize',28)
% ylabel([channel2 ' pixel intensity'],'fontname','Arial', 'fontsize',28)
% title('TH','fontname','Arial')
% saveas(gcf,[folder1s '/Scatterplot(TH)' ROI_number '.tif'])

pause(1)
close

bar([M1,M2,PCC])
% bar([M1,M2,PCC,MOC])
% bar([M1,M2,MOC,MOC1,PCC,PCC1])
axis square
box off
ylim([0 1])
xlim([0 4])
% xlim([0 5])
set(gca,'fontname','Arial', 'fontsize',28 ,'LineWidth',1.5,'TickLength',[0.015 0.015])
ylabel('Coefficient value','fontname','Arial', 'fontsize',28)
% xlabel('M1','fontname','Arial', 'fontsize',28)
str={['M1 (' channel1 ')'],['  M2 (' channel2 ')'],'PCC'};
set(gca,'XTickLabel',str,'fontname','Arial', 'fontsize',22)
set(gca,'XTickLabelRotation',45)
saveas(gcf,[folder1s '/barplot' ROI_number '.tif'])
saveas(gcf,[folder1s '/barplot' ROI_number '.eps'])

if strcmp(channel1,channel2) 
save([folder1s '/' channel1 '1 Int' ROI_number '.txt'],'-ASCII','-TABS','x11');
save([folder1s '/' channel2 '2 Int' ROI_number '.txt'],'-ASCII','-TABS','x22');
% save([folder1s '/' channel1 '1 Int(TH)' ROI_number '.txt'],'-ASCII','-TABS','x111');
% save([folder1s '/' channel2 '2 Int(TH)' ROI_number '.txt'],'-ASCII','-TABS','x222');
save([folder1s '/M1 (' channel1 '1)' ROI_number '.txt'],'-ASCII','-TABS','M1');
save([folder1s '/M2 (' channel2 '2)' ROI_number '.txt'],'-ASCII','-TABS','M2');
else
save([folder1s '/' channel1 ' Int' ROI_number '.txt'],'-ASCII','-TABS','x11');
save([folder1s '/' channel2 ' Int' ROI_number '.txt'],'-ASCII','-TABS','x22');
% save([folder1s '/' channel1 ' Int(TH)' ROI_number '.txt'],'-ASCII','-TABS','x111');
% save([folder1s '/' channel2 ' Int(TH)' ROI_number '.txt'],'-ASCII','-TABS','x222');
save([folder1s '/M1 (' channel1 ')' ROI_number '.txt'],'-ASCII','-TABS','M1');
save([folder1s '/M2 (' channel2 ')' ROI_number '.txt'],'-ASCII','-TABS','M2');
end
% save([folder1s '/MOC(ROI) ' ROI_number '.txt'],'-ASCII','-TABS','MOC');
save([folder1s '/PCC ' ROI_number '.txt'],'-ASCII','-TABS','PCC');
% save([folder1s '/MOC(TH) ' ROI_number '.txt'],'-ASCII','-TABS','MOC1');
% save([folder1s '/PCC(TH) ' ROI_number '.txt'],'-ASCII','-TABS','PCC1');
end
end
end
