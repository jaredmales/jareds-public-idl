;+
; NAME: 
;  astrofilt_watm
; 
; PURPOSE:
;  Multiply a filter transmission curve by an atmospheric transmission profile
;
; DESCRIPTION:
;  Multiplies a filter transmission curve by an atmospheric transmission profile.  Interpolates the
;  filter transmission onto the atmosphere wavelength scale and multiplies the result with the
;  atmosphere transmission.  Does not renormalize.
;
; INPUTS:
;   rawlam     :  raw filter curve wavelengths, in microns.  Is output if fname keyword used
;   rawtrans   :  raw filter curve transmission, in microns.  Is output if fname keyword used
;                 NOTE: rawlam and rawtrans should not be in RSR
;   atmlam     :  atmosphere transmission wavelengths, in microns
;   atmtrans   :  atmosphere transmission
;
; INPUT KEYWORDS:
;   fname   : the name of the filter, if set the filter is read from the astrofilt database
;   rsr     : convert to relative spectral response, appropriate for photon detectors (like CCDs), after
;             multiplying by atmosphere.  See Bessell, PASP, 112, 961 (2000).
;   datadir : specifies the data directory.  if not set or empty, the environment is queried for then
;             value of ASTROFILT_DATADIR. it may be advantageous to repass this after the first time 
;             to avoid further environment calls.
;
; OUTPUTS:
;   lam       : the new filter curve wavelength scale
;   transwatm : the new filter curve transmission 
;  
; MODIFICATION HISTORY:
;  Written 2013.05.11 by Jared Males (jrmales@email.arizona.edu)
;
; BUGS/WISH LIST:
;  None.
;
;-
pro astrofilt_watm, lam, transwatm, rawlam, rawtrans, atmlam, atmtrans, fname=fname, datadir=datadir, rsr=rsr


;---Read in filter profile fname keyword used
if(n_elements(fname) gt 0) then begin

   astrofilt, fname, rawlam, rawtrans, datadir=datadir

endif

idx = where(rawlam lt min(atmlam))

if(idx[0] eq -1) then begin
   terplam = 0.
   terpatm = 1.
endif else begin
   terplam = rawlam[idx]
   terpatm = dblarr(n_elements(idx)) + 1.
endelse


linterp, rawlam, rawtrans, [terplam,atmlam], terptrans


transwatm = terptrans * [terpatm, atmtrans]


idx = where([terplam,atmlam] ge min(rawlam) and [terplam,atmlam] le max(rawlam))

lam = ([terplam, atmlam])[idx]
transwatm = transwatm[idx]

if(keyword_set(rsr)) then transwatm = transwatm*lam/max(transwatm*lam)

end






