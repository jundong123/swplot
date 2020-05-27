pro swplot


; test here
;reg = "conus"
;sen = "mhs"
;sat = "n19"
;ffn_ilist = "ffname.list"
;odir = "."

spawn, "pwd", fdn_cur
print, fdn_cur

ffn_sys=file_which("wrap.pro")
fdn_sys=file_dirname(ffn_sys);
print, fdn_sys
;cd, fdn_sys


; read/redirect stdin
line = ''

read, line, prompt="reg sen sat: "
ss = strsplit(line, /extract, count=nss)
print, "npara: ", nss
reg = ss[0]  &  sen = ss[1]  &  sat = ss[2]
if (nss eq 3) then begin
    fimg = 0
endif else if (nss eq 4) then begin
    fimg = fix(ss[3])
endif

read, line, prompt="file name list file: "
ffn_ilist = line
read, line, prompt="output folder: "
odir = line

print, reg, " ", sen, " ", sat, " ", fimg
print, ffn_ilist
print, odir

spawn, "mkdir -p " + odir


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; user modify: region and ndiv of axis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (strcmp(reg,'conus') eq 1) then begin
    ; conus
    reg_box = [-125.0, -65.0, 25.0, 50.0]
    nsdiv = [12, 5]
endif else if (strcmp(reg,'alaska') eq 1) then begin
    ; alaska
    reg_box=[-170.0, -130.0, 52.0, 72.0]
    nsdiv = [8, 4]
endif else if (strcmp(reg,'global') eq 1) then begin
    ; global
    reg_box = [-180.0, 180.0, -90.0, 90.0]
    nsdiv = [12, 6]
endif else begin
    ; user define, global default
    ;reg_box = [-90.0, -65.0, 34.0, 48.0]
    ;nsdiv = [5, 7]
    reg_box = [-180.0, 180.0, -90.0, 90.0]
    nsdiv = [12, 6]
endelse


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; no need to change below
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set data grid
;ns=[   3000l,   1250l]
;ds=[    0.02,   0.02]
ns = [3200l, 2400l]

dlon = (reg_box[1]-reg_box[0])
dlat = (reg_box[3]-reg_box[2])
print, "lon/lat range: ", reg_box[0], reg_box[1], reg_box[2], reg_box[3]

ds = [dlon/ns[0], dlat/ns[1]]
;print, ns, ds

; set map grid
xdiv = dlon / nsdiv[0]
ydiv = dlat / nsdiv[1]
print, "lon/lat div: ", xdiv, ydiv

s0=[reg_box[0]+ds[0]/2, reg_box[2]+ds[1]/2]

; paper position
position = [0.1, 0.2+0.01, 0.95, 0.9+0.01]

set_plot, 'z'
;device, decomposed=0

; color table
change_ct, r, g, b
ict_white=!D.N_Colors-1
ict_black = !D.N_Colors-2

ict_miss = !D.N_Colors-1
ict_nosnow = !D.N_Colors-3
ict_water = !D.N_Colors-4
ict_cold = !D.N_Colors-5

!p.background=ict_white


; read file list file, proc and output file list file
ffn_pr = ''
openr, unit,  ffn_ilist, /get_lun

while ~eof(unit) do begin
	readf, unit, ffn_pr
	print, ffn_pr
	fn_pr = file_basename(ffn_pr, '.hdf')


	;;;;;;;;;;;;;;;
	; data
	;;;;;;;;;;;;;;;
	fileID = EOS_SW_OPEN(ffn_pr, /read)
	result = EOS_SW_inqswath(ffn_pr, grid_name)
	gridID = EOS_SW_ATTACH(fileid, grid_name)
	success = EOS_SW_READFIELD(gridID, 'ScanTime_year', scn_year)
	success = EOS_SW_READFIELD(gridID, 'ScanTime_month', scn_mon)
	success = EOS_SW_READFIELD(gridID, 'ScanTime_dom', scn_day)
	success = EOS_SW_READFIELD(gridID, 'ScanTime_hour', scn_hour)
	success = EOS_SW_READFIELD(gridID, 'ScanTime_minute', scn_min)
	success = EOS_SW_READFIELD(gridID, 'ScanTime_second', scn_sec)
	success = EOS_SW_READFIELD(gridID, 'Longitude', lon)
	success = EOS_SW_READFIELD(gridID, 'Latitude', lat)
	success = EOS_SW_READFIELD(gridID, 'SFR', sfr)
	success = EOS_SW_DETACH(gridID)
	success = EOS_SW_CLOSE(fileID)
	lon = transpose(lon)
	lat = transpose(lat)
	sfr = float(transpose(sfr))

	sz=size(sfr,/dim)
	nsl=sz(0)
	nfov=sz(1)
	print, "nscan, nfov: ", nsl, nfov

	; find data in region and time
	flag_in = 0;
	for i1=0, nsl-1  do begin
		ind = where(lon[i1,*] ge reg_box[0] and lon[i1,*] le reg_box[1] $
				and lat[i1,*] ge reg_box[2] and lat[i1,*] le reg_box[3])
		if ind[0] ne -1  then begin
			flag_in = 1
			break
		endif
	endfor

	if (flag_in eq 1) then begin
		iscn0 = i1
	endif else begin
		print, "all outside"
		if (fimg eq 0) then begin
            continue
        endif
        iscn0 = 0
        print, "but force to plot"
	endelse

    if (flag_in eq 1) then begin
	    for i1=iscn0, nsl-1  do begin
		    ind = where(lon[i1,*] ge reg_box[0] and lon[i1,*] le reg_box[1] $
			    	and lat[i1,*] ge reg_box[2] and lat[i1,*] le reg_box[3])
		    if ind[0] eq -1  then begin
			    flag_in = 0
			    break
		    endif
	    endfor

	    if (flag_in eq 0) then begin
		    iscn1 = i1
	    endif else begin
		    iscn1 = i1 - 1
	    endelse
    endif else begin
        iscn1 = nsl-1
    endelse
	
	print, "iscan reg: ", iscn0, iscn1
	if (iscn1-iscn0 lt 1)  then begin
		print, "too few scanline"
	    continue
	endif

	;help
	;lon = lon[iscn0:iscn1,*]
	;lat = lat[iscn0:iscn1,*]
	;sfr = sfr[iscn0:iscn1,*]
	;help

	jday0 = julday(scn_mon[iscn0],scn_day[iscn0],scn_year[iscn0], $
			scn_hour[iscn0],scn_min[iscn0],scn_sec[iscn0])
	jday1 = julday(scn_mon[iscn1],scn_day[iscn1],scn_year[iscn1], $
			scn_hour[iscn1],scn_min[iscn1],scn_sec[iscn1])
	jday = (jday0 + jday1) / 2
	caldat, jday, mon, day, year, hour, min, sec

	;print, scn_year[iscn0], scn_mon[iscn0], scn_day[iscn0], $
	;		scn_hour[iscn0], scn_min[iscn0], scn_sec[iscn0]
	;print, scn_year[iscn1], scn_mon[iscn1], scn_day[iscn1], $
	;		scn_hour[iscn1], scn_min[iscn1], scn_sec[iscn1]
	print, "dttm: ", year, mon, day, hour, min

	cyear = string(year, format='(I04)')
	cmon = string(mon, format='(I02)')
	cday = string(day, format='(I02)')
	chour = string(hour, format='(I02)')
	cmin = string(min, format='(I02)')
	dttm = cyear + "-" + cmon + "-" + cday + " " $
			+ chour + ":" + cmin + "Z"

    if (strcmp(sat,'n18') eq 1) then begin
        snm = 'NOAA-18'
    endif else if (strcmp(sat,'n19') eq 1) then begin
        snm = 'NOAA-19'
    endif else if (strcmp(sat,'moa') eq 1) then begin
        snm = 'MetOp-A'
    endif else if (strcmp(sat,'mob') eq 1) then begin
        snm = 'MetOp-B'
    endif else if (strcmp(sat,'moc') eq 1) then begin
        snm = 'MetOp-C'
    endif else begin
        snm = strupcase(sat)
    endelse
	title = snm + " Liquid Equivalent Snowfall Rate " + dttm
	;print, title


	;;;;;;;;;;;;;;;;;;
	; regrid and scale
	;;;;;;;;;;;;;;;;;;
	loni = make_array(nsl+1, nfov+1)
	lati = make_array(nsl+1, nfov+1)
	;restore, 'fov_96_ab.sav'
	;a=a(3-(nfov-90)/2:92+(nfov-90)/2)
	a = findgen(nfov)*0 + 1.0
	fov_rect_1f, lon, lat, a, loni, lati

	sfr1 = make_array(ns[0], ns[1])
	sfr1 = sfr1 * 0 - 99
	r = call_external(fdn_sys+'/i_cal_s3.so', 'i_cal_s3', nfov, nsl, $
			loni, lati, sfr, ns, s0, ds, sfr1)
	;sfr1 = transpose(sfr1)
	print, "min, max: ", min(sfr1), max(sfr1)

	; scale
	imiss   = where(sfr1 eq -99)
	iwater  = where(sfr1 eq -10)
	icold   = where(sfr1 eq -13)
	inosnow = where(sfr1 eq   0)

	if imiss(0)   ne -1  then sfr1(imiss)   = 0
	if iwater(0)  ne -1  then sfr1(iwater)  = 0
	if icold(0)   ne -1  then sfr1(icold)   = 0

	sfr1 = bytScl(sfr1, Min=0, Max=500, top=199)

	if imiss(0)   ne -1  then sfr1(imiss)   = ict_miss
	if iwater(0)  ne -1  then sfr1(iwater)  = ict_water
	if icold(0)   ne -1  then sfr1(icold)   = ict_cold
	if inosnow(0) ne -1  then sfr1(inosnow) = ict_nosnow
	

	;;;;;;;;;;;;;;;;;
	; plot
	;;;;;;;;;;;;;;;;;
	; pre scale sfr1
	;map_set,0,0,limit=[40,-180,90,-100], $
	;		/noborder, title=title, position=position
	map_set, 0, 0, limit=[reg_box[2],reg_box[0],reg_box[3],reg_box[1]], $
			/noborder, color=ict_black, title=title, position=position, $
			charsize=1.0
	
	new = MAP_IMAGE(sfr1, xstart, ystart, 						$
			lonmin=reg_box[0], lonmax=reg_box[1], 				$
			latmin=reg_box[2], latmax=reg_box[3], COMPRESS=1)

	xsize = (position(2) - position(0)) * !D.X_VSize
	ysize = (position(3) - position(1)) * !D.Y_VSize
	xstart = position(0) * !D.X_VSize
	ystart = position(1) * !D.Y_VSize

	TV, new, xstart, ystart, XSize=xsize, YSize=ysize

	map_continents, /cont, /countries, /usa, color=ict_black
	map_grid, lons=indgen(nsdiv[0]+1)*xdiv+reg_box[0], $
            lats=indgen(nsdiv[1]+1)*ydiv+reg_box[2], $
			color=ict_black

	plot, reg_box[0:1], reg_box[2:3], /noerase, /nodata, xstyle=1, ystyle=1, $
			xticks=nsdiv[0], yticks=nsdiv[1], position=position, charsize=1.0, $
			xrange=reg_box[0:1], yrange=reg_box[2:3], color=ict_black, $
			xtitle="Longitude", ytitle="Latitude"


	; colorbar
	pos_bar=findgen(4)
	pos_bar[0]=position[0]+0.05
	pos_bar[1]=position[1]-0.12
	pos_bar[2]=position[2]-0.12
	pos_bar[3]=pos_bar[1]+0.03
	colorbar, bottom=1, ncolor=200, min=0, max=5, division=10, $
    	    position=pos_bar, charsize=0.9, color=ict_black, $
			format='(f3.1)'
	xyouts, 5.2, -6.0, '(mm/hr)', color=ict_black
	xyouts, -0.18, -10.8, '0.00', color=ict_black
	xyouts,  0.32, -10.8, '0.02', color=ict_black
	xyouts,  0.82, -10.8, '0.04', color=ict_black
	xyouts,  1.32, -10.8, '0.06', color=ict_black
	xyouts,  1.82, -10.8, '0.08', color=ict_black
	xyouts,  2.32, -10.8, '0.10', color=ict_black
	xyouts,  2.82, -10.8, '0.12', color=ict_black
	xyouts,  3.32, -10.8, '0.14', color=ict_black
	xyouts,  3.82, -10.8, '0.16', color=ict_black
	xyouts,  4.32, -10.8, '0.18', color=ict_black
	xyouts,  4.82, -10.8, '0.20', color=ict_black
	xyouts,  5.20, -10.8, '(in/hr)', color=ict_black


	; save image
	png_file = odir + "/" + fn_pr + ".png"
	tvlct, r, g, b, /get
	write_png, fdn_cur+"/"+png_file, tvrd(), r, g, b
    print, "png_file: ", png_file
    print, ""
    print, ""


	; save to file
	;fid = h5f_create('output_02.h5')
	;ss = create_struct('sfr1', sfr1)
	;dt_id = h5t_idl_create(ss)
	;ds_id = h5s_create_simple(size(ss, /dimensions))
	;dd_id = h5d_create(fid, 'sfr1', dt_id, ds_id)
	;h5d_write, dd_id, ss
	;h5d_close, dd_id
	;h5s_close, ds_id
	;h5t_close, dt_id
	;h5f_close, fid

end

end




