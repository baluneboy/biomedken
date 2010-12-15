function CLim=selectcolorlim(b);
sHistText.strXType='Edges Log_{  10}';
sHistText.strXUnits='g^2/Hz';
sHistText.casYStub={'Number of Occurrences'};
sHistText.casYTypes={''};
sHistText.casYUnits={'count'};
sHistText.casUL={'UpLeft{1}','UpLeft{2}','12345678901234567890','UpLeft{4}'};
sHistText.casUR={'UpRight{1}','UpRight{2}','09876543210987654321','UpRight{4}'};
sHistText.strComment='Click 2 Color Limits';
sHistText.strTitle='Color Limit Histogram';
sHistText.casRS={{'RightSide{1}{1}','RightSide{1}{2}'};{'RightSide{2}{1}','RightSide{2}{2}'};{'RightSide{3}{1}','RightSide{3}{2}'}};
sHistText.strVersion='$Revision: 1.1 $';

if isstr(b)
   strHistFilename=b;
   load(strHistFilename)
else
   histEdges=[-inf -20:0.1:0 inf]; % log base 10
   histN=histc(log10(b(:)),histEdges);
   histEdges(1)=nan;histEdges(end)=nan;
end

hFigHist=plotgen2d(histEdges(:),histN(:),sHistText,'screen',[]);
[xMouse,yMouse]=ginput(2);
close(hFigHist.Figure1x1);
CLim=round(sort(xMouse(:)'));
