function setallfontsize(p)
% setallfontsize(14); % changes ALL fontsizes to 14
set( findall(0, '-property', 'FontSize'), 'FontSize', p);