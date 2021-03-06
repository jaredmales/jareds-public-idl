; subpix_centration.pro
; Katie Morzinski     2009 Feb 18     ktmorz@ucolick.org

; Centers images to subpixel accuracy.  (for saturated images)
; shifts by subpixel (tenth of pixel, from +/- 1 pixel around center

function subpix_centration, image, angle, oxb, oyb, box=box

   if(n_elements(angle) ne 1) then angle =180.
   if(n_elements(box) ne 1) then box = 128.
   
   targim = image
	target_image = image
	ref_image = rot(targim,angle,cubic=-0.5)

	;subarrays
	;box = 128
	r1 = box/2.-box/4.
	r2 = box/2.+box/4.-1
	nx = (size(target_image))[1]
	ny = (size(target_image))[2]
	target = target_image[nx/2.-box/2.:nx/2.+box/2.-1,ny/2.-box/2.:ny/2.+box/2.-1]
	refim = ref_image[nx/2.-box/2.:nx/2.+box/2.-1,ny/2.-box/2.:ny/2.+box/2.-1]

	; Line up arrays to sub-pixel accuracy
	; subpix.pro
	numx = (size(refim))[1]
	numy = (size(refim))[2]
	nsh = 21 ;number of shifts

	tcx = (numx-1)/2.;target center x
	tcy = (numy-1)/2.;target center y
	rsh = fltarr(numx,numy);refim shifted
	this_rsh = fltarr(numx,numy,nsh,nsh);this refim shifted
	this_diff = fltarr(numx,numy,nsh,nsh)
	this_stddev = fltarr(nsh,nsh)
	for i=0,nsh-1 do begin;shift in x direction
		for j=0,nsh-1 do begin;shift in y direction
			ox = (i-10)/10.;offset x
			oy = (j-10)/10.;offset y
			this_rsh[*,*,i,j] = rot(refim,0,1,tcx-ox,tcy-oy,cubic=-0.5)
			this_diff[*,*,i,j] = this_rsh[*,*,i,j] - target
			this_stddev[i,j] = stddev(this_diff[r1:r2,r1:r2,i,j])
		endfor;j
	endfor;i
	bs = array_indices([nsh,nsh],where(this_stddev eq min(this_stddev)),/dim);best shift
	oxb = ((bs[0]-10)/10.)/2.;best offset amount x
	oyb = ((bs[1]-10)/10.)/2.;best offset amount y

	lcx = (nx-1)/2.;large array center x
	lcy = (ny-1)/2.;large array center y
	
	result = rot(target_image,0,1,lcx+oxb,lcy+oyb,cubic=-0.5)

	return,result
end
