CLA 4-bit

*********Library*************
.lib    'crn90g_2d5_lk_v1d2p1.l'    TT_lvt

**** parameters ****
.param      VDD=1
.param      Lmin=100n
.param      Wn=500n
*.param      t=5n

*********Inverter************
.subckt     INV     Vin     Vout
M1      Vout        Vin     0       0       nch_lvt     l=Lmin      w=Wn
M2      Vout        Vin     VD      VD      pch_lvt     l=Lmin      w='2*Wn'
Vsupply     VD      0       VDD
.ends     INV

*********2-Input-Nand********
.subckt     NAND2       A       B       Vout
M1      x       B       0       0       nch_lvt     l=Lmin      w='2*Wn'
M2      Vout    A       x       0       nch_lvt     l=Lmin      w='2*Wn'
M3      Vout    A       VD      VD      pch_lvt     l=Lmin      w='2*Wn'
M4      Vout    B       VD      VD      pch_lvt     l=Lmin      w='2*Wn'
Vsupply     VD      0       VDD
.ends     NAND2

*********2-Input-And*********
.subckt     AND2        A       B       Vout
X1      A       B       out0        NAND2
X2      out0    Vout    INV
.ends     AND2

*********2-Input-NOR*********
.subckt     NOR2     A       B       Vout
M1      Vout     A       0       0       nch_lvt     l=Lmin      w=Wn
M2      Vout     B       0       0       nch_lvt     l=Lmin      w=Wn
M3      x        A       VD      VD      pch_lvt     l=Lmin      w='4*Wn'
M4      Vout     B       x       VD      pch_lvt     l=Lmin      w='4*Wn'
Vsupply     VD      0       VDD   
.ends     NOR2

*********2-Input-OR**********
.subckt     OR2     A       B       Vout
X1      A       B       out0        NOR2
X2      out0    Vout    INV
.ends     AND2

**** 2-input xor gate ****
.subckt     XOR2        A       B       Vout
X1      A       Abar    INV
X2      B       Bbar    INV

X3      Abar    B       out0    AND2
X4      A       Bbar    out1    AND2
X5      out0    out1    Vout    OR2
.ends     XOR2


*********GP-Logic************
.subckt     GP      A       B       G       P
X1      A       B       G       AND2
X2      A       B       P       XOR2
.ends       GP

*********AO21-Logic**********
.subckt     AO21     A       B       C       Vout
X1      B       C      out0     AND2
X2      A       out0   Vout     OR2 
.ends       AO21  

*********4-bit-CLA***********
.subckt     CLA4    Cin     A4 A3 A2 A1     B4 B3 B2 B1     Cout    S4 S3 S2 S1
X1      A1      B1      G1      P1      GP
X2      A2      B2      G2      P2      GP 
X3      A3      B3      G3      P3      GP 
X4      A4      B4      G4      P4      GP

X5      G1      Cin     P1      G10     AO21
X6      G2      G10     P2      G20     AO21
X7      G3      G20     P3      G30     AO21
X8      G4      G30     P4      Cout    AO21

X9      Cin     P1      S1      XOR2
X10     G10     P2      S2      XOR2
X11     G20     P3      S3      XOR2
X12     G30     P4      S4      XOR2
.ends       CLA4

*********SIMULATION**********
X1      Cin     A4 A3 A2 A1     B4 B3 B2 B1     Cout    S4 S3 S2 S1       CLA4
*X2      0       0      Vout    XOR2
*X3      0       Vout        INV
*X4      VD       VD       Vout2    NAND2
*Vsupply     VD      0       VDD   

.meas   tran    Td_tb1_cout    trig   v(A1)    td=0.8ns   val='VDD/2'  cross=1 targ   v(cout)   val='VDD/2'  cross=1
.meas   tran    Td_tb1_S4      trig   v(A1)    td=0.8ns   val='VDD/2'  cross=1 targ   v(S4)     val='VDD/2'  cross=1
.meas   tran    Td_tb1_S3      trig   v(A1)    td=0.8ns   val='VDD/2'  cross=1 targ   v(S3)     val='VDD/2'  cross=1
.meas   tran    Td_tb1_S2      trig   v(A1)    td=0.8ns   val='VDD/2'  cross=1 targ   v(S2)     val='VDD/2'  cross=1
.meas   tran    Td_tb1_S1      trig   v(A1)    td=0.8ns   val='VDD/2'  cross=1 targ   v(S1)     val='VDD/2'  cross=1

.meas   tran    Td_tb2_S4      trig   v(A4)    td=1.6ns   val='VDD/2'  cross=1 targ   v(S4)     val='VDD/2'  cross=1

.meas   tran    Td_tb3_S4      trig   v(B1)    td=3.2ns   val='VDD/2'  cross=1 targ   v(S4)     val='VDD/2'  cross=1

.meas   tran    Td_tb4_cout    trig   v(B1)    td=4.8ns   val='VDD/2'  cross=1 targ   v(cout)   val='VDD/2'  cross=1
.meas   tran    Td_tb4_S4      trig   v(B1)    td=4.8ns   val='VDD/2'  cross=1 targ   v(S4)     val='VDD/2'  cross=1
.meas   tran    Td_tb4_S3      trig   v(B1)    td=4.8ns   val='VDD/2'  cross=1 targ   v(S3)     val='VDD/2'  cross=1
.meas   tran    Td_tb4_S2      trig   v(B1)    td=4.8ns   val='VDD/2'  cross=1 targ   v(S2)     val='VDD/2'  cross=1
.meas   tran    Td_tb4_S1      trig   v(B1)    td=4.8ns   val='VDD/2'  cross=1 targ   v(S1)     val='VDD/2'  cross=1

****look for power version folder
*.meas   tran    AVGpower    AVG power   from=0ns  to='t*8' 

.vec 'part3.txt'
*.vec    'VEC_CLA4bit.txt'

.option post=2
.tran   10ps    10ns


.alter
.temp 0
.alter
.temp 100

.end
