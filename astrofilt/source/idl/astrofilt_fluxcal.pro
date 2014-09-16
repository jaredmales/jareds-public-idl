pro astrofilt_fluxcal, splam, spflam, filters, norm=norm, err_norm=err_norm, synmag=synmag, chi2=chi2

;filters is an array of structures:
;  filter.lam
;  filter.trans
;  filter.mag
;  filter.mag_err
;  filter.lam0
;

synmag = fltarr(n_elements(filters))

for i=0, n_elements(filters)-1 do begin

   synmag[i] = astrofilt_getvegamag(filters[i].lam, filters[i].trans, splam, spflam)

endfor

idx = where(filters[*].lam0 ge min(splam) and filters[*].lam0 le max(splam))

dmags = (filters[idx].mag - synmag[idx])

lsqmean, dmags, filters[idx].mag_err,  norm, err_norm

chi2 = mean( ((filters[idx].mag - (synmag[idx]+norm))/filters[idx].mag_err)^2)
end





