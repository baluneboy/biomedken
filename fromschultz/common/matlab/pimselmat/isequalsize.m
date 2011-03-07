function bln = isequalsize(a,b)
% isequalsize true when size of a same as b
bln = all(size(a)==size(b));