;+
; NAME: astrofilt_meanflux
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
function astrofilt_meanflux, filtlam, filtrans, splam, spflam, rsr=rsr, jansky=jansky, fname=fname


;---Read in filter profile fname keyword used
if(n_elements(fname) gt 0) then begin

   astrofilt, fname, filtlam, filtrans, datadir=datadir, rsr=keyword_set(rsr)

endif




linterp, filtlam, filtrans, splam, filtranst

idx = where(filtranst gt 0.)

dlam = dblarr(n_elements(splam))

for i=0l, n_elements(splam)-2 do dlam[i] = splam[i+1]-splam[i]
dlam[n_elements(splam)-1] = dlam[n_elements(splam)-2]

return, total(filtranst[idx]*spflam[idx]*dlam[idx])/total(filtranst[idx]*dlam[idx])

end

