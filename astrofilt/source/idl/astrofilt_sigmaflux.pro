function astrofilt_sigmaflux, F0, sigma_F0,  mag, sigma_mag
;Calculates error in flux given error in 0 mag flux and magnitude

return, sqrt(  (sigma_F0^2 + (alog(10)/2.5)^2*F0^2*sigma_mag^2)*10.^(-2.*mag/2.5))

end

