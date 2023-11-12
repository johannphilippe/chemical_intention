/*
    Audio instruments 
*/

instr clics	
	kb1 line 0.999, p3, -0.999
	kb2 line -0.999, p3, 0.999
	a1 noise 5000, kb1
	a2 noise 5000, kb2
	a3 clip a1, 0, 1
	a4 clip a2, 0, 1
	a5 butterhp a3, p5
	a6 butterhp a3, p5
    a5 = butlp(a5, 12000)
    a6 = butlp(a6, 12000)
	kamp = linseg:k(1, p3*0.05, 0.1, p3*0.95, 0)
	ipan random 0, 1000
	
    ispeaker = rint:i(1, $NCHNLS)
    asig = (a5 + a6) * 0.5 * kamp * p4 
    set_out(ispeaker, asig)
endin
  

instr crunchyvoice
    ipick = rint:i(0, lenarray(gistiegler_files)-1)
    print ipick
    isample = gistiegler_files[ipick]
    kcrossfade = 0.05
    iend = ftlen(isample) / ftchnls(isample) / sr
    istart = random:i(0, iend / 3 * 2)
    kloopstart = istart
    kloopend = iend
    al, ar flooper2 1, 1, kloopstart, kloopend, kcrossfade, isample, istart
    asig = (al+ar) * .5
    kch init 0
    iclickspeed init p6
    imaxdur = random:i(6, 10)
    ispeed = rint:i(1, 8) / 16 * iclickspeed
    kmet = drunk(ispeed, 0.5)
    ksub init 2
    kchoice init 1
    kstutter init  0
    kstutterspeed init 1
    if(kmet == 1) then
        ksub =  rint:k(1, 8) 
        kchoice = 1
        kstutter = 0
        kstutterspeed = rint:k(1, 4)
    endif
    acut, kch jcut asig, gihc_hanning, imaxdur,  ksub, kchoice, kstutter, kstutterspeed
    igain init p4
    kgain = rspline:k(igain / 2, igain , 0.5, 2)
    kamp init p5
    afold = mirror:a(acut * kgain, -1, 1) * kamp * 0.4
    ahp = buthp(afold, random:i(1000, 3000)) 

    ispeaker = rint:i(1, $NCHNLS)
    kspeaker init ispeaker
    kchange_sp = percent(0.33)
    if(kmet == 1 && kchange_sp == 1) then 
        kspeaker = rint:k(1, $NCHNLS)
    endif
    set_out(kspeaker, ahp)
endin

gipart2_gain = 3
giAltScales[] fillarray gibyzantine, gichinese, giegyptian, giethiopian

girnd = rint:i(0, lenarray(giAltScales)-1)
gkp2_scale init giAltScales[girnd]

; vco emulation with gliding svn non linear filter
instr part2_vcglide

    kfq = rspline:k(p4, p5, 0.05, 3)
    kampmod = rspline:k(0, 1, 0.05, 3)
    iamp init p6
    ienv init p7
    kcrv = tablei:k(linseg:k(0,p3,1), ienv, 1)
    ao = vco2(kampmod, kfq)
    
    kq = rspline(0.5, 1.5, 0.05, 3)
    kdrive = kcrv * 0.99
    ahp,alp,abp,abr svn ao, kfq, kq, kdrive
    ahp2,alp2,abp2,abr2 svn ao, kfq*1.5, kq, kdrive

    kpan = lineto(kcrv, 0.03)
    iprnd = rint:i(1,3)
    kpan2 = 1 - kpan
    if(iprnd == 1) then 
        kpan = 1-kpan
    elseif(iprnd == 2) then 
        kpan2 = 1 - kpan2
    endif

    hpan( abp * iamp * kcrv, kpan, kpan2 )
    hpan( abp2 * iamp * kcrv, mirror:k(kpan + random:i(0.5, 1), 0, 1), mirror:k(kpan2+random:i(0.5, 1), 0, 1) )
endin

gihypermod_curves[] fillarray gitight, gihcslow, gifastatq, gisoft, gidiocles, gihc_cubic_bezier
gimars_crvs[] fillarray gihcslow, gihc_traj_cubic_concav, gistcrv, gidiocles, gifastatq, gitight, gihc_blackman

; vco set with several filtering svn mode (non linear distortion vcf) > hipass, lopass, bandpass
instr part2_marsattack
        icrv = gihc_cubic_bezier
        kcrv = tablei:k(linseg:k(0, p3, 1), icrv, 1)
        ao = vco2(0.5, p4) + vco2(0.2, p5) + vco2(0.1, p6 * 0.8)
        kmod =  p8 - abs(  oscili(0.3, kcrv * p7 + 0.1, gihcslow) * p8)
        
        ao *= kcrv
        acmp = ao
        ao *= kmod
        kffq = p4
        icrvmov = gimars_crvs[rint:i(0, lenarray(gimars_crvs) - 1)]
        kmovfq = lineto(tablei:k(linseg(0,p3, 1), icrvmov, 1) * (max:k(p4, p5, p6) * 4) + 80, 0.01)
        ires = (p11 == 1) ? 7 : 7
        idist = (p11 == 1) ? 0.25 : 0.125
        kffq = (p11 == 1) ? kmovfq : kffq

        ahp,alp,abp,abr svn ao, kffq, ires, idist
        adel = linseg:a(0, p3/2, random:i(0.01, 0.08), p3/2, 0)
        kfb = 0.7
        
        il = (p9 == 1) ? 1 : 0
        ib = (p9 == 2) ? 1 : 0
        ih = (p9 == 3) ? 1 : 0
        ao = (ahp * ih * 0.5) + (alp * il) + (abp * ib)
        if(ib == 1) then 
            ao *= 0.3
        endif
        
        kmodamp = random:i(0.25, 0.75)
        kmodfq = random:i(0.5, 8)
        kmodduty = rspline:k(0, 1, 0.5, 4)
        kmod = hypermod(kmodamp , kmodfq, gihypermod_curves)

        iamp init p10
        ao = dcblock2(ao)
        ao = balance(ao, acmp)
        if(p12 > 0) then 
            ao = (ao * kmod) + (ao * (1 - kmodamp))
        endif
        ao *= iamp * gipart2_gain
        
        kpan =  lineto(kcrv, 0.03)

        inspeaker = rint:i(2, $NCHNLS)
        ispeakers[] = random_array_int(inspeaker, 1, $NCHNLS)

        iprnd = rint:i(1,3)
        kpan2 = 1 - kpan
        ioffset1 = random:i(0, 0.75)
        ioffset2 = random:i(0, 0.75)
        if(iprnd == 1) then 
            kpan = 1-kpan
        elseif(iprnd == 2) then 
            kpan2 = 1 - kpan2
        endif

        hpan(ao, mirror:k(kpan+ioffset1,0, 1) , mirror:k(kpan2+ioffset2, 0, 1))
endin   

; The sound used in soft chord generations
instr part2_chords
    ifq init p4
    kfq = ifq + rspline:k(-(ifq/1000), ifq/1000, 0.01, 0.3)
    ao = vco2(0.3, kfq) *  (expseg(1.01, p3, 0.01) - 0.01)
    ihigh = percent:i(0.1)
    ahp,alp,abp,abr svn ao, kfq, 10, 0.5
    if(ihigh == 1) then 
        abp = ahp
    endif
    imodamp = random:i(0, 0.7)
    kmod = funkymod( imodamp, random:i(1, 6), rspline:k(0, 1, 0.1, 2) )
    ispeaker init p5
    iamp init p6

    abp = (abp * kmod) + (abp * (1-imodamp))
    abp *= iamp * gipart2_gain
    set_out(ispeaker, abp)
endin

; The second sound used in buzzy chord generations
instr part2_buzzychords
    iwavet[] fillarray 0, 2, 4, 12 
    iwavep = rint:i(0, lenarray(iwavet)-1)
    iwave = iwavet[iwavep]
    kpw = rspline(0, 1, 0.25, 4)

    ifq init p4
    kfq = ifq + rspline:k(-(ifq/1000), ifq/1000, 0.01, 0.3)

    ao = vco2(0.3, kfq, iwave, kpw ) *  (expseg(1.01, p3, 0.01) - 0.01)
    
    ahp,alp,abp,abr svn ao, kfq, 10, 0.5
    ispeaker init p5
    iamp init p6

    ipick = rint:i(1, 4)
    ihp = (ipick == 1) ? 1 : 0
    ilp = (ipick == 2) ? 1 : 0
    ibp = (ipick == 3) ? 1 : 0
    ibr = (ipick == 4) ? 1 : 0
    ares = (ahp * ihp) + (alp * ilp) + (abp * ibp) + (abr * ibr)

    imodfq = random:i(0.5, 4)
    imodamp = random:i(0.2, 1)
    kduty = rspline:k(0, 1, 0.2, 4)
    kmod = funkymod(imodamp, imodfq, kduty)
    ares = (ares * kmod) + (ares * (1 - imodamp))
    ares *= iamp * gipart2_gain
    set_out(ispeaker, ares)
endin

; Wind emulation
opcode storm_wind_impl, aa, k
    kenv xin
	kGain = 1 
	aNoise pinker
	kPan1 jitter .5, .1, 1 
	kPan1 = kPan1+.5
	kPan2 jitter .5, .1, 1 
	kPan2 = kPan2+.5
	kPan3 jitter .5, .1, 1
	kPan3 = kPan3+.5 
	kPan4 jitter .5, .1, 1
	kPan4 = kPan4+.5 
	kb1 = 1.25
	kb2 = 1.5
	kb3 = 1.75
	kb4 = 2
	ka1 = .8
	ka2 = .6
	ka3 = .5
	ka4 = .3
	aLow butterlp aNoise, 100+randi:k(50, kb1, 1)
	aMid1 butterbp aNoise, 200+randi:k(100, kb2, 1), 100
	aMid2 butterbp aNoise, 800+randi:k(300, kb3, 1), 400
	aHigh butterbp aNoise, 2000+randi:k(500, kb4, 1), 500 
	
	aLowL, aLowR pan2 aLow*ka1, random(0, 1) 
	aMid1L, aMid1R pan2 aMid1*ka2, random(0, 1) 
	aMid2L, aMid2R pan2 aMid2*ka3, random(0, 1) 
	aHighL, aHighR pan2 aHigh*ka4, random(0, 1) 

	aLeft = (aLowL+aMid1L+aMid2L+aHighL) * kenv
	aRight = (aLowR+aMid1R+aMid2R+aHighR) * kenv
	xout aLeft*kGain, aRight*kGain
endop

; A synthesizer based on variable waveform vco, and chebyshev filter/distortion
instr part2_hypervco
    icrv init p4
    iamp init p5
    ifqoffset = p6
    ifqmult = p7
    icrvspeed = p8
    kcrv = tablei:k(linseg:k(0, p3, 1), icrv, 1)
    kmod = tablei:k(phasor:k(icrvspeed), icrv, 1)

    kpw = limit:k(oscili:k(0.5, rspline:k(1, 4, 1 ,4)) + 0.5, 0.01, 0.99)

    ifq = ifqoffset
    kfq = ifq
    iwavet[] fillarray 0, 2, 4, 12 
    iwavep = rint:i(0, lenarray(iwavet)-1)
    iwave = iwavet[iwavep]
    asig = vco2(1, kfq, iwave, kpw)  + 
            vco2(1, kfq * 1.05, iwave, kpw ) +
            vco2(1, kfq * 2, iwave, kpw ) +
            vco2(1, kfq * 4, iwave, kpw )
	
    k1 = linseg:k(1.0, p3, 0.0)
    k2 = linseg:k(-0.5, p3, 0.0)
    k3 = linseg:k(-0.333, p3, -1.0)
    k4 = linseg:k(0.0, p3, 0.5)
    k5 = linseg:k(0.0, p3, 0.7)
    k6 = linseg:k(0.0, p3, -1.0)
    // Distortion calculated from chebyshev polynomial
    ares = chebyshevpoly(asig, 0, k1, k2, k3, k4, k5, k6)
    ares = balance(ares, asig)

    ares *= (0.25 * iamp) * kcrv
    ares = buthp(ares, 40) 

    ich = rint:i(1, $NCHNLS)
    set_out(ich, ares)
endin

; Noise based synthesizer
instr part2_noise
    icrv init p4
    iamp init p5
    ifqoffset = p6
    ifqmult = p7
    icrvspeed = p8
    kcrv = tablei:k(linseg:k(0, p3, 1), icrv, 1)
    kmod = tablei:k(phasor:k(icrvspeed), icrv, 1)

    kres = kcrv * 0.99
    kcf = kcrv * ifqmult + ifqoffset
    ao = noise(0.1, 0.5)  
    ao *= kcrv
    afilt = vclpf(ao, kcf, kres)

    kphfreq = kcf + oscili(50, 0.1)
    kphq = 0.75
    kord = 30
    kmode = 2
    ksep = 1
    kfb = 0.9
    asig = afilt

    ab1, ab2 storm_wind_impl kcrv

    inspeaker = int(random:i(1, $NCHNLS))
    ispeakers[] = random_array_int(inspeaker, 1, $NCHNLS)

    kbcrv = rspline(0, 1, 0.1, 0.5)
    traj(ab1, ispeakers, icrv, kbcrv)
    traj(ab2, ispeakers, icrv, 1 - kbcrv)
endin
