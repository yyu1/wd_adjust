;This procedure takes the input AGB image and a matching type image and adjusts using WD for specified type
;this one assumes all the files are in the same projection and registered

Pro apply_wd_sameproj, agb_in_file, agb_out_file, type_file, wd_file, type_code, xdim, ydim, mean_wd
	;agb_in file : input agb file   (assumes type integer)
	;agb_out_file : output agb file (assumes type integer)

	;type_file : type file for allometric equation select (byte)

	;wd_file : wood density image (float, and conforms to assumed specs)

	;type_code : which type code value to apply wd correction

	;xdim : input file xdim
	;ydim : input file ydim

	;mean_wd : scale agb by (pixel wd) / mean_wd

	;WD correction
	in_agb_line = intarr(xdim)
	in_type_line = bytarr(xdim)
	in_wd_line = fltarr(xdim)
	out_agb_line = intarr(xdim)

	openr, in_agb_lun, agb_in_file, /get_lun
	openr, type_lun, type_file, /get_lun
	openr, in_wd_lun, wd_file, /get_lun
	openw, out_agb_lun, agb_out_file, /get_lun

	adjust_flag = bytarr(xdim)

	for j=0ULL, ydim-1 do begin
		readu, in_agb_lun, in_agb_line
		readu, type_lun, in_type_line
		readu, in_wd_lun, in_wd_line

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
			index2 = where(in_wd_line[index] gt 0, count2)
			if (count2 gt 0) then begin
				cur_wd = (in_wd_line[index])[index2]
				cur_agb = (in_agb_line[index])[index2]
				out_agb = out_agb_line[index]
				out_agb[index2] = fix(float(cur_agb)*cur_wd/mean_wd)
				out_agb_line[index] = out_agb
			endif
		endif

		writeu, out_agb_lun, out_agb_line

	endfor

	free_lun, in_agb_lun
	free_lun, in_wd_lun
	free_lun, type_lun
	free_lun, out_agb_lun

End
