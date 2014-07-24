;+
; NAME: 
;   pca_covarmat
;
; DESCRIPTION:
;   Calculates the covariance matrix for a cube of images
;
; INPUTS:
;   rims     :  a cube of images with format [dim1, dim2, number_of_images] (possibly with a masked region removed). 
;
; INPUT KEYWORDS:
;   none
;
; KEYWORDS:
;   meansub  : if set, the mean of each image is first subtracted, modifying ims
;              this is the strict interpretation of Soummer et al.
;
; OUTPUTS:
;   err   : the covariance matrix with size [number_of_images, number_of_images] 
;
;
; MODIFICATION HISTORY:
;  Written 2013/01/26 by Jared Males (jrmales@email.arizona.edu)
;
; BUGS/WISH LIST:
;
;-
pro pca_covarmat, err, rims, meansub=meansub


;Do mean subtraction if requested
if(keyword_set(meansub)) then begin

   sz = size(rims)

   nims = sz[2]

   for i=0, nims-1 do begin
      
      mn = mean(rims[*,i])
      
      rims[*,i] = rims[*,i] - mn
         
   endfor
   
endif

;Now calculate the covariance matrix
err = rims ## transpose(rims)

; sz = size(rims)
; 
; npix = sz[1]
; nims = sz[2]
; 
; err = dblarr(nims, nims)
; 
; for i=0, nims-1 do begin
;    for j=0, nims-1 do begin
;       err[i,j] = total(rims[*,i]*rims[*,j])
;    endfor
; endfor


end

