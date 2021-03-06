% makePDF.m
% a wrapper for MATLAB's publish() function, it makes a PDF directly from the .tex that MATLAB creates and cleans up afterwards.
% needs pdflatex installed. Will not work on Windows.
% usage:
% makePDF  % automatically builds PDF from last modified .m file
% makePDF --dirty % or 
% makePDF -d      % leaves all auxillary files in the publish folder (.aux, .tex, etc.) 
% makePDF --force % or
% makePDF -f      % overrides warnings about git status
% makePDF -f -d filename.m % builds PDF from filename.m
% 
% created by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
function [] = makePDF(varargin)

% defaults 
force = false;
dirty = false;
filename = '';

assert(~ispc,'makePDF cannot run on a Windows computer')
filename = findFileToPublish;
if ~nargin
else
	% figure out which arguments are options and handle them
	for i = 1:nargin
		if strcmp(varargin{i},'-f') || strcmp(varargin{i},'--force') 
			force = true;
		elseif strcmp(varargin{i},'-d') || strcmp(varargin{i},'--dirty') 
			dirty = true;
		elseif ~any(strfind(varargin{i},'-')) 
			filename = varargin{i};
			if strcmp(filename(end-1:end),'.m')
				filename = [filename '.m'];
			end
		end
	end
	assert(exist(filename,'file') == 2,'Cant find the file you told me to compile');
end

orig_dir = cd;
close all 

% compile to .tex
options.showCode = false;
options.format = 'latex';
options.imageFormat= 'pdf';
options.figureSnapMethod=  'print';


% use a custom stylesheet, if it exists
a = dir('*.xsl');
switch length(a)
	case 0
		% no custom stylesheet
	case 1
		% use this!
		options.stylesheet = a.name;
	case 2
		error('Too many custom stylesheets in working directory. makePDF does not know what to do. Make sure there is only one .xsl file in the working directory.')
end

% check to make sure all changes are committed to git
[~,m] = unix('git status | grep "modified" | wc -l');
if str2double(m) > 0 && ~force
	error('You have unmodified files that have not been committed to your git repo. Cowardly refusing to proceed till you commit all files.')
end

% run publish to generate the .tex file
f = publish(filename,options);

% tell stupid MATLAB to get the path right
[~,v] = unix('sw_vers -productVersion'); % Mac OS X specific
v = str2double(v);
path1 = getenv('PATH');
if v < 10.11
	if isempty(strfind(path1,':/usr/texbin'))
		path1 = [path1 pathsep '/usr/texbin'];
	end
	setenv('PATH', path1);
else
	if isempty(strfind(path1,':/Library/TeX/texbin'))
		path1 = [path1 pathsep '/Library/TeX/texbin'];
	end
	setenv('PATH', path1);
end

% move to the correct directory
cd('html')

% convert the .tex to a PDF
unix(['pdflatex ' f]);

% clean up
cd(orig_dir)
if ~dirty
	cleanPublish;
end
close all

f = strrep(f,'.tex','.pdf');

% archive this PDF in html/archive/ with the date and the git hash
if exist([fileparts(f) oss 'archive'],'file') == 7
else
	mkdir([fileparts(f) oss 'archive'])
end

[~,archive_file_name] = fileparts(f);
[~,git_hash] = unix('git rev-parse HEAD');
archive_file_name = [archive_file_name '-' datestr(today) '-' git_hash(1:7) '.pdf'];
archive_file_name = [fileparts(f) oss 'archive' oss archive_file_name];
copyfile(f,archive_file_name);

% % check if github release is installed
% path1 = getenv('PATH');
% if isempty(strfind(path1,':/usr/local/go/bin/bin'))
% 	path1 = [path1 pathsep '/usr/local/go/bin/bin'];
% end
% setenv('PATH', path1);
% [notok,temp] = unix('github-release');
% if ~notok
% 	% github-release is installed

% 	% load github token
% 	[~,github_token]=unix('echo $(<~/.git.yale.edu-token)');

% 	% make a tag name
% 	[~,tag_name] = fileparts(archive_file_name);

% 	% assume that the user tagged it and pushed the tags

% end

% open the PDF
open(f)

function filename = findFileToPublish()
	% run on the last modified file
	d = dir('*.m');

	% find the last modified file
	[~,idx] = max([d.datenum]);

	% name of file
	try
		filename = d(idx).name;
	catch
		error('MakePDF could not figure out which document you want to publish. Specify explicitly.')
	end

end

end