;Gets wood density value from image (which must be in memory and passed in)

Function get_wd, wd_image, longitude, latitude
	;map information for wood density image
	tl_x = -180.0D
	tl_y = 39.04166259D
	pix_size = 0.04166666666666666D
	xdim = 8640ULL
	ydim = 2300ULL

	ind_x = long((longitude - tl_x) / pix_size)
	ind_y = long((tl_y-latitude) / pix_size)

	if ((ind_x ge 0) and (ind_x lt xdim) and (ind_y ge 0) and (ind_y lt ydim)) then return, wd_image[ind_x,ind_y]
	return, 0.

End
