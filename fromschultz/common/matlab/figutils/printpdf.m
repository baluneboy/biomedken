function printpdf(H,strFile,strOrient)
% printpdf - prints figure to a pdf
%
% INPUTS
% H - figure to print
% strFile - string, filename (should have extension .pdf)
% strOrient - portrait or landscape [defaults to portrait]
% 
% OUTPUTS
% pdf file with plot
% 
% EXAMPLE
% H = figure;
% hLine = plot(1:11);
% strFile = 'c:\temp\yay_a_pdf.pdf';
% printpdf(H,strFile);
% printpdf(H,strFile,'landscape');

% Author - Krisanne Litinas
% $Id$

if nargin == 2
    strOrient = 'portrait';
end

switch strOrient
    case 'portrait'
        mPos = [0.5 0.5 7.5 10];
    case 'landscape'
        mPos = [0.5 0.5 10 7.5];
end

set(H,'paperposition',mPos)
set(H,'paperorientation',strOrient)
print(H,'-dpdf',strFile)