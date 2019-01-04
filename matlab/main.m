%% Load data
clear;
clc;
cd 'E:\Research\RA\songyan\gaokao\Gaokao_StataOpt\matlab_version';
format long
sample = csvread('../sample.csv',1,0);
% v = uint8([1:1:126]);
% C5 = nchoosek(v,uint8(4));
% C4 = nchoosek(v,uint8(3));
% C3 = nchoosek(v,uint8(2));
% C2 = nchoosek(v,uint8(1));
% save('combi126_4.mat', 'C5', 'C4', 'C3', 'C2')
load('combi126_4.mat')
% Get opt_parameter by GMM 
init_params = [0.01 0.0000001 0.002]'; %beta for sch_score and dist
params = init_params;
Emax = 2;

%% Version 1
% fun = @(x)GMM1(x, sample);
% options = optimset('PlotFcns',@optimplotfval); %, 'Maxfunevals', 50000
% % [x,fval, exitflag] = fmincon(fun,init_params, [],[],[],[],[],[],[],options)
% [x,fval, exitflag] = fminsearch(fun, init_params, options)
% params=x;

%% Version 2
fun = @(x)GMM2(x, sample, C2, C3, C4, C5, Emax);
options = optimset('PlotFcns',@optimplotfval, 'Display', 'iter'); %, 'Maxfunevals', 50000, 
% lb = [-inf, -inf, 0];
% ub = [inf, inf, 1];
% [x, fval, exitflag, output] = fmincon(fun,init_params, [],[],[],[],lb,ub,[],options)
[x,fval, exitflag, output] = fminsearch(fun, init_params, options)
init_params=x;