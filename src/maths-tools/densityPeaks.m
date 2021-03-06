%% wrapper function for density Peaks clustering
% usage:
% [L] = densityPeaks(X)
% where X is a 2xN matrix specifying co-ordinates of the points you want to cluster
% and L is a 1xN labelled matrix
%
function [L,center_idxs] = densityPeaks(X,varargin)

switch nargin
case 0
	help densityPeaks
	return
end

assert(length(size(X)) == 2,'first input should be a matrix')
if size(X,2) > size(X,1)
	X = X';
end


% options and defaults
options.method = 'gaussian';
options.percent = 2;
options.sigma = 20;
options.trim_halo = false;
options.n_clusters = Inf;
options.show_plot = false;
options.M = 10;

if nargout && ~nargin 
	varargout{1} = options;
    return
end

% validate and accept options
if iseven(length(varargin))
	for ii = 1:2:length(varargin)-1
	temp = varargin{ii};
    if ischar(temp)
    	if ~any(find(strcmp(temp,fieldnames(options))))
    		disp(['Unknown option: ' temp])
    		disp('The allowed options are:')
    		disp(fieldnames(options))
    		error('UNKNOWN OPTION')
    	else
    		options = setfield(options,temp,varargin{ii+1});
    	end
    end
end
elseif isstruct(varargin{1})
	% should be OK...
	options = varargin{1};
else
	error('Inputs need to be name value pairs')
end

d = pdist2(X,X);

[L, center_idxs] = cluster_dp(d, options);

if options.show_plot
    temp = figure; hold on
    c = lines(3);
    for i = 1:3
        plot(X(L==i,1),X(L==i,2),'+','Color',c(i,:))
    end
    prettyFig
end