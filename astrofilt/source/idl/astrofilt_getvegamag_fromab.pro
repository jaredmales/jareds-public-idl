;+
; NAME: astrofilt_getvegamag_fromab
; 
; DESCRIPTION:
;   Gets the Vega magnitude for an input AB magnitude, in a specified filter bandpass.
;
; INPUTS:
;   filtlam  :  filter transmission wavelength scale, microns.  If fname set this is output
;   filtrans :  filter transmission.  If fname set this is output
;   abmag    :  the AB magnitude in this filter
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
function astrofilt_getvegamag_fromab, filtlam, filtrans, abmag, rsr=rsr, jansky=jansky, vega=vega, fname=fname, magvega=magvega, abmag_err=abmag_err, magerr=magerr 
   

;---Read in filter profile fname keyword used
if(n_elements(fname) gt 0) then begin
   astrofilt, fname, filtlam, filtrans, datadir=datadir, rsr=keyword_set(rsr)
endif

astrofilt_char, filtlam, filtrans, lambda0, f0lam, f0nu, f0phot, fwhm, weff, rsr=keyword_set(rsr), $
                    datadir=datadir, vega=vega, magvega=magvega
                    
abjy = 3631.*10^(-.4*abmag)

vegamag = -2.5*alog10(abjy/f0nu)

if(n_elements(abmag_err) eq 1) then magerr = sqrt(abmag_err^2 + (1.08*0.015)^2)

return, vegamag

end

