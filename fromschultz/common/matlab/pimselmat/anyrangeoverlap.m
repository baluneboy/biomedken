function bln = anyrangeoverlap(r)
rt = r';
drt = diff(rt(:));
bln = any(drt(2:2:end)<=0);