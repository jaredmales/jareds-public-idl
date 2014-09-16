pro astrofilt_normraw, infile, outfile, nozero=nozero


readcol, infile, inlam, intrans, /silent

idx = sort(inlam)
inlam = inlam[idx]
intrans=intrans[idx]

dlam = max(inlam)-min(inlam)

outlam = min(inlam) + dindgen(dlam/.01+1.) * .01


linterp, inlam, intrans, outlam, outrans

idx = where(outrans lt 0.)
if(idx[0] ne -1) then outrans[idx] = 0.

if(~keyword_set(nozero)) then begin
   outrans[0] = 0.0
   outrans[n_elements(outrans)-1]= 0.0
endif

forprint, textout=outfile, outlam, outrans/max(outrans), /nocomment

end

