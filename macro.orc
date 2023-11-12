/*
    This file contains utility macros
*/

;       DYNAMICs

giamp_fff =  ampdbfs(-3)
giamp_ff = ampdbfs(-5)
giamp_f = ampdbfs(-9)
giamp_mf = ampdbfs(-13)
giamp_mp = ampdbfs(-17)
giamp_p = ampdbfs(-23)
giamp_pp = ampdbfs(-29)
giamp_ppp = ampdbfs(-39)
 
#define fff     #giamp_fff# 
#define ff      #giamp_ff# 
#define f       #giamp_f# 
#define mf      #giamp_mf# 
#define mp      #giamp_mp# 
#define p       #giamp_p# 
#define pp      #giamp_pp# 
#define ppp     #giamp_ppp# 

giAmps ftgen 0, 0, 8, -2, $ppp, $pp, $p, $mp, $mf, $f, $ff, $fff

#define ampvar          #(iamp+random:i(-$ppp, $ppp))#

;       HELPFULs

#define k               #*1000#
#define c               #*100#
#define d               #*10#

#define ms              #/1000#
#define s               #*1000#

#define if              #if (#
#define then            # == 1) then#

