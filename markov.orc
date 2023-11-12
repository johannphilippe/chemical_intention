; This file contains markov chains facilities and translations from Lua. 
; This work has been made to allow web compatibility.
; It is only included if ENABLE_PLUGINS is disabled (config.orc)

#ifdef ENABLE_PLUGINS
    opcode markov, k, iik
        inode, istart, ktrig xin

        iArr[] fillarray inode, istart
        kArr[] init 1
        kArr[0] = ktrig
        kmark = lua_obj("markov", iArr, kArr)
        xout kmark
    endop
#else 
    gimark3_1 = ftgen(0, 0, 0, 2, 0.99, 0.01)
    gimark3_2 = ftgen(0, 0, 0, 2, 0.99, 0.01)
    gimark3 = ftgen(3, 0, 0, 2, gimark3_1, gimark3_2)

    gimark4_1 = ftgen(0, 0, 0, 2, 0.1, 0.2, 0.3, 0.4)
    gimark4_2 = ftgen(0, 0, 0, 2, 0.2, 0.1, 0.4, 0.3)
    gimark4_3 = ftgen(0, 0, 0, 2, 0.3, 0.4, 0.1, 0.2)
    gimark4_4 = ftgen(0, 0, 0, 2, 0.4, 0.3, 0.2, 0.1)
    gimark4 = ftgen(4, 0, 0, 2, gimark4_1, gimark4_2, gimark4_3, gimark4_4)

    gimark7_1 = ftgen(0, 0, 0, 2, 0.2, 0.4, 0.3, 0.1)
    gimark7_2 = ftgen(0, 0, 0, 2, 0.2, 0.1, 0.4, 0.3)
    gimark7_3 = ftgen(0, 0, 0, 2, 0.3, 0.1, 0.2, 0.4)
    gimark7_4 = ftgen(0, 0, 0, 2, 0.25, 0.25, 0.25, 0.25)
    gimark7 = ftgen(7, 0, 0, 2, gimark7_1, gimark7_2, gimark7_3, gimark7_4)

    gimark101_1 = ftgen(0, 0, 0, 2, 0.9, 0.02, 0.08)
    gimark101_2 = ftgen(0, 0, 0, 2, 0.96, 0.02, 0.02)
    gimark101_3 = ftgen(0, 0, 0, 2, 0.96, 0.02, 0.02)
    gimark101 = ftgen(101, 0, 0, 2, gimark101_1, gimark101_2, gimark101_3)

    gimark102_1 = ftgen(0, 0, 0, 2, 0.7, 0.1, 0.2)
    gimark102_2 = ftgen(0, 0, 0, 2, 0.8, 0.1, 0.1)
    gimark102_3 = ftgen(0, 0, 0, 2, 0.7, 0.2, 0.1)
    gimark102 = ftgen(102, 0, 0, 2, gimark102_1, gimark102_2, gimark102_3)

    gimark201_1 = ftgen(0, 0, 0, 2, 0.95, 0.05)
    gimark201_2 = ftgen(0, 0, 0, 2, 0.2, 0.8)
    gimark201 = ftgen(201, 0, 0, 2, gimark201_1, gimark201_2 )

    gimark202_1 = ftgen(0, 0, 0, 2, 0.7, 0.3)
    gimark202_2 = ftgen(0, 0, 0, 2, 1, 0)
    gimark202 = ftgen(202, 0, 0, 2, gimark202_1, gimark202_2)

    gimark203_1 = ftgen(0, 0, 0, 2, 0.9, 0.1)
    gimark203_2 = ftgen(0, 0, 0, 2, 1, 0)
    gimark203 = ftgen(203, 0, 0, 2, gimark203_1, gimark203_2)

    gimark204_1 = ftgen(0, 0, 0, 2, 0.5, 0.25, 0.25)
    gimark204_2 = ftgen(0, 0, 0, 2, 0.25, 0.5, 0.25)
    gimark204_3 = ftgen(0, 0, 0, 2, 0.25, 0.25, 0.5)
    gimark_204 = ftgen(204, 0, 0, 2, gimark204_1, gimark204_2, gimark204_3)

    gimark205_1 = ftgen(0, 0, 0, 2, 0.9, 0.1)
    gimark205_2 = ftgen(0, 0, 0, 2, 0.7, 0.3)
    gimark205  = ftgen(205, 0, 0, 2, gimark205_1, gimark205_2)

    gimark301 = ftgen(301, 0, 0, 2, gimark101_1, gimark101_2, gimark101_3)

    gimark302_1 = ftgen(0, 0, 0, 2, 1/3, 1/3, 1/3)
    gimark302_2 = ftgen(0, 0, 0, 2, 1/3, 1/3, 1/3)
    gimark302_3 = ftgen(0, 0, 0, 2, 1/3, 1/3, 1/3)
    gimark302 = ftgen(302, 0, 0, 2, gimark302_1, gimark302_2, gimark302_3)

    gimark303_1 = ftgen(0, 0, 0, 2, 0.98, 0.02)
    gimark303_2 = ftgen(0, 0, 0, 2, 1, 0)
    gimark303 = ftgen(303, 0, 0, 2, gimark303_1, gimark303_2)

    gimark304_1 = ftgen(0, 0, 0, 2, 0.5, 0.5)
    gimark304_2 = ftgen(0, 0, 0, 2, 0.5, 0.5)
    gimark304 = ftgen(304, 0, 0, 2, gimark304_1, gimark304_2)

    gimark305_1 = ftgen(0, 0, 0, 2, 0.7, 0.15, 0.15)
    gimark305_2 = ftgen(0, 0, 0, 2, 0.7, 0.15, 0.15)
    gimark305_2 = ftgen(0, 0, 0, 2, 0.7, 0.15, 0.15)
    gimark305 = ftgen(305, 0, 0, 2, gimark305_1, gimark305_2)

    opcode markov, k, iik
        inum_mark, istart, ktrig xin

        kindex init istart - 1
        kcur_table = table(kindex, inum_mark)

        if(ktrig == 1) then
            kincr = 0
            krnd = random:k(0, 1)
            kcnt = 0
            while kincr < krnd do
                kcur = tablekt(kcnt, kcur_table)
                kincr += kcur
                kcnt += 1
            od
            kindex = kcnt - 1
        endif
        xout kindex + 1
    endop
#end

