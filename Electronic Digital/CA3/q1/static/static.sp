Q1

*********Library*************
.lib '32nm_bulk.l' tt

**** parameters ****
.param      VDD=1
.param      Lmin=32n
.param      Wn=Lmin

*********static**************
.subckt     static     A        B       C       Vout
Mn_a      X1        A       0       0       nmos     l=Lmin      w='2*Wn'
Mn_b      X1        B       0       0       nmos     l=Lmin      w='2*Wn'
Mn_c      Vout      C       X1      0       nmos     l=Lmin      w='2*Wn'

Mp_a      X2        A       VD      VD      pmos     l=Lmin      w='4*Wn'
Mp_b      Vout      B       X2      VD      pmos     l=Lmin      w='4*Wn'
Mp_c      Vout      C       VD      VD      pmos     l=Lmin      w='2*Wn'

Vsupply     VD      0       VDD
.ends       static

*********SIMULATION**********
X1 A B C Vout static


*part a
*.vec 'part_static.txt'

*part b
.meas   tran    Td_LH    trig   v(B)     td=1ns   val='VDD/2'  cross=1 targ   v(Vout)   val='VDD/2'  cross=1
.meas   tran    Td_HL    trig   v(A)     td=2ns   val='VDD/2'  cross=1 targ   v(Vout)   val='VDD/2'  cross=1


*part c & d
.meas   tran    AVGpower_Hight           AVG power   from=1.2ns  to=2ns
.meas   tran    AVGpower_Low             AVG power   from=2.2ns  to=3ns
.meas   tran    AVGpower_Dynamic_Hight   AVG power   from=1ns    to=1.15ns
.meas   tran    AVGpower_Dynamic_Low     AVG power   from=2ns    to=2.15ns
.vec 'part_static_b.txt'

.option post=2
.tran   10ps    10ns

.end
