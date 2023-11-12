Main entry point for Chemical Intention. 

<CsoundSynthesizer>
<CsOptions>
-odac 
</CsOptions>
; ==============================================
<CsInstruments>

#include "config.orc"

#ifdef BINAURAL
    #define NCHNLS #6# ; Binaural mode is defined for 6 virtual sources equally placed around the listener
#else
    #define NCHNLS #nchnls# 
#end

#ifdef ENABLE_PLUGINS
    ierr = lua_dofile("script/markov.lua")
    print ierr
#end

gaOut[] init $NCHNLS
gaSub init 0

; Mix to output
opcode set_out, 0, ia
    ich, asig xin
    if ich > $NCHNLS then
        ich = $NCHNLS
    elseif ich <= 0 then
        ich = 1
    endif

    gaOut[ich - 1] = gaOut[ich - 1] + asig 
endop
opcode set_out, 0, ka
    kch, asig xin
    if kch > $NCHNLS then
        kch = $NCHNLS
    elseif kch <= 0 then
        kch = 1
    endif

    gaOut[kch - 1] = gaOut[kch - 1] + asig 
endop
opcode set_outs, 0, i[]a
    ich[], asig xin
    kcnt = 0
    ilen lenarray ich
    while kcnt < ilen do
        kch = ich[kcnt]
        if(kch > $NCHNLS) then
            kch = $NCHNLS 
        elseif kch <= 0 then
            kch = 1
        endif
        gaOut[kch - 1] = gaOut[kch - 1] + asig
        kcnt += 1
    od
endop

#include "macro.orc"
#include "gens.orc"
#include "udo.orc"
#include "scales.orc"
#ifdef ENABLE_PLUGINS
    #include "hypercurves.orc"
#else 
    #include "hypercurves_raw.orc"
#end
#include "markov.orc"
#include "traj.orc"
#include "disturbance.orc"

giGain = 1

opcode binaural_out, 0, a[]k[]k[]ii
    asigs[], kaz[], kelev[],ilen, icnt xin
    if(icnt == ilen) goto nothing
    asig = limit(asigs[icnt] * giGain, -0.99, 0.99)
    #ifdef WEB
    all, arr hrtfmove2 asig, kaz[icnt], kelev[icnt], "samples/hrtf-44100-left.dat", "samples/hrtf-44100-right.dat", 4, 9, 44100
    #else 
    all, arr hrtfmove2 asig, kaz[icnt], kelev[icnt], "samples/hrtf-48000-left.dat", "samples/hrtf-48000-right.dat", 4, 9, 44100
    #endif
    outs all, arr
    binaural_out(asigs, kaz, kelev, ilen, icnt + 1)
    nothing:
endop

instr master
    ilen init $NCHNLS
    kcnt init 0
    kcnt = 0
    #ifdef BINAURAL
        al = 0
        ar = 0
        kElev[] init 6
        kElev[0] = oscili(15, 0.01, gisine, 1/6)
        kElev[1] = oscili(15, 0.011, gisine, 2/6)
        kElev[2] = oscili(15, 0.012, gisine, 3/6)
        kElev[3] = oscili(15, 0.013, gisine, 4/6)
        kElev[4] = oscili(15, 0.014, gisine, 5/6)
        kElev[5] = oscili(15, 0.015, gisine, 0)
        kAz[] = fillarray(15, 30, -90, 90, -135, 135 )

        kAz[0] = kElev[1]
        kAz[1] = 70 + kElev[0]
        kAz[2] = 290 + kElev[3]
        kAz[3] = 140 + kElev[2]
        kAz[4] = 220 + kElev[5]
        kAz[5] = 180 + kElev[4]
        binaural_out(gaOut, kAz, kElev, $NCHNLS, 0)
    #else
    #ifdef PERF
    #end
        out gaOut
    #end

    gaSub = 0
    while kcnt < ilen do
        gaOut[kcnt] = 0
        kcnt += 1
    od
endin

#include "audio_instr.orc"
#include "schedulers.orc"

instr stop_schedulers
    schedule("part2_stop_sched", 0, 1)
endin

opcode get_active, k, 0
    kact = active:k("part2", 1)
    xout kact
endop

instr scheduler
    seed 0
    kdur init 0
    inseqs = 4

    kdiv init 3
    kpulses init 9
    kphfq init 0.002
    kph = phasor:k(kphfq)
    keuc = euclidian(1, kdiv, kpulses, 0, kph)
    keuc = rolling_russian_roll(5, keuc, keuc)

    ifirst = rint:i(1, inseqs)
    kmark = markov(7, ifirst, keuc)

    kstart init 1
    kactive = get_active()

    kkey, kdown sensekey

    if( (kdur / 60) > 5 ) then 
        keuc = 1
        kmark = rint:k(1, 4)
    endif

    printf("main scheduler %d \n", keuc, kmark)
    if(kkey == 38) then 
        keuc = 1
        kmark = 1
    elseif(kkey == 195) then 
        keuc = 1
        kmark = 2
    elseif(kkey == 34) then
        keuc = 1
        kmark = 3
    elseif(kkey == 39 ) then
        keuc = 1
        kmark = 4
    endif
    
    if(keuc == 1 || kstart == 1) then
        kdur = 0
        schedulek("stop_schedulers", 0, 1)
        kphfq = random:k(0.001, 0.008)
        kwhen = 1.5
        schedulek("part2", kwhen, -1) 
    endif
    kstart = 0
    kdur += (ksmps / sr)
endin

</CsInstruments>
; ==============================================
<CsScore>
f 0 z

i "master" 0 -1
i "scheduler" 0 -1
</CsScore>
</CsoundSynthesizer>




