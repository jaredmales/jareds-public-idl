pro pca_worker, psfsub, rims, rotoff, nmodes, mindq, err=err, msims=msims, nocovar=nocovar, silent=silent, indmean=indmean, modelrims=modelrims, modelsub=modelsub, imno=imno, maxdq=maxdq, dqisdn=dqisdn, regmedsub=regmedsub

dim1 = (size(rims))[1]
nims = (size(rims))[2]

dodouble = 0
if(size(rims, /type) eq 5) then dodouble = 1

if(~keyword_set(nocovar)) then begin

   pca_covarmat, err, rims, meansub=(keyword_set(indmean))

   if(arg_present(msims)) then msims = rims

endif

if(dodouble) then begin
   psfsub = dblarr(dim1, nims, n_elements(nmodes))
endif else begin
   psfsub = fltarr(dim1, nims, n_elements(nmodes))
endelse

domodel = 0

if(n_elements(modelrims) gt 1 and arg_present(modelsub)) then begin

   domodel = 1

   if(dodouble) then begin
      modelsub = dblarr(dim1, nims, n_elements(nmodes))
   endif else begin
      modelsub = fltarr(dim1, nims, n_elements(nmodes))
   endelse
   
endif

;Region median subtraction
doregmedsub = 0
if(keyword_set(regmedsub)) then doregmedsub = 1

if(n_elements(maxdq) lt 1) then maxdq = 1e5

roff = requad_angles(rotoff)

if(keyword_set(dqisdn)) then imnum=indgen(nims)

;Allocate klims now
actnmodes = max(nmodes)
klims = fltarr(dim1, actnmodes)

if(n_elements(imno) eq 1) then begin
   i0 = imno
   i1 = imno
endif else begin
   i0 = 0
   i1 = nims-1
endelse

for i=i0, i1 do begin

   if(keyword_set(dqisdn)) then begin
      idx = where(abs(imnum - imnum[i]) ge mindq)
      
   endif else begin
      dang = abs(angsub(roff,roff[i]))
      ;sdx = sort(dang)
      idx = where(dang ge mindq and dang le maxdq)
   endelse
   
   ;idx= idx[0:49]
   
   terr =  err[*, idx]
   terr =  terr[idx, *]

   tims = rims[*, idx]

   
   if(~keyword_set(silent)) then begin
      status = 'pca_worker: performing PCA for image ' + strcompress( string(i + 1) + ' / ' + string(nims), /rem) $
      + ' with ' + strcompress(string(n_elements(idx)), /rem) + ' R images.'
      statusline, status
   endif
   

   pca_klims, klims, terr, tims, actnmodes, /silent
   
   
   
   cfs = dblarr(actnmodes)
   
   if(domodel) then begin
      cfs_mod = dblarr(actnmodes)
      
      for j=0, actnmodes-1 do begin
      
         cfs[j] = klims[*,j]##transpose(rims[*,i])
         cfs_mod[j] = klims[*,j]##transpose(modelrims[*,i])
         
      endfor
      
   endif else begin
      for j=0, actnmodes-1 do cfs[j] = klims[*,j]##transpose(rims[*,i])
   endelse
   
   if(dodouble) then begin
      psf = dblarr(dim1)
      if(domodel) then psfmod = dblarr(dim1)
   endif else begin
      psf = fltarr(dim1)
      if(domodel) then psfmod = fltarr(dim1)
   endelse
   
   j = 0
   for k=0, n_elements(nmodes)-1 do begin
   
      donmodes = nmodes[k]
      
      if donmodes gt actnmodes then begin
         donmodes = actnmodes
      endif
      
      if(domodel) then begin
      
         for j=j, donmodes-1 do begin
            psf = psf + cfs[j]*klims[*,j]
            psfmod = psfmod + cfs_mod[j]*klims[*,j]
         endfor
         
         newim = rims[*,i] - psf
         psfsub[*,i, k] = newim
         if(doregmedsub) then psfsub[*,i, k] = psfsub[*,i, k] - median(psfsub[*,i, k])
         
         newim = modelrims[*,i] - psfmod
         modelsub[*,i,k] = newim;-median(newim)
         if(doregmedsub) then modelsub[*,i,k] = modelsub[*,i,k] - median(modelsub[*,i,k])
         
      endif else begin
      
         for j=j, donmodes-1 do psf = psf + cfs[j]*klims[*,j]
        
         newim = rims[*,i] - psf
         psfsub[*,i, k] = newim;-median(newim)
         if(doregmedsub) then psfsub[*,i, k] = psfsub[*,i, k] - median(psfsub[*,i, k])
         
      endelse
      
   endfor
      
   
endfor

statusline, /clear

end