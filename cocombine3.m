function cocombine3(folder1,channel1,channel2,first_number,last_number)
%%
close
clc
folder1=folder1{1};
d1=dir(folder1);
seq=str2double(first_number):str2double(last_number);
%%
M1s=[];
M2s=[];
MOCs=[];
PCCs=[];
MOC1s=[];
PCC1s=[];
k1=0;
k2=[];
for i=1:1:length(d1)
if d1(i).isdir==0
file_name1=d1(i).name;
k1=k1+1;
if contains(num2str(seq),num2str(k1))==1
folder1s=[folder1 '/sum' file_name1];
d1s=dir(folder1s);
if isempty(d1s)
k2=[k2,k1];
end
for j=1:1:length(d1s)
        if d1s(j).isdir==0
            if contains(d1s(j).name,'M1')==1
                M1=load([folder1s '/' d1s(j).name]);
                M1s=[M1s,M1];
            end
            if contains(d1s(j).name,'M2')==1
                M2=load([folder1s '/' d1s(j).name]);
                M2s=[M2s,M2];
            end
%             if contains(d1s(j).name,'MOC(ROI)')==1
%                 MOC=load([folder1s '/' d1s(j).name]);
%                 MOCs=[MOCs,MOC];
%             end      
%             if contains(d1s(j).name,'MOC(TH)')==1
%                 MOC1=load([folder1s '/' d1s(j).name]);
%                 MOC1s=[MOC1s,MOC1];
%             end    
            if contains(d1s(j).name,'PCC')==1
                PCC=load([folder1s '/' d1s(j).name]);
                PCCs=[PCCs,PCC];
            end  
%             if contains(d1s(j).name,'PCC(TH)')==1
%                PCC1=load([folder1s '/' d1s(j).name]);
%                PCC1s=[PCC1s,PCC1];
%             end  
        end
    
end
end
end
end
close
error=0;
if isempty(k2)==1 && str2double(first_number)>0 && k1>=str2double(last_number)
else
    if str2double(first_number)==0
    h=msgbox(['error, image ' first_number ' does not exist']);
    ht=findobj(h,'Type','text');
    set(ht, 'fontname','Arial', 'fontsize', 16, 'Unit', 'normal');
    set(h,'position',[400 400 400 60])
    pause(2)
    close
    error=1;
    end
    if isempty(k2)==0
    h=msgbox(['error, data for image ' num2str(k2) ' does/do not exist']);
    ht=findobj(h,'Type','text');
    set(ht, 'fontname','Arial', 'fontsize', 16, 'Unit', 'normal');
    set(h,'position',[400 400 400 60])
    pause(2)
    close
    error=1;
    end
    if k1<str2double(last_number)
    h=msgbox(['error, image ' last_number ' does not exist']);
    ht=findobj(h,'Type','text');
    set(ht, 'fontname','Arial', 'fontsize', 16, 'Unit', 'normal');
    set(h,'position',[400 400 400 60])
    pause(2)
    close
    error=1;
    end

end

%%
if error==0
% M1_ave=mean(M1s);
% M1_std=std(M1s);
% M2_ave=mean(M2s);
% M2_std=std(M2s);
% MOC_ave=mean(MOCs);
% MOC_std=std(MOCs);
% PCC_ave=mean(PCCs);
% PCC_std=std(PCCs);
M1s=M1s';
M2s=M2s';
% MOCs=MOCs';
PCCs=PCCs'
% MOC1s=MOC1s';
% PCC1s=PCC1s';
%%
if ~exist([folder1 '/sum'],'dir') 
mkdir(folder1,'sum');
else
delete([folder1 '/sum/*.txt'])
delete([folder1 '/sum/*.tif'])
delete([folder1 '/sum/*.fig'])
end
%%
save([folder1 '/sum/M1.txt'],'-ASCII','-TABS','M1s');
save([folder1 '/sum/M2.txt'],'-ASCII','-TABS','M2s');
% save([folder1 '/sum/MOC (ROI).txt'],'-ASCII','-TABS','MOCs');
save([folder1 '/sum/PCC.txt'],'-ASCII','-TABS','PCCs');
% save([folder1 '/sum/MOC(TH).txt'],'-ASCII','-TABS','MOC1s');
% save([folder1 '/sum/PCC(TH).txt'],'-ASCII','-TABS','PCC1s');
% save([folder1 '/sum/M1_ave.txt'],'-ASCII','-TABS','M1_ave');
% save([folder1 '/sum/M1_std.txt'],'-ASCII','-TABS','M1_std');
% save([folder1 '/sum/M2_ave.txt'],'-ASCII','-TABS','M2_ave');
% save([folder1 '/sum/M2_std.txt'],'-ASCII','-TABS','M2_std');
% save([folder1 '/sum/MOC_ave.txt'],'-ASCII','-TABS','MOC_ave');
% save([folder1 '/sum/MOC_std.txt'],'-ASCII','-TABS','MOC_std');
% save([folder1 '/sum/PCC_ave.txt'],'-ASCII','-TABS','PCC_ave');
% save([folder1 '/sum/PCC_std.txt'],'-ASCII','-TABS','PCC_std');
%%
close
% set(gcf,'position',[10 150 500 500]);

subplot(1,3,1)
hc=histc(M1s,0:0.1:1);
bar(0.05:0.1:0.95,hc(1:end-1),1)
xlim([0 1])
axis square
set(gca,'fontname','Arial', 'fontsize',12)
xlabel(['M1 (' channel1 ')'],'fontname','Arial', 'fontsize',12)
ylabel('Frequency','fontname','Arial', 'fontsize',12)
subplot(1,3,2)
hc=histc(M2s,0:0.1:1);
bar(0.05:0.1:0.95,hc(1:end-1),1)
xlim([0 1])
axis square
set(gca,'fontname','Arial', 'fontsize',12)
xlabel(['M2 (' channel2 ')'],'fontname','Arial', 'fontsize',12)
ylabel('Frequency','fontname','Arial', 'fontsize',12)
% subplot(3,2,3)
% hc=histc(MOCs,0.9:0.01:1);
% bar(0.9:0.01:1,hc,1)
% xlim([0.9 1])
% set(gca,'fontname','Arial', 'fontsize',12)
% xlabel('MOC (ROI)','fontname','Arial', 'fontsize',16)
% ylabel('Frequency','fontname','Arial', 'fontsize',16)
subplot(1,3,3)
hc=histc(PCCs,0:0.1:1);
bar(0.05:0.1:0.95,hc(1:end-1),1);
xlim([0 1])
axis square
set(gca,'fontname','Arial', 'fontsize',12)
xlabel('PCC','fontname','Arial', 'fontsize',12)
ylabel('Frequency','fontname','Arial', 'fontsize',12)
% subplot(3,2,5)
% hc=histc(MOC1s,0:0.1:1);
% bar(0:0.1:1,hc,1)
% xlim([0 1])
% set(gca,'fontname','Arial', 'fontsize',12)
% xlabel('MOC (TH)','fontname','Arial', 'fontsize',16)
% ylabel('Frequency','fontname','Arial', 'fontsize',16)
% subplot(2,2,4)
% hc=histc(PCC1s,0:0.1:1);
% bar(0.05:0.1:0.95,hc(1:end-1),1)
% xlim([0 1])
% set(gca,'fontname','Arial', 'fontsize',12)
% xlabel('PCC (TH)','fontname','Arial', 'fontsize',16)
% ylabel('Frequency','fontname','Arial', 'fontsize',16)

saveas(gcf,[folder1 '/sum/hist.tif'])
saveas(gcf,[folder1 '/sum/hist.fig'])
end
end
