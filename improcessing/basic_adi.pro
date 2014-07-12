pro basic_adi, ims, derot, finim, psf, meanpsf=meanpsf, meancomb=meancomb, $
                     radsub=radsub, radpolydeg=radpolydeg, nomedsub=nomedsub, nearby=nearby,$
                     annwidth=annwidth, ppfw=ppfw, minrotfw=minrotfw, psfsub=psfsub, usm=usm
;+
; NAME: 
; 
; DESCRIPTION:
;   Performs basic angular differential imaging (ADI) reduction on a dark subtracted and registered 
;   cube of images.  Most work is done in place, so the input image cube, ims, is modified.  On output 
;   it contains the rotated and PSF subtracted individual images
;
; INPUTS:
;   ims     :  a cube of images with format [dim1, dim2, number_of_images], already dark subtracted. 
;              ims is modified by this routine, on output it contains the psf-subtracted and de-rotated individual images
;   derot   :  a vector of rotation angles, one for each image in the cube
;
; INPUT KEYWORDS:
;   meanpsf    : if set, PSFs are formed as the mean.  default is median
;   meancomb   : if set, the final image is formed as a mean.  default is median
;   radsub     : if set, the radial profile is subtracted from each image. 
;   radpolydeg : the degree of the polynomial fit for the radial profile, default is 5
;   nomedsub   : if set, the median of each image is not subtracted (usually after radial profile subtracted)
;
; OUTPUTS:
;   finim   : the final image
;   psf     : the master psf
;
; OUTPUT KEYWORDS:
;  none
;
; MODIFICATION HISTORY:
;  Written 2012/12/12 by Jared Males (jrmales@email.arizona.edu)
;
; BUGS/WISH LIST:
;  Need to further test the nearby PSF facility.
;
;-

dim1 = (size(ims))[1]
dim2 = (size(ims))[2]
nims = (size(ims))[3]

   
;Default is to do median subtraction, check if keyword turned it off.
domedsub =1
if(keyword_set(nomedsub)) then domedsub = 0

;going to need this twice, so do it now
r=rarr(dim1, dim2, /pix)


;radial profile subtraction
if(keyword_set(radsub)) then begin

   if(n_elements(radpolydeg) lt 1) then radpolydeg  = 5
   
   if(domedsub) then begin
      print, '------- Subtracting radial profiles and image medians -------'
      print, 'poly degrees = ', radpolydeg
   endif else begin
      print, '------- Subtracting radial profiles -------'
      print, 'poly degrees = ', radpolydeg
   endelse

   sdx = sort(r)

   for i=0, nims-1 do begin
      status = strcompress(string(i+1) + '/' + string(nims), /rem)
      statusline, status, 0

      imr = (ims[*,*,i])[sdx]
      
      findx = where(finite(imr))
      c = poly_fit((r[sdx])[findx], imr[findx], radpolydeg)

      rp = poly(r, c)
      ims[*,*,i] = ims[*,*,i] - rp
   
      if(domedsub) then ims[*,*,i] = ims[*,*,i] - median(ims[*,*,i])
   endfor
   
   statusline, /clear
   
endif

;radial profile subtraction
if(keyword_set(usm)) then begin
  
   if(domedsub) then begin
      print, '------- Unsharp masking and subtracting image medians -------'
      print, 'kernel fwhm = ', usm
   endif else begin
      print, '------- Unsharp masking -------'
      print, 'kernel fwhm = ', usm
   endelse


   for i=0, nims-1 do begin
      status = strcompress(string(i+1) + '/' + string(nims), /rem)
      statusline, status, 0

      ims[*,*,i] = ims[*,*,i] - filter_image(ims[*,*,i], fwhm_g=usm)
   
      if(domedsub) then ims[*,*,i] = ims[*,*,i] - median(ims[*,*,i])
   endfor
   
   statusline, /clear
   
endif

   ;If we didn't subtract the radprof, then we might still subtract the median
   
   if(~keyword_set(radprof) and ~keyword_set(usm) and domedsub) then begin
      print, '------- Subtracting median of each image -------'

      for i=0, nims-1 do begin

         status = strcompress(string(i+1) + '/' + string(nims), /rem)
         statusline, status, 0
   
         ims[*,*,i] = ims[*,*,i] - median(ims[*,*,i])
      endfor
      
      statusline, /clear
      
   endif   


if(~keyword_set(meanpsf)) then begin
   print, '------- Forming master median PSF -------'
   print, "med start: ", systime()
   psf = median(ims, dim=3)
   print, "med stop: ", systime()
endif else begin
   print, '------- Forming master average PSF -------'
   psf = total(ims, 3)/double(nims)
endelse

print, '------- Subtracting master PSF -------'
for i=0,nims-1 do ims[*,*,i] = ims[*,*,i] - psf


print, 'De-rotating and combining'

psfsub=ims

print, "Derotating and combining: ", systime()
derotcomb_cube, finim, ims, derot, meancomb=keyword_set(meancomb)
print, "derot finished: ", systime()

print, 'Basic ADI done'

end
