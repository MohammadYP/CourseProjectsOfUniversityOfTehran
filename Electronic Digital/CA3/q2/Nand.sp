Q2- NAND 3 input

*********Library*************
.lib '32nm_bulk.l' tt”

**** parameters ****
.param      VDD=1
.param      Lmin=32n
.param      Wn=Lmin

*********NAND3**************
.subckt     NAND3     A        B       C        clk       Vout


Mp_clk    Vout      clk     VD      VD      pmos     l=Lmin      w='2*Wn'

Mn_clk    X1        clk     0       0       nmos     l=Lmin      w='4*Wn'
Mn_a      X2        A       X1      0       nmos     l=Lmin      w='4*Wn'
Mn_b      X3        B       X2      0       nmos     l=Lmin      w='4*Wn'
Mn_c      Vout      C       X3      0       nmos     l=Lmin      w='4*Wn'

Vsupply     VD      0       VDD
.ends       NAND3

*********Inverter************
.subckt     INV     Vin     Vout
M1      Vout        Vin     0       0       nmos     l=Lmin      w=Wn
M2      Vout        Vin     VD      VD      pmos     l=Lmin      w='2*Wn'
Vsupply     VD      0       VDD
.ends     INV

*********NAND3_Fixed*********
.subckt     NAND3_Fixed     A        B       C        clk       Vout

X1        Vout      Vout_b  INV
Mp_clk    Vout      clk     VD      VD      pmos     l=Lmin      w='2*Wn'
Mp_r      Vout      Vout_b  VD      VD      pmos     l=Lmin      w='2*Wn'

Mn_clk    X1        clk     0       0       nmos     l=Lmin      w='4*Wn'
Mn_a      X2        A       X1      0       nmos     l=Lmin      w='4*Wn'
Mn_b      X3        B       X2      0       nmos     l=Lmin      w='4*Wn'
Mn_c      Vout      C       X3      0       nmos     l=Lmin      w='4*Wn'

Vsupply     VD      0       VDD
.ends       NAND3_Fixed

*********SIMULATION**********
X1      A       B       C       clk     Vout    NAND3_Fixed

part a & b & c
.meas   tran    AVGpower_Low       AVG power   from=1.2ns  to=2ns
.meas   tran    AVGpower_Hight     AVG power   from=3.2ns  to=4ns
.meas   tran    AVGpower_Dynamic   AVG power   from=1ns  to=1.15ns
.meas   tran    Td_HL    trig   v(clk)     td=1ns  val='VDD/2'  cross=1 targ   v(Vout)   val='VDD/2'  cross=1
.vec 'part_NAND.txt'

*part d
*.vec 'part_NAND_d.txt'

.option post=2
.tran   10ps    20ns

.end
