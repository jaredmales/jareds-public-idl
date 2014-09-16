;+
; NAME: 
;  astrofilt_char
; 
; PURPOSE:
;   Characterize a filter using the HST CALSPEC Vega spectrum
;
; DESCRIPTION:
;   Calculates central wavelength, zero mag flux density, and filter width (FWHM and effective) for a filter.
;
; INPUTS:
;   lam     :  filter curve wavelengths, in microns.  Is output if fname keyword used
;   trans   :  filter curve transmission, in microns.  Is output if fname keyword used
;
; INPUT KEYWORDS:
;   fname   :  the name of the filter, if set the filter is read from the astrofilt database
;   rsr     : convert to relative spectral response, appropriate for photon detectors (like CCDs).  See
;           : Bessell, PASP, 112, 961 (2000).
;   datadir : specifies the data directory.  if not set or empty, the environment is queried for then
;             value of ASTROFILT_DATADIR. it may be advantageous to repass this after the first time 
;             to avoid further environment calls.
;   magvega : magnitude of Vega in this bandpass, default is 0.0 
;   vega    : a structure containing the Vega spectrum.  if empty, is filled in.  re-pass this structure
;             to avoid repeated loading of Vega.
;
; OUTPUTS:
;   lambda0 : the central wavelength, the transmission weighted average
;   f0lam   : flux density of a 0 magnitude star
;   f0nu    : flux density of a 0 magnitude star
;   f0phot  : flux density of a 0 magnitude star
;   fwhm    : FWHM, found by interpolation
;   weff    : effective width, such that f0lam*weff = integral(flam*dlam)*10^(.4*vegamag)
;
;  
; MODIFICATION HISTORY:
;  Written 2013/02/20 by Jared Males (jrmales@email.arizona.edu)
;  2013.05.11 changed input to lam, trans, and moved fname to keyword (Jared Males)
;
; BUGS/WISH LIST:
;  None.
;
;-
pro astrofilt_char, lam, trans, lambda0, f0lam, f0nu, f0phot, fwhm, weff, fname=fname, rsr=rsr, $
                    datadir=datadir, vega=vega, magvega=magvega
                  
if(n_elements(vega) lt 1) then begin
   astrofilt_calspec, 'vega',  vlam, vflam, vfnu, vfphot
   
   dlam = dblarr(n_elements(vlam))

   for i=0, n_elements(vlam)-2 do dlam[i] = vlam[i+1]-vlam[i]
   dlam[n_elements(vlam)-1] = dlam[n_elements(vlam)-2]


   vega = create_struct('lam', vlam, 'flam', vflam, 'fnu', vfnu, 'fphot', vfphot, 'units', 0, 'f', vflam, 'dlam', dlam)
endif



;---Default assumption is magvega = 0.03
if(n_elements(magvega) ne 1) then magvega = 0.;0.03

;---Read in filter profile fname keyword used
if(n_elements(fname) gt 0) then begin

   astrofilt, fname, lam, trans, rsr=keyword_set(rsr), datadir=datadir

endif

linterp, lam, trans, vega.lam, transt

tottrans = total(transt*vega.dlam)

lambda0 = total(vega.lam*transt*vega.dlam)/tottrans

dmag = 10.^(0.4*magvega) ;positive since we're increasing the flux

f0lam = total(vega.flam*transt*vega.dlam)/tottrans*dmag
f0nu = total(vega.fnu*transt*vega.dlam)/tottrans*dmag
f0phot = total(vega.fphot*transt*vega.dlam)/tottrans*dmag

weff = total(vega.flam*transt*vega.dlam)*dmag/f0lam

trans = trans/max(trans)

;FWHM determination
tm = where(trans eq 1)
tt = trans[0:tm[0]]
lamt = lam[0:tm[0]]
idx = sort(tt)
linterp, tt[idx], lamt[idx] , 0.5, HWLeft
tt = trans[tm[0]:*]
lamt = lam[tm[0]:*]
idx = sort(tt)
linterp, tt[idx], lamt[idx] , 0.5, HWRight

fwhm = HWRight-HWLeft


end




