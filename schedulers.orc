/*
    This file contains control schedulers for this installation. The main / parent scheduler is "part2". 
    This can be considered as the musical center of this work.
*/ 


; Control synthesizer
gipick_tab[] fillarray gifastatq, gihcslow, gistcrv, gidiocles, gitight
instr part2_wtf
    ifq init p4
    iamp init p5
    ienvtable init p6

    iwavet[] fillarray 0, 2, 4, 12 
    iwavep = rint:i(0, lenarray(iwavet)-1)
    iwave = iwavet[iwavep]

    kpw = rspline(0.01, 0.99, 0.25, 4)
    ao = vco2(0.5, ifq, iwave, kpw) + vco2(0.25, ifq*0.98, iwave, kpw)

    alin = linseg:a(0, p3, 1)
    klin = linseg:k(0, p3, 1)
    aenv = table3:a(alin, ienvtable, 1)
    kenv = table3:k(klin, ienvtable, 1)
    
    icutmult = random:i(1, 4)
    kcutoff = ( ifq * icutmult ) + 20
    kQ = random:i(0.5, 7)
    kdrive = random:i(0.125, 0.8)
    ;ifn = gifastatq
    ahp, alp, abp, abr svn ao, kcutoff, kQ, kdrive, giascend_bip
    
    ipick = rint:i(1, 4)
    ihp = (ipick == 1) ? 1 : 0
    ilp = (ipick == 2) ? 1 : 0
    ibp = (ipick == 3) ? 1 : 0
    ibr = (ipick == 4) ? 1 : 0

    ares = (ahp * ihp) + (alp * ilp) + (abp * ibp) + (abr * ibr)
    ares =  buthp(ares, ifq) 

    ares *= iamp * random:i(0.5, 1) * kenv
    
    ispeaker1 = rint:i(1, $NCHNLS)
    ispeaker2 = ispeaker1
    while ispeaker2 == ispeaker1  do
        ispeaker2 = rint:i(1, $NCHNLS)
    od
    ipantable = anyof(gipick_tab)
    kpan = tablei:k(klin, ipantable, 1)
    al, ar pan2 ares, kpan
    set_out(ispeaker1, al)
    set_out(ispeaker2, ar)
endin

instr part2_noisyphrases
    kmetfq init p4
    iamp init p5
    idurmult init p6
    ibase init p7
    kamp = random:k(iamp/2, iamp)
    kdurmult = rspline:k(idurmult/2, idurmult, 1, 5)
    kmet = drunk(kmetfq * rspline:k(0.5, 2, 1, 4), 0.9)
    kdur = 1 / kmetfq  * kdurmult

    iscale = i(gkp2_scale)
    imin = rint:i(10, ibase)
    imax = rint:i(ibase+1, 90)
    kprms[] fillarray 1, 3, 5
    kfreq = scale_itv(iscale, 3, ibase, kprms, kmet, imin, imax, 1)

    if(kmet == 1) then 
        ktable_pick = rint:k(0, lenarray(gipick_tab) -1)
        ktab = gipick_tab[ktable_pick]
        schedulek("part2_wtf", 0, kdur, kfreq, kamp, ktab )
    endif
endin

; Dense and intense subscheduler
instr 203
    kph = phasor:k(p6, p7)
    keuc = euclidian:k(2, p4, p5, 0, kph)
    keuc2 = euclidian:k(2, p4, p5 , 0, phasor:k(p6 * 2.25, p7 ))
    ibase init p8

    kprms2[] fillarray 2, 4, 7
    kprms[] fillarray 1,3,5
    kfqs[] init 3

    irnd rint 1,3
    kmark = markov(204, irnd, keuc2)
    iscale = i(gkp2_scale) 
    kstart init 1

    kreversmark = markov(205, 1, keuc)
    kbeatmark = markov(205, 1, keuc)
    icrvs[] fillarray gifastatq, gihcslow, gidescend, gihc_cubic_bezier
    incrvs[] fillarray gihcslow, gidescend, gisoft

    kfqs[] init 3
    kcnt = 0
    
    imaxwave = rint:i(2, 3)

    ihypervco_sel = percent:i(0.33)
    if(keuc == 1 || kstart == 1) then
        if(kmark == 1) then
            kdur = random:k(9, 15)
            kamp = random:k(0.2, 0.8)
            kfqoffset = random:k(100, 250)
            kfqmult = random:k(300, 1000)
            kcrvspeed = random:k(0.1, 3)
            kcrv = incrvs[rint:k(0, lenarray(incrvs)-1)]
            khyperfq = scale_itv(iscale, 3, ibase, kprms, keuc, 20, 50, 1)
            if(ihypervco_sel == 1) then 
                schedulek("part2_hypervco", 0, kdur, kcrv, kamp, khyperfq, 1, kcrvspeed)
            else 
                schedulek("part2_noise", 0, kdur, kcrv, kamp, kfqoffset, kfqmult, kcrvspeed)
            endif
        elseif(kmark == 2) then 
            kcnt = 0
            kdur = random:k(10, 20)
            kamp = random:k(0.1, 0.2)
            kmod = 0;rint:k(0,1)
            if(kmod == 1) then
                kamp *= 0.01
            endif
            multiple_fqs:
                kfqs[kcnt] = scale_itv(iscale, 3, ibase, kprms, keuc, 20, 90, 1)
            loop_lt(kcnt, 1, 3, multiple_fqs)
            schedulek("part2_marsattack", 0, kdur, kfqs[0], kfqs[1], kfqs[2], random:k(1, 5), 1, rint:k(1, imaxwave), kamp, kmod , 0)
            if (kbeatmark == 2) then 
                kwhen = random:k(0, 8)
                schedulek("part2_marsattack",kwhen , kdur, kfqs[0] * 1.001, kfqs[1] * 0.99, kfqs[2] * 1.01, random:k(0.1, 0.5), 0.5, rint:k(1,imaxwave), kamp, 0, 0 )
            endif
            if(kreversmark == 2) then
                kwhen = random:k(0, 8)
                krev = rint:k(0, 2)
                kmult = 1
                if(krev == 0) then
                    kmult = 0.5
                elseif(krev >= 1) then
                    kmult = 2
                endif
                schedulek("part2_marsattack", kwhen, kdur, kfqs[0] * kmult, kfqs[1] * kmult, kfqs[2] * kmult, random:k(0.1, 0.5), 0.5, rint:k(1,3), kamp, 0 , 0)
            endif
        elseif(kmark == 3) then 
            kcnt = 0
            kdur = random:k(10, 20)
            kamp = random:k(0.1, 0.2)
            multiple_fqs:
                kfqs[kcnt] = scale_itv(iscale, 3, ibase * 2, kprms, keuc, 20, 80, 1)
            loop_lt(kcnt, 1, 3, multiple_fqs)
            kmod = rint:k(0,1)
            if(kmod == 1) then
                kamp *= 0.1
            endif
            schedulek("part2_marsattack", 0, kdur, kfqs[0], kfqs[1], kfqs[2], random:k(1, 5), 1, rint:k(1,3), kamp, kmod, 0)

            if (kbeatmark == 2) then 
                kwhen = random:k(0, 8)
                schedulek("part2_marsattack",kwhen , kdur, kfqs[0] * 1.001, kfqs[1] * 0.99, kfqs[2] * 1.01, random:k(1, 5), 1, rint:k(1,3), kamp, kmod, 0 )

            endif
            if(kreversmark == 2) then
                kwhen = random:k(0, 8)
                krev = rint:k(0, 2)
                kmult = 1
                if(krev == 0) then
                    kmult = 0.5
                elseif(krev >= 1) then
                    kmult = 2
                endif
                schedulek("part2_marsattack",kwhen , kdur, kfqs[0] * kmult, kfqs[1] * kmult, kfqs[2] * kmult, random:k(1, 5), 1, rint:k(1,3), kamp, kmod , 0)
            endif
        endif

    endif

    ispecial_fastevents = rint:i(1, 3)
    kspecial_mark = markov(205, 1, keuc2)
    if(kspecial_mark == 2 && keuc2 == 1 && ispecial_fastevents == 1) then 
        kdur = random:k(2, 12)
        kmetfq = rint:i(0.5, 4)
        kamp = random:k(0.05, 1)
        kdurmult = random:k(4, 8)
        schedulek("part2_noisyphrases", 0, kdur, kmetfq, kamp, kdurmult, ibase)
    endif

    kstart = 0

endin
maxalloc(203, 2)

; Smooth and slow subscheduler
instr part2_drone
    kph = phasor:k(p6, p7)
    keuc = euclidian(1, p4, p5, 0, kph)
    keuc2 = euclidian(1, p4, p5 , 0, phasor:k(0.35))

    // base note of the drone
    ibase = p8

    iprms_size = rint:i(2, 6)
    kprms[] init iprms_size
    icnt = 0
    while icnt < iprms_size do 
      kprms[icnt] = rint:i(1, 8)
      icnt += 1
    od
    kfqs[] init 3

    kmark = markov(201, 1, keuc2)

    iscale = i(gkp2_scale) ;gibebopdominant

    kreversmark = markov(205, 1, keuc)
    kbeatmark = markov(205, 1, keuc)

    kstart init 1
    if(keuc == 1 || kstart == 1) then
        kcnt = 0
        kdur = random:k(20, 40)
        kamp = random:k(0.01, 0.1)
        multiple_fqs:
            kfqs[kcnt] = scale_itv(iscale, 3, ibase, kprms, keuc, 30, 70, 1)
        loop_lt(kcnt, 1, 3, multiple_fqs)
        schedulek("part2_marsattack", 0, kdur, kfqs[0], kfqs[1], kfqs[2], random:k(0.1, 0.5), 0.5, 2, kamp, 0, 0 )
        if (kbeatmark == 2) then 
            kwhen = random:k(0, 8)
            schedulek("part2_marsattack",kwhen , kdur, kfqs[0] * 1.001, kfqs[1] * 0.99, kfqs[2] * 1.01, random:k(0.1, 0.5), 0.5, 2, kamp, 0 , 0)
        endif
        if(kreversmark == 2) then
            kwhen = random:k(0, 8)
            krev = rint:k(0, 2)
            kmult = 1
            if(krev == 0) then
                kmult = 0.5
            elseif(krev >= 1) then
                kmult = 2
            endif
            schedulek("part2_marsattack", kwhen, kdur, kfqs[0] * kmult, kfqs[1] * kmult, kfqs[2] * kmult, random:k(0.1, 0.5), 0.5, 2, kamp, 0 , 0 )
        endif
    endif
    kstart = 0
    kprms2[] fillarray 1, 2
    ifuzzy = rint:i(1, 4)
    if(keuc2 == 1 && kmark == 2) then
        klpcnt = 0
        klpmax = rint:k(3,7)
        kspeaker = rint:k(1,$NCHNLS)
        kdorev = rint:k(0,4)
        krenverse=rint:k(2, 3 )
        kwhen = random:k(0.5, 1)
        kbuzzy = percent:k(0.2)
        karp = percent(0.1)
        karp_incr = random:k(0.05, 0.2)
        chord_generator:
            if(karp == 1) then 
                kwhen += karp_incr
            endif
            kfq = scale_itv(iscale, 3, ibase, kprms2, 1, 35, 75, 1)
            if(kbuzzy == 1 || ifuzzy == 1) then
                schedulek("part2_buzzychords", 0, random:k(1,7), kfq,  kspeaker, random:k(0.03, 0.1))
            else
                schedulek("part2_chords", 0, random:k(1,7), kfq,  kspeaker, 0.03)
            endif
            if(kdorev == 3) then
                krepcnt = 0
                while krepcnt < krenverse do

                    ;gkp1_oscil_args_mode
                    krev = rint:k(0, 2)
                    if(krev == 1) then
                        kfq *= 2
                    elseif(krev == 1) then
                        kfq *= .5
                    endif

                    kspeaker = rint:k(1,$NCHNLS)
                    if(kbuzzy == 1 || ifuzzy == 1) then 
                        schedulek("part2_buzzychords", kwhen * (krepcnt + 1), random:k(1,7), kfq,  kspeaker, random:k(0.03, 0.1))
                    else 
                        schedulek("part2_chords", kwhen * (krepcnt + 1), random:k(1,7), kfq,  kspeaker, 0.03)
                    endif

                    krepcnt += 1
                od
            endif
        loop_lt(klpcnt, 1, klpmax, chord_generator)
    endif
    kfqss[] init 3
    if(keuc == 1 && kmark == 2) then
        kmlpcnt = 0
        bigevent:
            kfqss[kmlpcnt] = scale_itv(iscale, 3, ibase, kprms, keuc, 30, 90, 1)
        loop_lt(kmlpcnt, 1, 3, bigevent)
        schedulek("part2_marsattack", 0, random:k(10,30), kfqss[0], kfqss[1], kfqss[2], random:k(0.1, 0.5), 0.1, 1, random:k(0.01, 0.07), 0, 0 )
    endif
endin
maxalloc "part2_drone", 2

; Calm subscheduler
instr part2_calme
    krar init 0
    imode init p8
    SChordName = "part2_chords"
    if(imode == 1) then 
        SChordName = "part2_amazinggliss"
    endif
    kph = phasor:k(p6, p7)

    isolo = rint:i(1,2)

    kdiv init p4
    kpulses init p5
    keuc = euclidian(1, kdiv, kpulses, 0, kph)

    kprms2[] fillarray 3, 5, 7
    ibase = rint(30, 60)
    kstart init 1
    iscale =  i(gkp2_scale) 

    krar = rolling_russian_roll(7, keuc, keuc)
    krus = rolling_russian_roll(3, keuc, keuc)

    imin = rint:i(30, 50)
    imax = rint:i( imin, imin + 30)
    if(krus == 1 || kstart == 1) then
        ; Fast events  
        kmontage_smooth = percent:k(0.1)
        if(kmontage_smooth == 1) then 
            kdur = random:k(2, 8)
            kamp = random:k(0.01, 0.075)
            kdurmult = random:k(2, 6)
            kmetfq = rint:k(2, 8)
            schedulek("part2_noisyphrases", 0, kdur, kmetfq, kamp, kdurmult, ibase)
        endif

        kbuzzy = percent:k(0.1)
        krenverse = rint:k(1,4)

        klpcnt = 0
        kwhen = random:k(0.25,1)
        klpmax = rint:k(2,4)
        kdur = random:k(15, 25)
        chord_generator:
            kspeaker = rint:k(1,$NCHNLS)
            kfq = scale_itv(iscale, 4, ibase, kprms2, 1, imin, imax, 1)
            if(kbuzzy == 1) then
                schedulek("part2_buzzychords", 0, kdur * random:k(1,2), kfq,  kspeaker, random:k(0.03, 0.1))
            else
                schedulek("part2_chords", 0, kdur, kfq,  kspeaker, 0.03)
            endif
            if(krenverse == 1) then
                krev = rint:k(0, 2)
                if(krev >= 1) then
                    kfq *= 2
                elseif(krev == 0) then
                    kfq *= .5
                endif
                if(kbuzzy == 1) then 
                    schedulek("part2_buzzychords", kwhen, kdur*random:k(1, 2), kfq,  kspeaker, random:k(0.03, 0.1))
                else 
                    schedulek("part2_chords", kwhen, kdur, kfq,  kspeaker, 0.03)
                endif
            endif
        loop_lt(klpcnt, 1, klpmax, chord_generator)

    endif
    if(isolo == 1 && krar == 1) then
        krsplcnt = 0
        krsplmax = rint:k(1, 4)
        vcglide_loop:
            kdur = random:k(10, 30)
            kfqrnd = random:k(0.7, 2)
            kfq *= kfqrnd
            schedulek("part2_vcglide", 0, kdur,kfq, kfq + 500, 0.02, gisoft)
        loop_lt(krsplcnt, 1, krsplmax, vcglide_loop)
    endif

    kstart = 0
endin
maxalloc("part2_calme", 2)

; pianissimo and high pitch subscheduler
instr 204
    imode = rint:i(1, 3)
    ; mode 1 = voice + click + synt
    ; mode 2 = click + synt
    ; mode 3 = voice + click + tiny synt

    ibase = p8
    iclick = percent:i(0.75)
    kph = phasor:k(p6, p7)
    keuc = euclidian(1, p4, p5, 0, kph)
    keuc2 = euclidian(1, p4, p5 , 0, phasor:k(0.35))

    kclickspeed = random:i(1.5, 3)
    kclickmov = random:i(1, 1.5)
    kdrunk = drunk( rspline:k(kclickspeed, kclickspeed * kclickmov, 0.1, 0.3), 0.75)
    kclickamp = rspline:k(0.005, 0.15, 0.1, 0.25)
    if(kdrunk == 1 && iclick == 1) then 
        schedulek("clics", 0, 0.03, kclickamp, random:k(5000, 10000))
        schedulek("clics", 0.01, 0.03, kclickamp, random:k(5000, 10000))
    endif

    kvoicetrig = drunk(0.08, 0.75)
    printk2 kvoicetrig
    print imode
    if(kvoicetrig == 1 && (imode == 1 || imode == 3) ) then 
        kdrive = random:i(10, 20)
        kamp = random:k(0.1, 0.2)
        kamp = (imode == 1) ? kamp * 2 : kamp
        kdur = random:k(10, 20)
        schedulek("crunchyvoice", 0, kdur, kdrive, kamp, kclickspeed)
    endif
    iprms_size = rint:i(2, 6)
    kprms[] init iprms_size
    icnt = 0
    while icnt < iprms_size do 
      kprms[icnt] = rint:i(1, 8)
      icnt += 1
    od
    ;kprms[] = random_array_int(rint:i(2, 6), 1, 8)
    kfqs[] init 3
    kmark = markov(201, 1, keuc2)
    iscale = i(gkp2_scale) ;gibebopdominant
    kreversmark = markov(205, 1, keuc)
    kbeatmark = markov(205, 1, keuc)
    kmodamp = percent:k(0.15) ; chance to enable amplitude modulation
    kstart init 1
    inotemin = random:i(50, 65)
    inotemax = random:i(inotemin+7, 90)

    if( (keuc == 1 ||kstart == 1) && (imode == 3)) then 
        ;schedulek("part2_chords", 0, 1, 1000,  1, 0.05)
        kcnt = 0
        kdur = random:k(15, 30)
        kamp = random:k(0.0003, 0.007)
        ihighmin = random:i(70, 85)
        ihighmax = random:i(ihighmin+3, 100)
        multiple_fqs_high:
            kfqs[kcnt] = scale_itv(iscale, 3, ibase, kprms, keuc, ihighmin, ihighmax, 1)
        loop_lt(kcnt, 1, 3, multiple_fqs_high)
        schedulek("part2_marsattack", 0, kdur, kfqs[0], kfqs[1], kfqs[2], random:k(0.1, 0.5), 0.5, 2, kamp, 0, percent(0.25) )
        if (kbeatmark == 2) then 
            kwhen = random:k(0, 8)
            schedulek("part2_marsattack",kwhen , kdur, kfqs[0] * random:k(1.001, 1.1), kfqs[1] * random:k(0.9, 0.999), kfqs[2] * 1.01, random:k(0.1, 0.5), 0.5, 2, kamp, 0 , percent(0.25))
        endif
        if(kreversmark == 2) then
            kwhen = random:k(0, 8)
            krev = rint:k(0, 2)
            kmult = 1
            if(krev == 0) then
                kmult = 0.5
            elseif(krev >= 1) then
                kmult = 2
            endif
            schedulek("part2_marsattack", kwhen, kdur, kfqs[0] * kmult, kfqs[1] * kmult, kfqs[2] * kmult, random:k(0.1, 0.5), 0.5, 2, kamp, 0 , kmodamp)
        endif
    endif

    if( (keuc == 1 || kstart == 1 ) && (imode < 3) ) then
        ;schedulek("part2_chords", 0, 1, 1000,  1, 0.05)
        kcnt = 0
        kdur = random:k(15, 30)
        kamp = random:k(0.01, 0.05)
        multiple_fqs:
            kfqs[kcnt] = scale_itv(iscale, 3, ibase, kprms, keuc, inotemin, inotemax, 1)
        loop_lt(kcnt, 1, 3, multiple_fqs)
        schedulek("part2_marsattack", 0, kdur, kfqs[0], kfqs[1], kfqs[2], random:k(0.1, 0.5), 0.5, 2, kamp, 0, percent(0.25) )
        if (kbeatmark == 2) then 
            kwhen = random:k(0, 8)
            schedulek("part2_marsattack",kwhen , kdur, kfqs[0] * random:k(1.001, 1.1), kfqs[1] * random:k(0.9, 0.999), kfqs[2] * 1.01, random:k(0.1, 0.5), 0.5, 2, kamp, 0 , percent(0.25))
        endif
        if(kreversmark == 2) then
            kwhen = random:k(0, 8)
            krev = rint:k(0, 2)
            kmult = 1
            if(krev == 0) then
                kmult = 0.5
            elseif(krev >= 1) then
                kmult = 2
            endif
            schedulek("part2_marsattack", kwhen, kdur, kfqs[0] * kmult, kfqs[1] * kmult, kfqs[2] * kmult, random:k(0.1, 0.5), 0.5, 2, kamp, 0 , kmodamp)
        endif
    endif
    kstart = 0
endin

instr part2_stop_subseq
	ip1 nstrnum "part2_drone"
    ip2 nstrnum "part2_calme"
    ip3 init 203
    ip4 init 204 

	turnoff2 ip1, 0, 1
    turnoff2 ip2, 0, 1
    turnoff2 ip3, 0, 1
    turnoff2 ip4, 0, 1
endin

opcode p2get_active_instances, k, 0
    k1 = active:k("part2_calme", 1) + active:k("part2_drone", 1) + active:k(203, 1) + active:k(204, 1) 
    xout k1
endop

; Main scheduler 
instr part2
    seed 0
	kph = phasor:k(0.01)
	keu init 1
	keu = euclidian(1, 3, 9, 0, kph)

    kmark = markov(202, 1, keu)
    kmainmark = markov(203, 1, keu)
    kinstances = p2get_active_instances()

    iScalesArr[]  fillarray gibebopdominant, gibebopdominantflatnine, gibebopmajor
    idecision rint 1,4
    kdecision init idecision
    if(kmainmark == 2 || kinstances == 0) then
        kdecision = rint:k(1, 4)
        krnd = rint(0, lenarray(giAltScales)-1)
        gkp2_scale = giAltScales[krnd]  
    endif

    printf(">>>>>>>>>>>>>>>>>>> Part 2 - decision is %d\n", keu, kdecision)
    kstart init 1
    if( keu == 1 || kstart == 1 ) then
        schedulek("part2_stop_subseq", 0, 1)
        kwhen = 1.5
        if(kdecision == 1) then ; drone 
            kdiv = random:k(2, 4) 
            kpulses = random:k(19, 25)
            kphfq = (kmark==1) ? random:k(0.003, 0.01) : random:k(0.05, 0.15)
            ktr = (kmark == 2) ? 1 : 0
            kbasenote = random:k(30, 60)
            kdur = random:k(80, 150)
            schedulek("part2_drone", kwhen, kdur, kdiv, kpulses, kphfq, kph, kbasenote)
        elseif(kdecision == 2) then ; calme 
            kdiv = rint(3,5)
            kpulses = rint(7,9)
            kphfq = random:k(0.05, .2/*0.125*/)
            kdur = random:k(50, 100)
            schedulek("part2_calme", kwhen, kdur, kdiv, kpulses, kphfq, kph, 0)
        elseif (kdecision == 3) then ; 203
            kdiv = rint:k(3,5)
            kpulses = rint:k(6,8)
            ;kphfq = random:k(0.3, 0.5)
            kphfq = random:k(0.05, 0.15)
            kdur = random:k(20, 50)
            kbasenote = random:k(20, 60)
            schedulek(203, kwhen, kdur, kdiv, kpulses, kphfq, kph, kbasenote)
        elseif (kdecision == 4) then  ; 204
            kdiv = random:k(2, 4) 
            kpulses = random:k(19, 25)
            kphfq = (kmark==1) ? random:k(0.003, 0.01) : random:k(0.05, 0.15)
            ktr = (kmark == 2) ? 1 : 0
            kbasenote = random:k(30, 60)
            kdur = random:k(80 , 120)
            schedulek(204, kwhen, kdur, kdiv, kpulses, kphfq, kph, kbasenote)
        endif
    endif

    ; Triggers a comb effect on global audio output
    kglobal_effect init 0
    if(keu == 1) then 
        kglobal_effect = percent:k(0.1)
    endif
    if(kglobal_effect == 1 && keu == 1) then 
        turnoff2("global_aspiration", 0, 1)
        schedulek("global_aspiration", kwhen , 20)
    endif

    kstart = 0
endin

instr part2_stop_sched
	imain_nstr nstrnum "part2"
	turnoff2 imain_nstr, 0, 1
	
	ip1 nstrnum "part2_drone"
	ip2 nstrnum "part2_calme"
	ip3 init 203
    ip4 init 204

	turnoff2 ip1, 0, 1
	turnoff2 ip2, 0, 1
	turnoff2 ip3, 0, 1
    turnoff2 ip4, 0, 1
endin

