pro rot_cube, ims, rotangs


nims = (size(ims))[3]


for i=0, nims-1 do begin

   status = 'rot_cube: ' + strcompress(string(i+1) + '/' + string(nims), /rem)
   statusline, status, 0
   
   ims[*,*,i] = rot(ims[*,*,i], -1.d*double(rotangs[i]), cubic=-.5)

endfor

statusline, /clear

end

