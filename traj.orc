/*
        This file contains user defined opcodes for spatialization
        These techniques can be seen as raw / low-tech techniques
*/

opcode jout, 0, ai[]k[]o
        ain, ichnl[], kvals[], icnt xin
        isize lenarray ichnl
        if icnt >= isize goto nothing
        ;outch(ichnl[icnt], ain * kvals[icnt])
        set_out(ichnl[icnt], ain * interp(kvals[icnt]))

        jout(ain, ichnl, kvals, icnt + 1)
        nothing:
endop

// Direct out of signals
opcode jdout, 0, a[]i[]o
        asigs[],ichnls[], icnt xin
        isize lenarray asigs
        if icnt >= isize goto nothing
        ;outch(ichnls[icnt], asigs[icnt])
        set_out(ichnls[icnt], asigs[icnt])
        jdout(asigs, ichnls, icnt + 1)
        nothing:
endop

opcode ftconcat, i, ii
  ic1, ic2 xin 
  ilen1 = ftlen(ic1)
  ilen2 = ftlen(ic2)
  isize = ilen1+ilen2
  igen = ftgen(0, 0, isize, -2, 0)
  icnt init 0 
  while icnt < isize do
    isig init 0
    if(icnt < ilen1) then 
      isig = table(icnt, ic1)
    else 
      isig = table(icnt - ilen1, ic2)
    endif
    tablew(isig, icnt, igen)
    icnt += 1
  od
  xout igen
endop

opcode traj, 0, ai[]ik
        ain, ichnls[], iprecrv, ktraj xin
        inchnl = lenarray(ichnls)
        ksigs[] init inchnl
        kcnt = 0

        icrvlen = ftlen(iprecrv)
        izerocrv = ftgen(0, 0, icrvlen* (inchnl-1), -2, 0) 
        icrv = ftconcat(iprecrv, izerocrv)

        #ifdef ENABLE_PLUGINS
          izerocrv = hc_hypercurve(0, icrvlen * (inchnl - 1), 0, hc_segment(1, 0, hc_linear_curve()))
          icrv = hc_concat(0, 1000, iprecrv, izerocrv)
        #else
          izerocrv = ftgen(0, 0, icrvlen* (inchnl-1), -2, 0) 
          icrv = ftconcat(iprecrv, izerocrv)
        #endif
  
        while kcnt < inchnl do
                kcc =  inchnl - kcnt
                koff = (kcc  + 0.5 ) / inchnl
                kw = wrap(ktraj + koff, 0, 1)
                ksigs[kcnt] = tablei:k(kw, icrv, 1)
                kcnt += 1
        od

        jout(ain, ichnls, ksigs)
endop

opcode traj_vals, k[], ai[]ik
        ain, ichnls[], iprecrv, ktraj xin
        inchnl = lenarray(ichnls)
        ksigs[] init inchnl
        kcnt = 0

        icrvlen = ftlen(iprecrv)
        #ifdef ENABLE_PLUGINS
          izerocrv = hc_hypercurve(0, icrvlen * (inchnl - 1), 0, hc_segment(1, 0, hc_linear_curve()))
          icrv = hc_concat(0, 1000, iprecrv, izerocrv)
        #else
          izerocrv = ftgen(0, 0, icrvlen* (inchnl-1), -2, 0) 
          icrv = ftconcat(iprecrv, izerocrv)
        #endif

        while kcnt < inchnl do
                kcc =  inchnl - kcnt
                koff = (kcc  + 0.5 ) / inchnl
                kw = wrap(ktraj + koff, 0, 1)
                ksigs[kcnt] = tablei:k(kw, icrv, 1)
                kcnt += 1
        od
        xout ksigs
endop


opcode traj_filters, 0, ai[]ik
        asig, ichnls[], iprecrv, ktraj xin
        ksigs[] = traj_vals(asig, ichnls, iprecrv, ktraj)

        isize lenarray ksigs
        asigs[] init isize

        kcnt = 0
        while kcnt < isize do
                kcf = (1 - ksigs[kcnt]) * 1000 + 20
                asigs[kcnt] = K35_lpf(asig, kcf, 9.9, 1, 1.05) * ksigs[kcnt]
                kcnt += 1
        od

        jdout(asigs, ichnls)
endop



opcode hpan, 0, akk
        asig, kx, ky xin

        imax_ypos = int($NCHNLS/2)

        if(nchnls == 2) then 
                al, ar pan2 asig, kx
                gaOut[0] = gaOut[0] + al
                gaOut[1] = gaOut[1] + ar
        elseif(nchnls > 2) then 
        kcnt = 0
                while kcnt < $NCHNLS do
                        kmult = 0
                        kspeaker_ypos = kcnt - int(kcnt/2) - 1
                        // 0.5 is base offset (0 is basically the end of curve for speakers of y 0 position)
                        kxm = ( (1 - ky) + (kspeaker_ypos / imax_ypos)) 
                        kymult = tablei:k(kxm, gitriangle, 1)
                        ;printk2 ky, 10
                        if( (kcnt % 2 ) == 0) then
                        // Left
                                kmult = (1 - kx) * kymult
                        else 
                        // Right
                                kmult = kx * kymult
                        endif
                        gaOut[kcnt] = gaOut[kcnt] + (asig * kmult)
                        kcnt += 1
                od
        endif
endop

















