function strOut = keepalphanum(str)
% EXAMPLE
% str = 'series_5_bas_MoCoSeries';
% strOut = keepalphanum(str)

blnAlpha = isstrprop(str,'alpha');
blnDigit = isstrprop(str,'digit');
indKeep = find(blnAlpha + blnDigit);
strOut = str(indKeep); %#ok<FNDSB>