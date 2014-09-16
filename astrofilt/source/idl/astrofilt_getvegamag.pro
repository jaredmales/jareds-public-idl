;+
; NAME: astrofilt_getvegamag
; 
; DESCRIPTION:
;   Gets the Vega magnitude for an input spectrum, in a specified filter bandpass.
;
; INPUTS:
;   filtlam  :  filter transmission wavelength scale, microns.  If fname set this is output
;   filtrans :  filter transmission.  If fname set this is output
;   splam    :  spectrum wavelength scale
;   spflam   :  the spectrum flux density (in ergs/sec/cm^2/micron, unless /jansky is set)
;
; OUTPUTS:
;   returns the Vega magnitudes
;
; INPUT KEYWORDS:
;   jansky  :  is set, the input spectrum is in Janskys.
;   vega    :  if empty, then the vega spectrum is read.  re-pass the result to save time next time.
;   fname   :  the astrofilt name of the bandpass.  if set, filter is read from astrofilt database
;   rsr     :  if set, the relative spectral response is returned by astrofilt for the filter fname
;
; MODIFICATION HISTORY:
;  Written 2013/02/28 by Jared Males (jrmales@email.arizona.edu)
;
;-
function astrofilt_getvegamag, filtlam, filtrans, splam, spflam, rsr=rsr, jansky=jansky, vega=vega, fname=fname, $
   spflam_err=spflam_err, mag_err=mag_err, cal_err=cal_err

if(n_elements(vega) lt 1) then begin
   astrofilt_calspec, 'vega',  vlam, vflam, vfnu, vfphot

   dlam = dblarr(n_elements(vlam))

   for i=0, n_elements(vlam)-2 do dlam[i] = vlam[i+1]-vlam[i]
   dlam[n_elements(vlam)-1] = dlam[n_elements(vlam)-2]


   vega = create_struct('lam', vlam, 'flam', vflam, 'fnu', vfnu, 'fphot', vfphot, 'units', 0, 'f', vflam, 'dlam', dlam)
   
endif

;---Read in filter profile fname keyword used
if(n_elements(fname) gt 0) then begin

   astrofilt, fname, filtlam, filtrans, datadir=datadir, rsr=keyword_set(rsr)

endif


if(keyword_set(jansky) and vega.units eq 0) then begin
   vega.f = vega.fnu
   vega.units = 1
endif 

if(~keyword_set(jansky) and vega.units eq 1) then begin
   vega.f = vega.flam
   vega.units = 0
endif 






;Interpolate both vega spectrum and the filter transmission onto the input spectrum wavelength grid
linterp, vega.lam, vega.f, splam, vegaft

linterp, filtlam, filtrans, splam, filtranst

idx = where(filtranst gt 0.)

if(idx[0] eq -1) then begin

 return, -999
 
endif

dlam = dblarr(n_elements(splam))

for i=0l, n_elements(splam)-2 do dlam[i] = splam[i+1]-splam[i]
dlam[n_elements(splam)-1] = dlam[n_elements(splam)-2]

ftot = total(filtranst[idx]*spflam[idx]*dlam[idx])

if n_elements(spflam_err) gt 1 then begin

   fvar = total((filtranst[idx]*spflam_err[idx]*dlam[idx])^2)
  
   if(n_elements(cal_err) eq 0) then cal_err = 0.
   mag_err = (2.5/alog(10.))*sqrt(fvar/ftot^2 + 0.015^2 + cal_err^2)
endif

return, -2.5*alog10(ftot/total(filtranst[idx]*vegaft[idx]*dlam[idx]))

end

