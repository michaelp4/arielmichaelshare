function [ret] = newscript(x, y, xerr)
%Created BY Ofir Arad, Feb-6-2019.
%This script fits a non-linear model described by variable "test_model" to
%the data given by {xdata,ydata} with errors {edata}.
cosiderXerr = true;
test_model='y~(b1*x+b2)';%model t   o be fitted, coefficeients are of the form b#
beta0=[1 1];%starting values for the coefficients
 
xdata=x; %x-data points
ydata=y; %y-data points

edata=ones(1,length(ydata))/16000; % errors in y-data points

xErr = xerr;
dd=1./(edata.*edata);
%creating the model, errors for this model based on sigma^{-2}
% opts=statset('TolX',1e-300,'TolFun',1e-300);
temp_nlm=fitnlm(xdata,ydata,test_model,beta0,'Weights',dd);
if cosiderXerr
    slope = temp_nlm.Coefficients(1,1);
    edata = edata + xErr.'.*slope.Estimate*2;
    dd=1./(edata.*edata);
    temp_nlm=fitnlm(xdata,ydata,test_model,beta0,'Weights',dd);
end

temp_coeff=cell2mat(table2cell(temp_nlm.Coefficients));%fit coefficients
 
%the calculated errors need to be divided by a factor of RMSE to be 
%consistent with error analysis conventions
%RMSE is the Root Mean Squared Error which is the d.o.f reduced \chi^2
%SSE is the best fit \chi^2 value
%Why does fitnlm give an output multiplied by reduced chi2?
%Because it is equivalent to assuming that the sigmas only represent 
%relative weights of the data points, but the absolute scale of the sigmas
%is actually unknown.
temp_coeff(:,2)=temp_coeff(:,2)/temp_nlm.RMSE; 
temp_coeff
 
figure;
errorbar(xdata,ydata,edata,'b*');
hold on
xdiff=(max(xdata)-min(xdata));%just the difference between the x values
fplot(@(x) (temp_coeff(1,1)*x+temp_coeff(2,1)),[min(xdata)-xdiff/10,max(xdata)+xdiff/10]);
title('Big Ring Radius vs Wavelength','Interpreter','latex');
ylabel('Radius [m]');
xlabel('\lambda [nm]');
% addTrap(x,y,3,'-');
% addTrap(x,y,6,'r');
% addTrap(x,y,18,'y')
text(min(xdata),max(ydata),sprintf('y=b_1x+b_2\nb1=%d\\pm%d\nb2=%d\\pm%d\n\\chi^2=%d\nd.o.f-reduced \\chi^2=%d',temp_coeff(1,1),temp_coeff(1,2),temp_coeff(2,1),temp_coeff(2,2),temp_nlm.SSE,temp_nlm.MSE),'verticalAlignment','top')
hold off

end