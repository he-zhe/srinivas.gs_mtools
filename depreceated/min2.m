% min2.m
% finds the minimum of a vector, ignoring Infs and NaNs
% 
% created by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function m = min2(x)

x(isnan(x)) = [];
x(isinf(x)) = [];

m = min(x);