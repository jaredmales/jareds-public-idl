;+
; NAME: 
;  astrofilt_vega
; 
; PURPOSE:
;   Load the HST CALSPEC Vega spectrum
;
; DESCRIPTION:
;   Reads in the HST CALSPEC Vega spectrum in the ASTROFILT_DATADIR.  The version contained in astrofilt
;   has been converted to microns for wavelength, and includes jansky and photon flux densities.
;
; INPUTS:
;   none
;
; OUTPUTS:
;   vegalam   : the profile scale, in microns.
;   vegaflam : the flux density at each wavelength, in [ergs/sec/cm^2/micron]
;   vegafnu  : the flux density at each wavelength, in [Jy]
;   vegafphot : the flux density at each wavelength, in [photons/sec/m^2/micron]
;
; KEYWORDS:
;   datadir : specifies the data directory.  if not set or empty, the environment is queried for ASTROFILT_DATADIR.
;             it may be advantageous to repass this after the first time to avoid further environment calls.
;
; MODIFICATION HISTORY:
;  Written 2013/02/20 by Jared Males (jrmales@email.arizona.edu)
;
; BUGS/WISH LIST:
;  None.
;
;-

pro astrofilt_vega, vegalam, vegaflam, vegafnu, vegafphot, datadir=datadir

if (n_elements(datadir) ne 1) then begin

   datadir = getenv('ASTROFILT_DATADIR')

   if (datadir eq '') then begin
   
      message, 'ASTROFILT_DATADIR environment variable not set'

      return

   endif
   
endif


fpath = strcompress(datadir + '/alpha_lyr_stis_005_converted.dat', /rem)

readcol, fpath, vegalam, vegaflam, vegafnu, vegafphot, /silent


end

