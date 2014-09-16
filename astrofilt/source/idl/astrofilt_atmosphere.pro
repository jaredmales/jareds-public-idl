pro astrofilt_atmosphere, atmlam, atmtrans, aname, am, pwv, datadir=datadir


if (n_elements(datadir) ne 1) then begin

   datadir = getenv('ASTROFILT_DATADIR')

   if (datadir eq '') then begin
   
      message, 'ASTROFILT_DATADIR environment variable not set'

      return

   endif
   
endif


if (aname eq 'cptrans_zm' or aname eq 'mktrans_zm' ) then begin

   fname = strcompress(datadir + '/../astrofilt_support/atm/' + aname + '_'  + string(pwv*10., format='(I)') + '_' + $ 
                   string(am*10., format='(I)') + '.dat', /rem)


   readcol, fname, atmlam, atmtrans, /silent

endif




if (aname eq 'paranal') then begin

   fname1 = strcompress(datadir + '/../astrofilt_support/atm/' + 'paranal_airm' + string(am, format='(F0.2)') + '_wav00.4-03.0.dat', /rem)
   
   fname2 = strcompress(datadir + '/../astrofilt_support/atm/' + 'paranal_airm' + string(am, format='(F0.2)') + '_wav03.0-06.0.dat', /rem)

   readcol, fname1, l1, t1, /silent
   readcol, fname2, l2, t2, /silent

   atmlam = [l1,l2]
   atmtrans = [t1,t2]
   
endif
end


