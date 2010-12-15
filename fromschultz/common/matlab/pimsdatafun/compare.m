function t=compare(parent1,parent2,varargin)
%
% COMPARE compares two objects and outputs the locations of differences between them
% This function handles nested structures, nested subarrays, arrays,
% strings, objects, and files.  In the case of objects, if the handles are
% passed to x1 and x2, the properties are obtained with the get function
% and the properties are compared.
%
%
% t=compare('x1','x2',OPTS)
%
% x1   = first object surrounded by single quotes
% x2   = second object surrounded by single quotes
% OPTS = print and tolerance options
%        tol  = tolerance for comparison between floats
%        file = if you wish to print the differences to a file,
%               enter a filename for it to be save as.  Must be
%               in single quotes.
%
% t    = logical that represents whether the two variables x1 & x2 are
% the same
%
% 01/09/2006

tol=eps;
fid=1;

if nargin<2;
  % need at least two items to compare
  error('Incorrect usage of Compare, Need at least two items to compare');
elseif nargin==3;
  % there is one option variable
  if ischar(varargin{1})
    % filename option
    fid=fopen(varargin{1},'w');
  elseif isnumeric(varargin{1});
    % tolerence option
    tol=varargin{1};
  else
    % any other class results in error
    error('Incorrect usage of Compare, Improper option');
  end
elseif nargin==4;
  % two option variables
  if ischar(varargin{1}) && isnumeric(varargin{2});
    % first cell is the filename option, second is tolerance variable
    fid=fopen(varargin{1},'w');
    tol=varargin{2};
  elseif ischar(varargin{1}) && isnumeric(varargin{1});
    % first cell is the tolerance option, second is filename variable
    fid=fopen(varargin{2},'w');
    tol=varargin{1};
  else
    % any other class results in error
    error('Incorrect usage of Compare, Improper option');
  end
elseif nargin>4;
  % too many input variables results in an error
  error('Incorrect usage of Compare, Too many input variables');
end


if evalin('caller',['exist(''' parent1 ''',''var'')']) && evalin('caller',['exist(''' parent2 ''',''var'')']);
  % the items to compare are variables
  x1=evalin('caller',parent1);
  x2=evalin('caller',parent2);
  if all(ishandle(x1(:))) && all(ishandle(x2(:)));
    % the items to compare are handles to an object
    b=questdlg('Are the input variables object handles?', ...
      'Handle Question', ...
      'Yes','No','No');
    if strcmp(b,'Yes');
      disp('Input variables are handles');
      x1=get(x1);
      x2=get(x2);
    end
  end
elseif evalin('caller',['exist(''' parent1 ''',''file'')']) && evalin('caller',['exist(''' parent2 ''',''file'')']);
  % the items to compare are files
  x1=dir(parent1);
  x2=dir(parent2);
  if x1.bytes~=x2.bytes;
    % the size of the two files are different
    fprintf(fid,['size(' parent1 ')~=size(' parent2 ')\n']);
    t=false;
    return
  else
    % the file sizes are the same, so now read in the files for comparison
    fid1=fopen(parent1,'r');
    fid2=fopen(parent2,'r');
    x1=fread(fid1,'float');
    x2=fread(fid2,'float');
    fclose(fid1);
    fclose(fid2);
  end
else
  % items are actual values passes using strings
  x1=evalin('caller',parent1);
  x2=evalin('caller',parent2);
  if all(ishandle(x1(:))) && all(ishandle(x2(:)));
    % the items to compare are handles to an object
    b=questdlg('Are the input variables object handles?', ...
      'Handle Question', ...
      'Yes','No','No');
    if strcmp(b,'Yes');
      disp('Input variables are handles');
      x1=get(x1);
      x2=get(x2);
    end
  end
  parent1='x1';
  parent2='x2';
  disp('Actual value was passed, so input 1 & 2 will be referred to as x1 and x2');
end

t=isequalwithequalnans(x1,x2);
if t
  % items are the same
  fprintf(fid,[parent1 ' and ' parent2 ' are the exact same.\n']);
else
  t=true;
  % items are different
  if strcmp(class(x1),class(x2));
    % the items are the same class
    if isstruct(x1);
      %x1 is a structure, send to function comparestruct
      t=comparestruct(parent1,x1,parent2,x2,tol,fid,t);
    elseif iscell(x1);
      %x1 is a cell, send to function comparecell
      t=comparecell(parent1,x1,parent2,x2,tol,fid,t);
    elseif isnumeric(x1) || ischar(x1) || islogical(x1);
      %x1 is a numeric, char, or logical, send to function comarenum
      t=comparenum(parent1,x1,parent2,x2,tol,fid,t);
    end
  else
    % the items are not the same class
    fprintf(fid,['classes are different: ' parent1 ' is a ' class(x1) ' , and ' parent2 ' is a ' class(x2) '\n']);
    t=false;
  end
end
if fid~=1;
  % close output file
  fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t=comparenum(parent1,x1,parent2,x2,tol,fid,t)
%function to compare numerics, strings, logicals, & chars

if ndims(x1)~=ndims(x2);
  % number of dimensions are different
  fprintf(fid,['ndims(' parent1 ')~=ndims(' parent2 ')\n']);
  t=false;
elseif any((size(x1)~=size(x2)));
  % sizes are different
  fprintf(fid,['size(' parent1 ')~=size(' parent2 ')\n']);
  t=false;
else
  % items have the same number of dimension and are the same size, so check
  % the contents.
  x1=double(x1);
  x2=double(x2);
  i=(abs(x1-x2)>tol); %find index of diff above tol
  if any(i(:));
    % there are some differences
    tmp=sprintf('%d ',find(i));
    txt=sprintf('%s([ %s])\n',parent1,tmp);
    fprintf(fid,txt);
    t=false;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t=comparecell(parent1,x1,parent2,x2,tol,fid,t)
%function to compare cell arrays

if ndims(x1)~=ndims(x2);
  % number of dimensions are different
  fprintf(fid,['ndims(' parent1 ')~=ndims(' parent2 ')\n']);
  t=false;
elseif any((size(x1)~=size(x2)));
  % sizes are different
  fprintf(fid,['size(' parent1 ') ~= size(' parent2 ')\n']);
  t=false;
else
  % items have the same number of dimension and are the same size, so check
  % the contents.
  for i=1:numel(x1);
    %loop through the elements of x1 and x2
    if strcmp(class(x1{i}),class(x2{i}));
      % classes are the same
      tmp1=sprintf('%s{%i}',parent1,i);
      tmp2=sprintf('%s{%i}',parent2,i);
      if isstruct(x1{i});
        % items are structures
        t=comparestruct(tmp1,x1{i},tmp2,x2{i},tol,fid,t);
      elseif iscell(x1{i});
        % items are cells
        t=comparecell(tmp1,x1{i},tmp2,x2{i},tol,fid,t);
      elseif isnumeric(x1{i}) || ischar(x1{i}) || islogical(x1{i});
        % items are numerics, strings, logicals, or chars
        t=comparenum(tmp1,x1{i},tmp2,x2{i},tol,fid,t);
      end
    else
      % classes are different
      fprintf(fid,['classes are different: ' parent1 '{' num2str(i) '}' ' is a ' class(x1{i}) ' , and ' parent2 '{' num2str(i) '}' ' is a ' class(x2{i}) '\n']);
      t=false;
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t=comparestruct(parent1,x1,parent2,x2,tol,fid,t)
% function to compare structures

if ndims(x1)~=ndims(x2);
  % number of dimensions are different
  fprintf(fid,['ndims(' parent1 ')~=ndims(' parent2 ')\n']);
  t=false;
elseif any((size(x1)~=size(x2)));
  % sizes are different
  fprintf(fid,['size(' parent1 ') ~= size(' parent2 ')\n']);
  t=false;
else
  % items have the same number of dimension and are the same size, so check
  % the contents.
  f1=fieldnames(x1); %get fieldnames for x1
  f2=fieldnames(x2); %get fieldnames for x2
  [c, i1, i2]=setxor(f1,f2); %find fieldnames that are not in both x1 and x2
  if ~isempty(c);
    % there are different fieldnames in x1 and x2
    t=false;
    if ~isempty(i1);
      %different fieldnames in x1
      tmp11=sprintf('%s ',f1{i1});
      fprintf(fid,['fieldnames different: ' parent2 ' does not contain fieldname(s)\n\t' tmp11 '\n']);
    end
    if ~isempty(i2);
      %different fieldnames in x2
      tmp12=sprintf('%s ',f2{i2});
      fprintf(fid,['fieldnames different: ' parent1 ' does not contain fieldname(s)\n\t' tmp12 '\n']);
    end
  end
  c=intersect(f1,f2); % get common fieldnames
  for i=1:numel(x1);
    %loop through structure array
    if ~isequalwithequalnans(x1(i),x2(i));
      %x1(i) is not equal to x2(i)
      for ii=1:length(c);
        %loop through fieldnames
        if ~isequalwithequalnans(x1(i).(c{ii}),x2(i).(c{ii}));
          % field contents are not the same
          dtxt1=sprintf('%s(%i).%s',parent1,i,c{ii});
          dtxt2=sprintf('%s(%i).%s',parent2,i,c{ii});
          if strcmp(class(x1(i).(c{ii})),class(x2(i).(c{ii})));
            % the class of the field contents are the same
            if isstruct(x1(i).(c{ii}));
              % field contents are structures
              t=comparestruct(dtxt1,x1(i).(c{ii}),dtxt2,x2(i).(c{ii}),tol,fid,t);
            elseif iscell(x1(i).(c{ii}));
              % field contents are cells
              t=comparecell(dtxt1,x1(i).(c{ii}),dtxt2,x2(i).(c{ii}),tol,fid,t);
            elseif isnumeric(x1(i).(c{ii})) || ischar(x1(i).(c{ii})) || islogical(x1(i).(c{ii}));
              % field contents are numerics, chars, or logicals
              t=comparenum(dtxt1,x1(i).(c{ii}),dtxt2,x2(i).(c{ii}),tol,fid,t);
            end
          else
            % field contents have different classes
            fprintf(fid,['classes are different: ' dtxt1 ' is a ' class(x1(i).(c{ii})) ' , and ' dtxt2 ' is a ' class(x2(i).(c{ii})) '\n']);
            t=false;
          end
        end
      end
    end
  end
end