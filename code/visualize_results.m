function visualize_results(out_atonia_index,out_DNE,s)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
thisF = figure('Visible','off');
movegui(thisF,'center')
thisF.Visible='on';
subplot(121)
l = plot(1:6,out_atonia_index(1:6),'Marker','s','MarkerSize',7,'LineWidth',1);
l.MarkerFaceColor = l.Color;
grid on
title(['Atonia index'])
xlim([0 7])
ylim([0 1])
set(gca,'XTick',1:6,'XTickLabel',{'REM','N1','N2','N3','NREM','W'})
ylabel('Atonia index')
subplot(122)
set(gca,'yscale','log')
hold on
for j = 1:6
    l = plot(1:9,out_DNE(9*(j-1)+1:9*(j-1)+9),'Marker','s','MarkerSize',7,'LineWidth',1);
    l.MarkerFaceColor = l.Color;
    grid on
end
title(['DNE'])
xlim([0 10])
set(gca,'XTick',1:9,'XTickLabel',{'1','3','5','25','50','75','95','97','99'})
xlabel('Percentile')
ylabel('EMG norm')
legend('REM','N1','N2','N3','NREM','W','Location','southeast')
sgtitle(s,'Interpreter','none')
end

