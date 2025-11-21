Q1 DCVSL

*********Library*************
.lib '32nm_bulk.l' tt

**** parameters ****
.param      VDD=1
.param      Lmin=32n
.param      Wn=Lmin

*********Inverter************
.subckt     INV     Vin     Vout
M1      Vout        Vin     0       0       nmos        l=Lmin      w=Wn
M2      Vout        Vin     VD      VD      pmos        l=Lmin      w='2*Wn'
Vsupply     VD      0       VDD
.ends     INV

*********DCVSL***************
.subckt     DCVSL     A        B       C       Vout        Vout_b

Xa        A         A_b     INV
Xb        B         B_b     INV
Xc        C         C_b     INV

Mn1_a     X1        A       0       0       nmos     l=Lmin      w='2*Wn'
Mn1_b     X1        B       0       0       nmos     l=Lmin      w='2*Wn'
Mn1_c     Vout      C       X1      0       nmos     l=Lmin      w='2*Wn'

Mn2_a     X2        A_b     0       0       nmos     l=Lmin      w='2*Wn'
Mn2_b     Vout_b    B_b     X2      0       nmos     l=Lmin      w='2*Wn'
Mn2_c     Vout_b    C_b     0       0       nmos     l=Lmin      w='1*Wn'

Mp1       Vout      Vout_b  VD      VD      pmos     l=Lmin      w='2*Wn'
Mp2       Vout_b    Vout    VD      VD      pmos     l=Lmin      w='2*Wn'

Vsupply     VD      0       VDD
.ends       DCVSL


*********SIMULATION**********
X1 A B C Vout Vout_b DCVSL

*part a
*.vec 'part_dcvsl.txt'

*part b
.meas   tran    Td_LH    trig   v(B)     td=1ns   val='VDD/2'  cross=1 targ   v(Vout)   val='VDD/2'  cross=1
.meas   tran    Td_HL    trig   v(A)     td=2ns   val='VDD/2'  cross=1 targ   v(Vout)   val='VDD/2'  cross=1

*part c & d
.meas   tran    AVGpower_Hight           AVG power   from=1.2ns  to=2ns
.meas   tran    AVGpower_Low             AVG power   from=2.2ns  to=3ns
.meas   tran    AVGpower_Dynamic_Hight   AVG power   from=1ns    to=1.15ns
.meas   tran    AVGpower_Dynamic_Low     AVG power   from=2ns    to=2.15ns
.vec 'part_dcvsl_b.txt'

.option post=2
.tran   10ps    10ns

.end
