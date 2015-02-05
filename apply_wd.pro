;This procedure takes the input AGB image and a matching type image and adjusts using WD for specified type

Pro apply_wd, agb_in_file, agb_out_file, type_file, wd_file, type_code, in_tl_x, in_tl_y, in_pix_size, xdim, ydim, mean_wd
	;agb_in file : input agb file   (assumes type integer)
	;agb_out_file : output agb file (assumes type integer)

	;type_file : type file for allometric equation select (byte)

	;wd_file : wood density image (float, and conforms to assumed specs)

	;type_code : which type code value to apply wd correction

	;in_tl_x : upper left corner of upper left pixel map coordinate in x
	;in_tl_y : upper left corner of upper left pixel map coordinate in y

	;in_pix_size : pixel size of agb_in_file

	;xdim : input file xdim
	;ydim : input file ydim

	;mean_wd : scale agb by (pixel wd) / mean_wd


	;read wd image
	wd_image = fltarr(8640,2300)
	openr, in_lun, wd_file, /get_lun
	readu, in_lun, wd_image
	free_lun, in_lun


	;WD correction
	in_agb_line = intarr(xdim)
	in_type_line = bytarr(xdim)
	out_agb_line = intarr(xdim)

	openr, in_agb_lun, agb_in_file, /get_lun
	openr, type_lun, type_file, /get_lun
	openw, out_agb_lun, agb_out_file, /get_lun

	adjust_flag = bytarr(xdim)

	for j=0ULL, ydim-1 do begin
		readu, in_agb_lun, in_agb_line
		readu, type_lun, in_type_line

		out_agb_line[*] = in_agb_line[*]

		adjust_flag[*] = 0

		if (n_elements(type_code) gt 1) then begin
			;more than 1 type to adjust
			for ii=0, n_elements(type_code)-1 do begin
				index = where((in_type_line eq type_code[ii]) and (in_agb_line gt 0), count)
				if (count gt 0) then adjust_flag[index] = 1
			endfor
			index = where(adjust_flag eq 1, count)
		endif else begin
			index = where((in_type_line eq type_code) and (in_agb_line gt 0), count)
		endelse

		if (count gt 0) then begin
			cur_lat = in_tl_y - double(j+0.5)*in_pix_size
			for i=0ULL, count-1 do begin
				cur_long = in_tl_x + double(index[i]+0.5)*in_pix_size
				cur_wd = get_wd(wd_image, cur_long, cur_lat)
				if (cur_wd ne 0) then out_agb_line[index[i]] = fix(in_agb_line[index[i]] * cur_wd / mean_wd)
			endfor
		endif

		writeu, out_agb_lun, out_agb_line

	endfor

	free_lun, in_agb_lun
	free_lun, type_lun
	free_lun, out_agb_lun

End
