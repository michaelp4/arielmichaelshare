function [ret] = labScript(x,y,yerr)
%Created BY Ofir Arad, Feb-6-2019.
%This script fits a non-linear model described by variable "test_model" to
%the data given by {xdata,ydata} with errors {edata}.
 
test_model='y~(b1*x+b2)';%model to be fitted, coefficeients are of the form b#
beta0=[1 1];%starting values for the coefficients
 
xdata=x; %x-data points
ydata=y; %y-data points
edata=yerr; % errors in y-data points
dd=1./(edata.*edata);
%creating the model, errors for this model based on sigma^{-2}
temp_nlm=fitnlm(xdata,ydata,test_model,beta0,'Weights',dd);
%temp_nlm=fitnlm(xdata,ydata,test_model,beta0,'Weights',edata.^(-2));
 
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
title('Fit test $\chi^2$','Interpreter','latex');
ylabel('y');
xlabel('x');
text(min(xdata),max(ydata),sprintf('y=b_1x+b_2\nb1=%f\\pm%f\nb2=%f\\pm%f\n\\chi^2=%f\nd.o.f-reduced \\chi^2=%f',temp_coeff(1,1),temp_coeff(1,2),temp_coeff(2,1),temp_coeff(2,2),temp_nlm.SSE,temp_nlm.MSE),'verticalAlignment','top')
hold off
end