pro mid_line, lon0, lat0, lon1, lat1, a, loni, lati
; calculate mid point
; Jun Dong, 08/01/2015


; input
tt=size(a)
nfov=tt(1)
;print, nfov


; loop
for i=0, nfov-2 do begin

	; unwrap 4 points
	lon00=lon0(i)
	lon01=lon0(i+1)
	lon10=lon1(i)
	lon11=lon1(i+1)
	tt=lon01-lon00
	if (tt lt -180) then begin
		lon01=lon01+360
	endif else begin if (tt gt 180) then begin
		lon01=lon01-360
	endif
	endelse
	tt=lon10-lon00
	if (tt lt -180) then begin
		lon10=lon10+360
	endif else begin if (tt gt 180) then begin
		lon10=lon10-360
	endif
	endelse
	tt=lon11-lon00
	if (tt lt -180) then begin
		lon11=lon11+360
	endif else begin if (tt gt 180) then begin
		lon11=lon11-360
	endif
	endelse
	;print, lon00, lon01, lon10, lon11

	; inner points
	tt=a(i)+a(i+1)
	loni(i+1)=(a(i+1)*(lon00+lon10)/2+a(i)*(lon01+lon11)/2)/tt
	lati(i+1)=(a(i+1)*(lat0(i)+lat1(i))/2  $
		+a(i)*(lat0(i+1)+lat1(i+1))/2)/tt

	; first
	if (i eq 0) then begin
		loni(0)=lon0(0)+lon1(0)-loni(1)
		lati(0)=lat0(0)+lat1(0)-lati(1)
	endif

	; last
	if (i eq nfov-2) then begin
		loni(nfov)=lon0(nfov-1)+lon1(nfov-1)-loni(nfov-1)
		lati(nfov)=lat0(nfov-1)+lat1(nfov-1)-lati(nfov-1)
	endif
endfor

; wrap
loni=(loni+180 mod 360)-180


end




