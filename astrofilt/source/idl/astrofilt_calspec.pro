;+
; NAME: 
;  astrofilt_calspec
; 
; PURPOSE:
;   Loads an HST CALSPEC spectrum
;
; DESCRIPTION:
;   Reads in the HST CALSPEC spectrum in the ASTROFILT_DATADIR/calspec directory.  The spectrum is
;   converted to microns for wavelength, and we also calculate jansky and photon flux densities.
;
; INPUTS:
;   sname  :  the name of the spectrum, e.g. "alpha_lyr" or "vega"
;
; OUTPUTS:
;   cslam   : the wavelength scale, in [microns].
;   csflam  : the flux density at each wavelength, in [ergs/sec/cm^2/micron]
;   csfnu   : the flux density at each wavelength, in [Jy]
;   csfphot : the flux density at each wavelength, in [photons/sec/m^2/micron]
;
; KEYWORDS:
;   datadir : specifies the data directory.  if not set or empty, the environment is queried for ASTROFILT_DATADIR.
;             it may be advantageous to repass this after the first time to avoid further environment calls.
;
; MODIFICATION HISTORY:
;  Written 2013/05/25 by Jared Males (jrmales@email.arizona.edu)
;
; BUGS/WISH LIST:
;  None.
;
;-
pro astrofilt_calspec, sname, cslam, csflam, csfnu, csfphot, datadir=datadir


if (n_elements(datadir) ne 1) then begin

   datadir = getenv('ASTROFILT_DATADIR')

   if (datadir eq '') then begin
   
      message, 'ASTROFILT_DATADIR environment variable not set'

      return

   endif
   
endif

csname = 'none'
if(sname eq 'alpha_lyr' or sname eq 'vega') then csname = 'alpha_lyr_stis_005.asc'
if(sname eq '1740346') then csname = '1740346_nic_002.ascii'

if(csname eq 'none') then begin
   message, 'calspec spectrum not found for ' + sname
   return
endif

fpath = strcompress(datadir + '/calspec/' + csname, /rem)

readcol, fpath, lam, flam, /silent

;Convert to Jansky's
csfnu = flam*3.33564095E+04  * (lam)^2

;Convert Flam to per micron
csflam = flam*1e4;

;Conver wavelength to microns
cslam = lam/1e4

;Calculate photon flux density
h = 6.62606957d-27 ;plancks constant, ergs/sec
c = 299792458.d ;speed of light, m/sec

csfphot = csflam/(h*c/(cslam*1d-6))*100.d^2


end

