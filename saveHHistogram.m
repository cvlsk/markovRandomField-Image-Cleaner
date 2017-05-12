% function to save a horizontal histogram
function saveHHistogram(filename,x,color)
if exist('color','var')~=1
    color = 'b';
end
barh(x,color);
ylim([0,length(x)+1]);
xlim([0,max(x)*1.2]);
alpha = max(x)*1.2/(length(x)+1);
daspect([alpha*3,1,1]);
set(gca,'FontSize',20,'LineWidth',1.5);
saveTightFigure(gcf,filename);
close;
