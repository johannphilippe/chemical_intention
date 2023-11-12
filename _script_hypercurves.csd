This file is used to translate hypercurves used in this project into raw Csound tables for web target (see hypercurves_raw.orc).

<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
; ==============================================
<CsInstruments>

sr	=	48000
ksmps	=	64
nchnls	=	4
0dbfs	=	1


#include "hypercurves.orc"

gSfilename = "hypercurves_raw.orc"
opcode translate, 0, Si
    Sname, itab xin 
    ilen = ftlen(itab)
    fprints(gSfilename, "%s = ftgen(0, 0, %d, 2", Sname, ilen)
    icnt init 0
    while icnt < ilen do 
        ival = table(icnt, itab)
        fprints(gSfilename, ", %f", ival)
        icnt += 1
    od
    fprints(gSfilename, ")\n\n")
endop

instr 1
    translate("giascend_bip", giascend_bip)
    translate("gidescend", gidescend)
    translate("gifastatq", gifastatq)
    translate("gihcslow", gihcslow)
    translate("gistcrv", gistcrv)
    translate("gisoft", gisoft)
    translate("gihc_traj_cubic_concav", gihc_traj_cubic_concav)
    translate("gihc_traj_linear", gihc_traj_linear)
    translate("gihc_blackman", gihc_blackman)
    translate("gihc_hamming", gihc_hamming)
    translate("gihc_hanning", gihc_hanning)
    translate("gihc_cubic_bezier", gihc_cubic_bezier)
    translate("gidiocles", gidiocles)
    translate("gitight", gitight)
    translate("gifade", gifade)
    translate("gitriangle", gitriangle)
endin

</CsInstruments>
; ==============================================
<CsScore>

i 1 0 0.1

</CsScore>
</CsoundSynthesizer>
