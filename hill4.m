% hill4.m
% 4-parameter Hill function
% usage: r = hill4(x,xdata)
% where x(1) specifies the maximum
% x(2) specifies the location of the inflection point
% x(3) specifies the steepness 
% x(4) specifies some offset (the value the function takes at very low values)
% Usage:
% r = hill(x,xdata)
% 
% created by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
function r = hill4(xdata,x)

if ~nargin 
	help hill4
	return
end



if isstruct(x)
	temp=x;
	x= [];
	x(1) = temp.A;
	x(2) = temp.k;
	x(3) = temp.n;
	x(4) = temp.offset;
	clear temp
end

if isstruct(xdata) % inputs in wrong order
	temp=xdata;
	xdata = x;
	x = [];
	x(1) = temp.A;
	x(2) = temp.k;
	x(3) = temp.n;
	x(4) = temp.offset;
	p = temp;
	% parameters so that FitModel2Data can read this
	p.A;
	p.k;
	p.offset;
	p.n;
	clear temp
end

A = x(1);
k = x(2);
n  =x(3);
offset = x(4);

r = A*xdata.^n;
r = r./(xdata.^n + k^n);
r= r+ offset;

	
% when xdata is negative, return 0
r(xdata<0) = offset;	