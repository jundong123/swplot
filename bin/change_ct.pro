pro change_ct,r,g,b
; new ct
; Jun Dong, 12/16/2014


; total color
N0=250

; main color
mc=[[159, 255, 255], $
    [ 31,  95, 159], $
    [  0, 223,  63], $
    [255, 255,   0], $
    [255,   0,   0], $
    [ 95,   0,   0]]

mc_ind=[0,25,50,100,150,N0-1]

; generate
ct = indgen(N0,3)
ind = indgen(N0)
for i=0,2 do begin
    ct(*,i) = interpol(mc(i,*), mc_ind, ind)
endfor


; change to 200
N1 = 200
r1 = congrid(ct(*,0), N1)
g1 = congrid(ct(*,1), N1)
b1 = congrid(ct(*,2), N1)


; background color
NCT = 256
bkgrd = [255, 255, 255]
r = [bkgrd(0), r1]
g = [bkgrd(1), g1]
b = [bkgrd(2), b1]


; extra colors
N2=5
black = [  0,   0,   0]
white = [255, 255, 255]
nosfr = [255, 230, 219]
water = [239, 239, 239]
cold  = [207, 207, 207]
r = [r, indgen(NCT-N1-N2-1)*0+255]
g = [g, indgen(NCT-N1-N2-1)*0+255]
b = [b, indgen(NCT-N1-N2-1)*0+255]
;r = [r, cold(0), water(0), nosfr(0), white(0), black(0)]
;g = [g, cold(1), water(1), nosfr(1), white(1), black(1)]
;b = [b, cold(2), water(2), nosfr(2), white(2), black(2)]

r = [r, cold(0), water(0), nosfr(0), black(0), white(0)]
g = [g, cold(1), water(1), nosfr(1), black(1), white(1)]
b = [b, cold(2), water(2), nosfr(2), black(2), white(2)]


; apply
tvlct, r, g, b



end


