function [numerator,den] = getnumdenrsq(pTop,pBot)

numeratorSumTop = locSum(pTop,mean(pTop));
numeratorSumBot = locSum(pBot,mean(pBot));
numerator = numeratorSumTop + numeratorSumBot;


%-----------------------------------
function numeratorSum = locSum(p,mu)
numeratorSum = sum((p-mu)^2);
