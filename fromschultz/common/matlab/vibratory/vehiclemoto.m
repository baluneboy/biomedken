function otoResults=vehiclemoto(t,f,p,fc,strOutputFile);

% otoResults=vehiclemoto(f,p,fc);
%
% Inputs: t,f - vector for time & frequency values
%         p - matrix of PSD values
%         fc - scalar cutoff frequency
%         strOutputFile - string for complete path to output (CSV) file
%
% Output: otoResults - 4-column matrix of [otoBandNum flo fhi ugrms]
%
% EXAMPLE - dummy data (change blnDrawFigure to 1 to see 1st column of p processed output)
%   t=0:100:300;
%   f=(0:1/100:62.5/2)';
%   m=1e-10*(1:length(f));m=m(:);m=[m flipud(m)];
%   p=repmat(m,1,2);clear m
%   otoResults=vehiclemoto(t,f,p,0.03);

% Author: Ken Hrovat
% $Id: vehiclemoto.m 4160 2009-12-11 19:10:14Z khrovat $

% Initialize
blnDrawFigure=0;
pCol=1; % column of p to plot about
otoResults=[];

% Verify size of inputs & specified interval
[n,nc]=size(p); 
t=t(:)'; % rowize t
f=f(:);  % columnize f
df=f(2)-f(1); % T=1/df;
if length(t)~=nc, error('t does not have length equal to number of columns in p'), end
if length(f)~=n,  error('f does not have length equal to number of rows in p'), end
if df~=0.01, error('not using specified interval of 100 seconds (df should be 0.01 Hz)'), end

% Crop spectra at cutoff
iKeep=find(f<=fc);
f=f(iKeep);
p=p(iKeep,:);

% Get requirements (vehicle+payload levels in 4th column)
moto=otoissreq;
flo=moto(:,1);
fhi=moto(:,3);

% Create header row for output CSV file
if exist(strOutputFile)~=2
   locCreateHeaderRow(strOutputFile,flo,fhi);
end

% Derive some needed quantities
df=f(2)-f(1); % T=1/df;
iBands=find(fhi<=fc);
flo=flo(iBands);
fhi=fhi(iBands);

% Get stairsteps for simple integration
ff=0:df/2:max(f);
[n,nc] = size(p); 
ndx=[1:n;1:n];
pp=p(ndx(1:2*n-1),:); 
imax=find(ff<=fc);
ff=ff(imax);
pp=pp(imax,:);
[ff,pp]=stairs(ff(:),[pp(2:end,:); pp(end,:)]);
ff=ff(:,1);

if blnDrawFigure
   hFig=figure;
   set(hFig,'pos',[1 29 1280 928])
   plot(ff,pp(:,pCol),'r')
   hold on
   hro=plot(ff,pp(:,pCol),'ro');
   set(hro,'markersize',12)
   plot(f,p(:,pCol),'b*')
   set(gca,'tickdir','out')
   xlabel('Frequency (Hz)')
   ylabel('\SigmaPSD (g^2/Hz)')
   axis([0 0.05 0 5e-10])
end

% Build f values for cat
fcat=[ff; interleave(flo,fhi)];
fstairs=sort(fcat);
pstairs=linterpvectorized(ff,pp,fstairs);

% Get interpolated values in stairs form
[ff,pp]=stairs(fstairs,[pstairs(2:end,:); pstairs(end,:)]);
ff=ff(:,1);
M=unique([ff pp],'rows');
ff=M(:,1);
pp=M(:,2:end);
clear M

% Get set of index [iBegin iEnd] values for each band to be used in loop below
% (so this index finding does not have to be repeated for each column of PSDs)
% built for speed
F=ff(1:end-1);
numBands=length(iBands);
iLoHi=zeros(numBands,2);
for i=numBands:-1:1
   iBand=iBands(i);
   iAll=find(F>=flo(iBand) & F<fhi(iBand));
   iLoHi(iBand,:)=[iAll(1) iAll(end)];
end

% For rectangle by rectangle simple integration use this procedure
%
% ff1 ------- p1
%        /
%       /
%      /    diff(ff(1:2))*p1
%     /
%    /
% ff2 ------- p2
%        /
%       /
%      /    diff(ff(2:3))*p2
%     /
%    /
% ff3 ------- p3
%      :
%      :

% If memory was not an issue, then use vectorized version
deltaF=diff(ff);
%integratedRectangles=diag(deltaF*pp(1:end-1,:); % vectorized version for speed
%FA=[ff(1:end-1) integratedRectangles]; 
%for i=1:length(iBands)
%   iBand=iBands(i);
%   f1=flo(iBand);
%   f2=fhi(iBand);
%   iSum=find(FA(:,1)>=f1 & FA(:,1)<f2);
%   ugrms=sqrt(sum(FA(iSum,2:end),1))/1e-6;
%   otoResults=[otoResults; iBand f1 f2 ugrms];
%end
%fprintf('\niBand\t  f1\t  f2\tugrms ...\n--------------------------------------')
%strFormat=repmat('\t%.2f',1,nc);
%fprintf(['\n%d\t%.4f\t%.4f' strFormat],otoResults')

%%% OTHERWISE NON-VECTORIZED, use column-by-column (time) loop
fid=fopen(strOutputFile,'a');
otoResults=[];
for iCol=1:nCols(pp)
   results=[t(iCol)];
   integratedRectangles=deltaF.*pp(1:end-1,iCol);
   FA=[F integratedRectangles];
   for i=1:numBands
      iBand=iBands(i);
      iSum=iLoHi(iBand,1):iLoHi(iBand,2);
      ugrms=sqrt(sum(FA(iSum,2:end),1))/1e-6;
      results=[results ugrms];
   end
   strFormat=repmat(',%7.2f',1,numBands);
   fprintf(fid,['%s' strFormat '\n'],popdatestr(t(iCol),0),results(2:end));
   otoResults=[otoResults; results];
end
fclose(fid);

if blnDrawFigure
   plot(ff,pp(:,pCol),'ks')
   for i=1:length(iBands)+1;
      hline(i)=line([moto(i,1) moto(i,1)],[1e-22 1e22]);
      htext(i)=text(moto(i,2),0.5e-10,num2str(i));
   end
   set(hline,'linestyle',':')
   set(htext(end),'pos',[df/5 0.5e-10])
   set(htext(end),'str','OTO Band #')
   fprintf('\n\nhard code stop drawing rectangles at 11 bands\n\n')
   for i=1:length(iBands)
      iBand=iBands(i);
      f1=flo(iBand);
      f2=fhi(iBand);
      iFreq=find(ff>=f1 & ff<=f2);
      vertexStub=[ff(iFreq) pp(iFreq,pCol)];
      numRectangles=nRows(vertexStub)-1;
      a(iBand)=0;
      for j=1:numRectangles
         top2verts=vertexStub(j:j+1,:);
         width=diff(top2verts(1:2,1));
         height=top2verts(1,2);
         aRect=width*height;
         a(iBand)=a(iBand)+aRect;
         if blnDrawFigure & (iBand<11)
            locDrawRect(iBand,top2verts);
         end
      end
   end
   
end

%fprintf('\n\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locCreateHeaderRow(strOutputFile,flo,fhi);
fid=fopen(strOutputFile,'w');
numBands=length(flo);
strFormat=['date,time' repmat(',band #%d: %.4f-%.4f Hz',1,numBands) ,'\n'];
fprintf(fid,strFormat,[(1:numBands)' flo fhi]');
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rgb=locFillColor(otoband);
if iseven(otoband)
   rgb=0.7;
else
   rgb=0.8;
end
rgb=rgb*[1 1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locDrawRect(iBand,top2verts);
bot2verts=flipud(top2verts);
bot2verts(:,2)=0;
vertices=[top2verts; bot2verts];
hPhil=fill(vertices(:,1),vertices(:,2),locFillColor(iBand));
set(hPhil,'tag','phil','edgecolor',locFillColor(iBand));
send2back(hPhil);