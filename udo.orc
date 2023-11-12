/*
	This file contains user defined opcodes (UDOS) that can be used in this project. 
	It covers from simple conversion utilities to complex audio algorithms (vocoder, cutter ...)
*/

/*
	Start and kill utilities
*/

instr KillImpl
  Sinstr = p4
  if (nstrnum(Sinstr) > 0) then
    turnoff2(Sinstr, 0, 0)
  endif
  turnoff
endin

opcode kill, 0, S
	Sinstr xin
	schedule("KillImpl", 0, .05, Sinstr)
endop

opcode start, 0, S
	Sinstr xin
	if (nstrnum(Sinstr) > 0) then
		kill(Sinstr)
		schedule(Sinstr, ksmps / sr, -1)
	endif
endop

opcode nst, i, Si
	Sname, ifrac xin
	iinst = nstrnum(Sname) + ifrac
	xout iinst
endop

/*
	Rhythm UDOS 
*/

opcode euclidian, k, kkkkk
        konset, kdiv, kpulses, krot, kphasor xin

        kph = int( ( ( (kphasor + krot)  * kdiv) / 1) * kpulses)
        keucval = int((konset / kpulses) * kph)
        kold_euc init i(keucval)
        kold_ph init i(kph)

        kres = ((kold_euc != keucval) && (kold_ph != kph)) ? 1 : 0

        kold_euc = keucval
        kold_ph = kph

        xout kres
endop

/*
	Random UDOS
*/
opcode chance, k, kkk
	k1, k2, kchance xin
	
	kch = int(random(1, kchance + 1))
	kres = (kch == 1) ? k1 : k2

	xout kres
endop

opcode ichance_trig, k, iikk
	i1, i2, kchance, ktrig xin
	kres init i2
	if(ktrig == 1) then
		kch = int(random:k(1, kchance + 1))
		kres = (kch == 1) ? i1 : i2
	endif
	xout kres
endop

opcode kchance_trig, k, kkkk
	k1, k2, kchance, ktrig xin
	kres init i(k2)
	if(ktrig == 1) then
		kch = int(random:k(1, kchance + 1))
		kres = (kch == 1) ? k1 : k2
	endif
	xout kres
endop

opcode chance, k, kk
	ktrig, kchance xin
	kch = int(random(1, kchance + 1))
	kres = (ktrig == 1 && kch == 1) ? 1 : 0
	xout kres
endop

opcode select2, k, kkk
	kone, ktwo, ksel xin
	kout = (ksel > 0) ? ktwo : kone
	xout kout
endop

opcode jump_after, k , iii
	ifi, is, id xin
	kres = linseg:k(ifi, id, ifi, 0, is)
	xout kres
endop

/*
	MIDI and pitch conversion UDOS
*/
opcode jmtofi,i,i
        imid xin
        iout = 440 * exp(0.0577622645 * (imid - 69))
        xout iout
endop

opcode jmtofk, k,k
	kmid xin
        kout = 440 * exp(0.0577622645 * (kmid - 69))
        xout kout
endop
	
/* 
	Amplitude UDOS
*/
opcode crescendo, k, i
	idur xin
	kamp = tablei:k(linseg:k(0, idur, 1), giAmps, 1) 
	xout kamp
endop

opcode decrescendo, k, i
	idur xin
	kamp = tablei:k(linseg:k(1, idur, 0), giAmps, 1)
	xout kamp
endop

opcode exp_cresc, k, i
	idur xin
	kamp = tablei:k(expseg:k(0.01, idur, 1), giAmps, 1)
	xout kamp
endop

opcode exp_decresc,k,i
	idur xin
	kamp = tablei:k(expseg:k(1, idur, 0.01), giAmps, 1)
	xout kamp
endop

opcode loop_cresc, k, i
	idur xin
	ifq = 1 / idur
	kamp = tablei:k(phasor:k(ifq), giAmps, 1)
	xout kamp
endop

opcode loop_decresc, k, i
	idur xin
	ifq = 1 / idur
	kph = 1 - phasor:k(ifq)
	kamp = tablei:k(kph, giAmps, 1)
	xout kamp
endop

/*
	Triangle on amplitudes (cresc and decresc in loop)
*/
opcode ampline, k, i
	idur xin
	ifq = 1 / idur 
	kdx = loopseg(ifq, 0, 0, 0, 0.5, 0.99, 0.5, 0)
	kamp = tablei:k(kdx, giAmps, 1)
	xout kamp	
endop

/*
	Iterators
*/
opcode intphasor, k, kk
	kmult, kfreq xin
	kres = int(phasor(kfreq) * kmult)
	xout kres
endop

/* 
	Steven Yi's Wavefolder
*/
opcode wavefolder_lambert, k, kk
  kx, kLn1 xin

  ithresh = 10e-10
  kw = kLn1
  kndx = 0
  while (kndx < 1000) do
    kexpw = pow:k($M_E, kw)

    kp = kw * kexpw - kx
    kR = (kw + 1) * kexpw
    ks = (kw + 2) / (2 * (kw+1))        
    kerr = (kp / (kR - (kp * ks)))
    
    if (abs(kerr) < ithresh) then 
      kndx = 1000
    else 
      kw = kw - kerr;
       
      kndx += 1

    endif
  od 
  xout kw
endop

; Homemade wavefolder
opcode wavefolder, a,a
  ain xin
  asig init 0
 
  ;; State
  kLn1 init 0
  kFn1 init 0
  kxn1 init 0

  ;; Constants
  iRL = 7.5e3;
  iR = 15e3;  
  iVT = 26e-3;
  iIs = 10e-16;

  ia = 2*iRL/iR
  ib = (iR+2*iRL)/(iVT*iR)
  id = (iRL*iIs)/iVT

  
  ;; Antialiasing error threshold
  ithresh = 10e-10

  kndx = 0
  while (kndx < ksmps) do
    kin = ain[kndx]
    kout init 0

    ;; Compute Antiderivative
    kl = signum(kin)
    ku = id * pow($M_E,kl * ib * kin)
    kLn = wavefolder_lambert(ku, kLn1)
    kFn = (0.5 * iVT / ib) * (kLn * (kLn + 2)) - 0.5 * ia * kin * kin 

    ;; Check for ill-conditioning
    if (abs(kin-kxn1) < ithresh) then 
            
        // Compute Averaged Wavefolder Output
        kxn = 0.5 * (kin + kxn1)
        ku = id * pow($M_E,kl * ib * kxn)
        kLn = wavefolder_lambert(ku,kLn1)
        kout = kl * iVT * kLn - ia * kxn;

    else 
        
        ;; Apply AA Form
        kout = (kFn - kFn1) / (kin - kxn1)
        
    endif 

    aout[kndx] = kout

    ;; Update States
    kLn1 = kLn;
    kFn1 = kFn;
    kxn1 = kin;

    kndx += 1
  od

  xout aout
endop 

// Random array of integers
opcode random_array_int, i[], iii
	isize, imin, imax xin	
	iarr[] init isize

	icnt init 0
	while icnt < isize do 
		iarr[icnt] = int(random:i(imin, imax))
		icnt += 1
	od
	xout iarr
endop
opcode random_array_int, k[], iii
	isize, imin, imax xin
	kArr[] init isize
	icnt init 0
	iArr[] = random_array_int(isize, imin, imax)
	while icnt < isize do
		kArr[icnt] = iArr[icnt]
		icnt += 1
	od
	xout kArr
endop

// Metronome with randomness
opcode drunk, k, kk
  kfreq, knoise_amt xin
  krand = random:k(-knoise_amt, knoise_amt) 
  kpick = metro:k(10)
  knoi init  0
  if(kpick == 1) then 
    knoi = krand
  endif
  
  kres = metro:k(  limit:k(kfreq + (kfreq * knoi), 0.001, 100) )
  xout kres
endop


opcode rint, i, ii
	imin, imax xin
	irnd = int(random:i(imin, int(imax) + 0.99))
	xout irnd
endop

opcode rint, k, kk
	kmin, kmax xin
	krnd = int(random:k(kmin, int(kmax) + 0.99))
	xout krnd
endop

opcode russian_roll, k, ikk
	isize, ktrig, kinp xin
	ipos = int(random:i(0, isize - 0.01))
	kmod init 0
	kres init 0
	kmult init 0
	if(ktrig > 0) then
		kmult = ( (kmod % isize) == ipos) ?  1 : 0
		kres = kinp * kmult 
		kmod += 1
	else
		kres = 0
	endif
	xout kres
endop

opcode rolling_russian_roll, k, ikk
	isize, ktrig, kinp xin
	kmod init 0
	kres init 0
	kmult init 0
	kpos init 0
	if( (kmod % isize) == 0) then
		// recalculate the bullet position
		kpos = rint:k(0, isize - 1)
	endif
	if(ktrig > 0) then
		kmult = ( (kmod % isize) == kpos) ?  1 : 0
		kres = kinp * kmult 
		kmod += 1
	else
		kres = 0
	endif
	xout kres
endop

; Facility for arrays
opcode anyof, k, k[]
	karr[] xin
	kpick = rint:k(0, lenarray(karr)-1)
	kres = karr[kpick]
	xout kres
endop

opcode anyof, i, i[]
	iarr[] xin
	ipick = rint:i(0, lenarray(iarr)-1)
	ires = iarr[ipick]
	xout ires
endop

; Victor Lazzarini's Vocoder 
opcode vocoder, a, aakkkii
	as1,as2,kmin,kmax,kq,ibnd,icnt  xin

	if kmax < kmin then
	ktmp = kmin
	kmin = kmax
	kmax = ktmp
	endif

	if kmin == 0 then 
	kmin = 1
	endif

	if (icnt >= ibnd) goto bank
	abnd   vocoder as1,as2,kmin,kmax,kq,ibnd,icnt+1

	bank:
	kfreq = kmin*(kmax/kmin)^((icnt-1)/(ibnd-1))
	kbw = kfreq/kq
	an  butterbp  as2, kfreq, kbw
	an  butterbp  an, kfreq, kbw
	as  butterbp  as1, kfreq, kbw
	as  butterbp  as, kfreq, kbw
	ao balance as, an

	amix = ao + abnd

		xout amix
endop

; Funky random modulator generator
opcode funkymod, k, kkk
	kamp, kfq, kduty xin

	; 1 sine
	; 2 tri
	; 3 square
	; 4 saw up
	; 5 saw down
	; 6 pwm
	iwave = rint:i(1, 6)

	klf_amp = (iwave < 6) ? 1 : 0
	kpwm_amp = 1 - klf_amp

	klfo = lfo:k(kamp, kfq)
	if(iwave < 3) then 
		klfo += kamp
		klfo /= 2
	endif

	klfo *= klf_amp
	
	kpwm = vco2(kamp*0.5, kfq, 2, kduty) + (kamp * 0.5)
	kpwm *= kpwm_amp
	xout klfo + kpwm
endop

; Modulator based on hypercurves
opcode hypermod, k, kki[]
	kamp, kfq, iarr[] xin

	iwaveidx = rint:i(0, lenarray(iarr)-1)
	iwave = iarr[iwaveidx]

	kval = tablei:k(phasor:k(kfq), iwave, 1) * kamp
	xout kval

endop

opcode percent, i, i
	ip xin 
	irnd = random:i(0, 1)
	ires init 0
	if(irnd < ip) then 
		ires = 1
	endif
	xout ires 
endop

opcode percent, k, k
	kp xin 
	krnd = random:k(0, 1)
	kres = 0
	if(krnd < kp) then 
		kres = 1
	endif
	xout kres 
endop


/*
	Cutter - slicer 
	Args:  
	* asig : input signal
	* iwin : window (hanning or any gen table)
	* imaxdur : size of buffer in seconds
	* ksub : slicing subdivision
	* kchoice : which subdivision to use (not obvious it is useful)
	* kstutter : 1 for stutter, 0 for normal
	* kstutterspeed : speedy gonzales

*/
opcode jcut, ak, aiikkkk
	asig, iwin,imaxdur, ksub, kchoice, kstutter, kstutterspeed xin

	kchoice = kchoice % ksub
	kreach init 0
	ksub_ch = changed(ksub)
	kchoice_ch = changed(kchoice)
	kstutter_ch = changed(kstutter)

	ilen_smps = imaxdur * sr
	ibuf ftgentmp 0, 0, ilen_smps, -2, 0
	
	kstut_sub init 1
	kstut_rpos init 0
	if(kstutter_ch > 0) then 
		kstut_sub = ksub
		kstut_rpos = 0
	endif

	kstut_limit = int(ilen_smps / kstut_sub)
	ibuf_stutter ftgentmp 0, 0, ilen_smps, -2, 0

	kwrite_ptr init 0
	
	asig init 0

	kcnt = 0
	while kcnt < ksmps do 
		tablew(asig[kcnt], kwrite_ptr, ibuf)
		kwrite_ptr = (kwrite_ptr + 1) % ilen_smps
		kcnt += 1
	od

	kincr init 0
	kinit init 1
	if(kinit == 1  || kchoice_ch > 0 || ksub_ch > 0 ) then
		kplus = ilen_smps / ksub * kchoice
		kread_ptr = (kwrite_ptr + kplus) % ilen_smps
		kincr = 0
	endif
	kreach = 0

	kcnt = 0
	if(kstutter > 0) kgoto stutter

	kchanged = 0
	kinit = 0
	while kcnt < ksmps do 
		knorm_index = kincr / (ilen_smps/ksub)
		kwin = tablei:k(knorm_index, iwin, 1)

		kread_idx = (kread_ptr + kincr) % ilen_smps
		if(kincr == 0) then 
			kchanged = 1
		endif
		kval = table( (kread_ptr + kincr) % ilen_smps, ibuf)
		aout[kcnt] = kval * kwin

		kincr = (kincr + 1) % int(ilen_smps / ksub) 
		// Write for stutter
		tablew(kval, kincr, ibuf_stutter)
		if(kincr == 0) then 
			kreach = 1
		endif

		
		kcnt += 1 
	od
	kgoto nostutter

	stutter:
	kcnt = 0
	while kcnt < ksmps do 
		knorm_index = kstut_rpos / (ilen_smps / kstut_sub)
		kwin = tablei:k(knorm_index, iwin, 1)
		aout[kcnt] = table(kstut_rpos, ibuf_stutter) * kwin
		kstut_rpos = (kstut_rpos + kstutterspeed) % int(ilen_smps / kstut_sub)
		kcnt += 1		
	od

	nostutter:
	
	xout aout, kchanged
endop




