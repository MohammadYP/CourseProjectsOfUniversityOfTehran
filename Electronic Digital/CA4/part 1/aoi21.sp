AOI21 4-bit

*********Library*************
.lib    '32nm_bulk.pm'    tt

**** parameters ****
.param      VDD=1
.param      Lmin=32n
.param      Wn=Lmin
*.param      t=5n

*********AOI21-Logic**********
.subckt     AOI21        A        B        C        Vout

Mn_a        X1        A        0        0        nmos     l=Lmin      w='2*Wn'
Mn_b        Vout      B        X1       0        nmos     l=Lmin      w='2*Wn'
Mn_c        Vout      C        0        0        nmos     l=Lmin      w='1*Wn'

Mp_a        X2        A        VD       VD       pmos     l=Lmin      w='4*Wn'
Mp_b        X2        B        VD       VD       pmos     l=Lmin      w='4*Wn'
Mp_c        Vout      C        X2       VD       pmos     l=Lmin      w='4*Wn'

Vsupply     VD      0       VDD

.ends       AOI21  

*********SIMULATION**********
X1      A       B       C       Vout        AOI21

.meas   tran    Td_ZERO_TO_ONE    trig   v(A)    td=1ns   val='VDD/2'  cross=1 targ   v(Vout)   val='VDD/2'  cross=1
.meas   tran    Td_ONE_TO_ZERO    trig   v(A)    td=2ns   val='VDD/2'  cross=1 targ   v(Vout)   val='VDD/2'  cross=1

.vec 'VEC_FILE.txt'
.option post=2
.tran   1ps    5ns

.end
