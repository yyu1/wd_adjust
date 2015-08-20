;Gets wood density value from image (which must be in memory and passed in)
function sin_to_ddlonlat, in_x, in_y
  ;MODIS definitions
  R_earth = 6371007.181   ;MODIS sinusoidal sphere radius in m
  PI = 3.141592653589793238d0
  HALF_PI = (PI * 0.5)
  return_lat = in_y / R_earth
  return_lon = in_x / (R_earth * cos(return_lat))
  return_val = [return_lon, return_lat]/PI*180.0d0
  return, return_val
end

Function get_wd_mod250m, wd_image, modx, mody
	;map information for wood density image
	tl_x = -180.0D
	tl_y = 39.00002040D
	pix_size = 0.00833333333333333D
	xdim = 43200ULL
	ydim = 11500ULL

	lonlat_coord = sin_to_ddlonlat(modx, mody)
	longitude = lonlat_coord[0]
	latitude = lonlat_coord[1]
	ind_x = long((longitude - tl_x) / pix_size)
	ind_y = long((tl_y-latitude) / pix_size)

	if ((ind_x ge 0) and (ind_x lt xdim) and (ind_y ge 0) and (ind_y lt ydim)) then return, wd_image[ind_x,ind_y]
	return, 0.

End
