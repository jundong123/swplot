pro fov_rect_1f, lon, lat, a, loni, lati
; Find 4 points of each fov
; Jun Dong, 08/10/2015


;input
;print, lon, lat, sfr, a
sz = size(lon, /dim)
nsl=sz(0)
nfov = sz(1)
;print, nsl, nfov


;inner
loni1=make_array(1,nfov+1,/float,value=0);
lati1=make_array(1,nfov+1,/float,value=0);

for j=0,nsl-2 do begin
    mid_line, lon(j,*), lat(j,*), lon(j+1,*), lat(j+1,*), a, $
			loni1, lati1
	loni(j+1,*)=loni1
	lati(j+1,*)=lati1
endfor


; first
; expand (unwrap, expand and wrap), then mid_line
; unwrap
lon0=lon(0,*)
lon1=lon(1,*)
ind=where((lon0-lon0(0,0)) lt -180)
lon0(ind)=lon0(ind)+360
ind=where((lon0-lon0(0,0)) gt 180)
lon0(ind)=lon0(ind)-360
ind=where((lon1-lon0(0,0)) lt -180)
lon1(ind)=lon1(ind)+360
ind=where((lon1-lon0(0,0)) gt 180)
lon1(ind)=lon1(ind)-360
; expand
lon0=2*lon0-lon1
tlat=2*lat(0,*)-lat(1,*)
; wrap
lon0=((lon0+180) mod 360)-180
; mid_line
mid_line, lon0, tlat, lon(0,*),lat(0,*), a, loni1, lati1
loni(0,*)=loni1
lati(0,*)=lati1


; last
; expand (unwrap, expand and wrap), then mid_line
; unwrap
lon0=lon(nsl-1,*)
lon1=lon(nsl-2,*)
ind=where((lon0-lon0(0,0)) lt -180)
lon0(ind)=lon0(ind)+360
ind=where((lon0-lon0(0,0)) gt 180)
lon0(ind)=lon0(ind)-360
ind=where((lon1-lon0(0,0)) lt -180)
lon1(ind)=lon1(ind)+360
ind=where((lon1-lon0(0,0)) gt 180)
lon1(ind)=lon1(ind)-360
; expand
lon1=2*lon1-lon0
tlat=2*lat(nsl-1,*)-lat(nsl-2,*)
; wrap
lon1=((lon1+180) mod 360)-180
; mid_line
mid_line, lon(nsl-1,*), lat(nsl-1,*), lon1, tlat, a, loni1, lati1
loni(nsl,*)=loni1
lati(nsl,*)=lati1

loni=((loni+180) mod 360)-180


end




