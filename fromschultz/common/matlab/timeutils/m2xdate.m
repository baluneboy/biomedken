function dates = m2xdate(dates,convention,excelbug)

if nargin == 1
    convention = 0;
    excelbug = false;
elseif nargin == 2
    excelbug = false;
elseif nargin == 3
    excelbug = strcmpi(excelbug, 'ExcelBug');
else
    %print_usage ();
end

if convention == 0
    adj = datenum(1900, 1, 1) - 2;
elseif convention == 1
    adj = datenum(1904, 1, 1);
end

if excelbug
    datemask = (dates < datenum(1900, 3, 1));
    dates(datemask) = dates(datemask) - 1;
end
dates = dates - adj;
if any (dates < 0)
    warning ('Negative date found, this will not work within MS Excel.')
end

