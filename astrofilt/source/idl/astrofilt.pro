;+
; NAME: 
;  astrofilt
; 
; PURPOSE:
;   Read a filter transmission curve from the astrofilt collection.
;
; DESCRIPTION:
;   Reads in a filter transmission curve from the astrofilt collection, usually found via the ASTROFILT_DATADIR
;   environment variable.  Astrofilt profiles are in wavelength of microns, and transmission normalized to peak 
;   of 1 and airmass 0.
;
; INPUTS:
;   fname   : the name of the filter, with no path or extension, e.g. 'J_NIRC2' or 'ip_VisAO'
;
; OUTPUTS:
;   lam   : the profile wavelength scale, in microns.
;   trans : the transmission at each lambda, normalized to a peak of 1 at 0 airmass.
;
; KEYWORDS:
;   rsr     : convert to relative spectral response, appropriate for photon detectors (like CCDs).  See
;           : Bessell, PASP, 112, 961 (2000).
;   datadir : specifies the data directory.  if not set or empty, the environment is queried for then
;             value of ASTROFILT_DATADIR. it may be advantageous to repass this after the first time 
;             to avoid further environment calls.
;
; MODIFICATION HISTORY:
;  Written 2013/02/18 by Jared Males (jrmales@email.arizona.edu)
;
; BUGS/WISH LIST:
;  None.
;
;-

pro astrofilt, fname, lam, trans, rsr=rsr, datadir=datadir, len=len


if (n_elements(datadir) ne 1) then begin

   datadir = getenv('ASTROFILT_DATADIR')

   if (datadir eq '') then begin
   
      message, 'ASTROFILT_DATADIR environment variable not set'

      return

   endif
   
endif


fpath = strcompress(datadir + '/' + fname + '.dat', /rem)

readcol, fpath, lam, trans, /silent

if(keyword_set(rsr)) then trans = trans*lam/max(trans*lam)



if (n_elements(len) gt 0) then begin

   clen = n_elements(lam)

   if(clen lt len) then begin
      lam = [lam, (findgen(len-clen)+1)*1e9]; make it sortable, but ignorable 
      trans = [trans, fltarr(len-clen)]
   endif
   
endif

end

