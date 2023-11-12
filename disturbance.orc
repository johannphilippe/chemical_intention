/*
	This file is a prototype for some global audio effects. 
	It contains the "global aspiration" effect that will apply a set of comb filters to the master
*/

opcode disturb, 0, i
    idur xin

    amult = linseg:a(1, 0.05, 0, idur - 0.1, 0, 0.05, 1)
	kcnt = 0
	while kcnt < $NCHNLS do
		gaOut[kcnt] = gaOut[kcnt] * amult
		kcnt += 1
	od
endop

instr dist1
	disturb(p3)
	ifq = rint:i(100, 200)
	ispeakers[] = random_array_int(rint:i(1,3), 1, $NCHNLS)
	ao = vco2(0.02, ifq)
	set_outs(ispeakers, ao)
endin

gihcarr[] fillarray gidescend, gifastatq, gihcslow, gistcrv
opcode dist2_audio, 0, kii
	kcrv, ilen, icnt xin
	ao = 0
	if(icnt == ilen) goto mmnothing
	dist2_audio(kcrv, ilen, icnt + 1)
	mmnothing:
	imult = random:i(100, 1000)
	ioff = random:i(50, 300)
	kfq = kcrv * imult + ioff
	aosc = skf(vco2(0.1, kfq, 12), kfq * 4, 2)

	asig = (ao + aosc)
	asig *= tablei:k(linseg:k(0,p3,1), gitight, 1)
	kx = rspline(0, 1, 0.1, 1)
	ky = rspline(0, 1, 0.1, 1)
	hpan(asig, kx, ky)	
endop

instr dist2
	disturb(p3)
	incrv = lenarray(gihcarr)
	icrv = gihcarr[rint:i(1, incrv) - 1]
	kcrv = tablei:k(linseg(0,p3,1), icrv, 1)
	ilen = rint:i(1,12)
	dist2_audio(kcrv, ilen, 0) 
endin

opcode disturbance, 0, 0
	kArr[] init 1
	kArr[0] = euclidian(1, 3, 9, 0, phasor:k(0.001))
	kmark = markov(4, 1, kArr[0] )
    printf("### disturbance n°%d\n\n", kArr[0], kmark)
	if(kArr[0] == 1) then
		if(kmark == 1) then
	    	kdur = random:k(0.1, 0.6)
		elseif(kmark == 2) then
	    	kdur = random:k(1.5, 8)
			schedulek("dist2", 0, kdur)
		elseif(kmark == 3) then 
	    	kdur = random:k(0.1, 0.3)
			schedulek("dist2", 0, kdur)
		elseif(kmark = 4) then
	    	kdur = random:k(1.5, 8)
			schedulek("dist2", 0, kdur)
        endif
	endif
endop

instr global_aspiration
	idur init p3
	asigs[] init  $NCHNLS
	kcnt = 0
	while kcnt < $NCHNLS do 
		asigs[kcnt] = gaOut[kcnt]
		kcnt += 1
	od
	amult = expsegr:a(0.01, p3/2, 1.01, p3/2, 0.01) - 0.01
	aimult = a(1) - amult

	kcnt = 0
	lp:
		gaOut[kcnt] = (gaOut[kcnt] * aimult) + (comb(asigs[kcnt], rspline:k(0.005, 0.02, 0.01, 0.2) * (kcnt+1), 3.5 ) * amult)
	loop_lt(kcnt, 1, $NCHNLS, lp)
endin
maxalloc "global_aspiration", 1


