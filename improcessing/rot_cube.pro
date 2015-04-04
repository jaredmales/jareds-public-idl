pro rot_cube, ims, rotangs, mask=mask, m0val=m0val, silent=silent


nims = (size(ims))[3]

if(n_elements(m0val) eq 0) then m0val = float('nan')

besilent = 0
if(keyword_set(silent)) then besilent = 1


if(n_elements(mask) gt 1) then begin
   get_cubedims(mask), maskd1, maskd2, maskn
endif


for i=0, nims-1 do begin

   if(~besilent) then begin
      status = 'rot_cube: ' + strcompress(string(i+1) + '/' + string(nims), /rem)
      statusline, status, 0
   endif
   
   ims[*,*,i] = rot(ims[*,*,i], -1.d*double(rotangs[i]), cubic=-0.5)

   if(n_elements(mask) gt 1) then begin
   
      if(maskn eq 1) then begin
         rmask = rot(mask, -1.d*double(rotangs[i]), cubic=-0.5)
      endif else begin
         rmask = rot(mask[*,*,i], -1.d*double(rotangs[i]), cubic=-0.5)
      endelse
      
      idx = where(rmask lt 1.)
      rmask[idx] = m0val
      
      ims[*,*,i] = ims[*,*,i]*rmask
   endif
      
endfor

if(~besilent) then begin
   statusline, /clear
endif

end

