pro snrmap, im, snrmap, dr, annwid, rad=rad, std=std, minrad=minrad, maxrad=maxrad, mask=mask, xmask=xmask, maxsnr=maxsnr, fwcor=fwcor
;+
; NAME: snrmap
;
; PURPOSE: 
;  Calculate a signal-to-noise (S/N or snr) map from an image
;
; DESCRIPTION:
;  Calculates the noise, as the standard deviation, in circular annuli of user-specified width, at user-specified radii.  This
;  noise vs. radius curve is then interpolated for each pixel in the image, which is divided by the resultant noise value.  A mask
;  can be specified, which excludes pixels from the standard deviation calculation.
;
; INPUTS
;    im :  the image from which to make a S/N map
;
; OPTIONAL INPUTS:
;    dr       :  the delta-r step size (default 1)
;    annwidth : the width of the annulus in which the standard deviation is calculated in (default 1)
;
; INPUT KEYWORDs:
;   minrad : minimum radius
;   maxrad : maximum radius
;   mask   : either a 1/0 mask which is the same size as im where only 1 pixels are used in calculating noise \
;            -or- a 3 element vector [x,y,r] describing a circular mask which is generated by this procedure 
;   xmask  : a 1/0 mask, which is treated the same as mask, except it is not used in the calculation of maxsnr
;   fwcor  : if set, this is the FWHM to use for the Student's-t correction
;
; OUTPUT:
;    snrmap  : 2D image which is the original image divided by the standard deviation at each radius
;
; OUTPUT KEYWORDS:
;    rad     : radius vector
;    std     : std deviation at each point in rad (the radius vector)
;    maxsnr  : the maximum S/N in the image, or in the masked region if applicable
;
; DEPENDENCIES:
;    rarr.pro (from mxlib)
;    make_apmask.pro (from mxlib)
;    linterp.pro (from astrolib)
;
; AUTHOR:
;    Jared Males (jaredmales@gmail.com)
;
; HISTORY:
;    Created in 2013
;     
; BUGS/WISHLIST:
;     Should provide smoothing capability via keywords.
; 
;-

;B = size(im)
get_cubedims, im, dim1, dim2, nims
;snrmap = fltarr(dim1,dim2, nims)

r=rarr(dim1, dim2, /pix)
rr = reform(r, dim1*dim2)
   
if(n_elements(dr) eq 0) then begin
   dr = 1
endif

if(n_elements(annwid) eq 0) then begin
   annwid = 1
endif

if(n_elements(mask) eq 3) then begin
   mx = mask[0]
   my = mask[1]
   mr = mask[2]
   
   idx = make_apmask(mx-0.5*(dim1-1), my-0.5*(dim2-1), mr, dim1*1., dim2*1.)
   mask = r*0. + 1
   mask[idx] = 0.
endif

rmax = max(r[where(im ne 0)])
rmin = min(r[where(im ne 0)])

nr = (rmax-rmin)/dr

std = fltarr(nr)
rad = fltarr(nr)

if(n_elements(mask) le 1) then mask = r*0.+1.
totmask = mask

if(n_elements(xmask) eq n_elements(mask)) then totmask = totmask*xmask

snrmap = fltarr(dim1, dim2, nims)
if(arg_present(maxsnr)) then maxsnr = fltarr(nims)

for z=0, nims-1 do begin

   zim = im[*,*,z]

   for i=0, n_elements(std)-1 do begin

      rad[i] = rmin+i*dr; + .5*dr

      if(n_elements(totmask) gt 1) then begin   
         idx = where(r ge rmin+i*dr - .5*annwid and r lt rmin + i*dr+.5*annwid and totmask ne 0)
      endif else begin
         idx = where(r ge rmin+i*dr -.5*annwid and r lt rmin + i*dr+dr+ .5* annwid)
      endelse
   
      if(n_elements(idx) gt 1) then begin
         std[i] = stdev(zim[idx])
      endif else begin
         std[i] = 0.
      endelse
      
      if(keyword_set(fwcor)) then begin
         std[i] = std[i]*sqrt(1 + 1./(2.*!pi*rad[i]/fwcor - 1))
      endif
      
   endfor


   linterp, rad, std, rr, snrim

   snrim = reform(snrim, dim1, dim2, /over)
   tsnrmap = zim/snrim
   idx = where(~finite(tsnrmap))

   if(idx[0] gt -1) then tsnrmap[idx] = 0.

   if(n_elements(minrad) gt 0 and n_elements(maxrad) gt 0) then begin

      idx = where(r lt minrad or r gt maxrad)
   
      if(idx[0] gt -1) then tsnrmap[idx] = 0.
 
;       idx = where(rad ge minrad and rad le maxrad)
;    
;       if (idx[0] gt -1) then begin
;          rad = rad[idx]
;          std = std[idx]
;       endif
   
   endif

   if(arg_present(maxsnr)) then begin
      if(n_elements(mask) gt 1) then begin
         maxsnr[z] = max(tsnrmap * (1-mask))
      endif else begin
         maxsnr[z] = max(tsnrmap)
      endelse
   endif

   snrmap[*,*,z] = tsnrmap

endfor ;z=0,nims-1

;print, snrmap[-1]
end
 


