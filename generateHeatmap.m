% function generateHeatmap(Y_diff,keySet)
function generateHeatmap(Y_diff)

Y_diff_abs = abs(Y_diff);

figure1 = figure;
colormap('summer');

axes1 = axes('Parent',figure1,...
    'Position',[0.121297841547394 0.11 0.727101412881008 0.815]);
hold(axes1,'on');

image(Y_diff_abs,'Parent',axes1,'CDataMapping','scaled');

axis(axes1,'tight');

set(axes1,'CLim',[0 10^ceil(log10(max(max(Y_diff_abs))))],'DataAspectRatio',[1 1 1],'Layer','top',...
    'XTick',1:length(Y_diff),'YTick',1:length(Y_diff),'XTickLabelRotation',90);

% set(axes1,'CLim',[0 1],'DataAspectRatio',[1 1 1],'Layer','top',...
%    'XTick',1:length(Y_diff),'XTickLabel',keySet,'YTick',1:length(Y_diff),'YTickLabel',keySet,'XTickLabelRotation',90);


% Create colorbar
colorbar('peer',axes1);
end
