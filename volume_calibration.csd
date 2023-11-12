<CsoundSynthesizer> 
<CsOptions> 
-odac
</CsOptions> 
; ============================================== 
<CsInstruments> 
 
sr      =       48000 
ksmps   =       64
nchnls =       2 
0dbfs   =       1 
 
#include"macro.orc"
instr 1  
 printf("VOLUME CALIBRATION --> Press spacebar to test next amplitude\n", 1)
printf("Amplitude ppp - linear = %f \n", 1, $ppp )
 kamp init 0
 iamps[] fillarray $ppp, $p, $mf, $f, $fff 
 ilen lenarray iamps
 kpick init 0
 kkey, kdown sensekey 
 printk2 kkey
 if(kkey == 32) then
    kpick = (kpick+1) % ilen

    if(kpick == 0) then 
        printf("Amplitude ppp - linear = %f \n", kdown, $ppp )
    elseif(kpick == 1) then 
        printf("Amplitude p - linear = %f \n", kdown, $p )
    elseif(kpick == 2) then 
        printf("Amplitude mf - linear = %f \n", kdown, $mf )
    elseif(kpick == 3) then 
        printf("Amplitude f - linear = %f \n", kdown, $f )
    elseif(kpick == 4) then 
        printf("Amplitude fff - linear = %f \n", kdown, $fff )
    endif
 endif

kamp = lineto:k(iamps[kpick], 0.1)
 ao = noise(kamp, 0.5)
 
 outs ao,ao
endin 
 
</CsInstruments> 
; ============================================== 
<CsScore> 
f 0 z 
 i 1 0 -1
 
 
</CsScore> 
</CsoundSynthesizer> 

