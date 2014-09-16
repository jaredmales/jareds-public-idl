pro astrofilt_makesqwave, lam, trans, lam0, weff, dlam, len=len

nlam = floor(weff/dlam + .5) + 3.

lam = lam0-.5*weff-dlam + findgen(nlam)*dlam

trans = fltarr(nlam)

idx = where(lam ge lam0-.5*weff and lam le lam0+.5*weff)

trans[idx] = 1.


if (n_elements(len) gt 0) then begin

   clen = n_elements(lam)

   if(clen lt len) then begin
      lam = [lam, (findgen(len-clen)+1)*1e9]; make it sortable, but ignorable 
      trans = [trans, fltarr(len-clen)]
   endif
   
endif

end

