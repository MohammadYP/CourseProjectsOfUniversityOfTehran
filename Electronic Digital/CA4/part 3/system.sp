system

*********Library*************
.lib    '32nm_bulk.pm'    tt

**** parameters ****
.param      VDD=1
.param      Lmin=32n
.param      Wn=Lmin
.param      t=2p

*********Inverter************
.subckt     INV     Vin     Vout
M1      Vout        Vin     0       0       nmos     l=Lmin      w=Wn
M2      Vout        Vin     VD      VD      pmos     l=Lmin      w='2*Wn'
Vsupply     VD      0       VDD
.ends     INV

*********transmission********
.subckt     TG      D       Q       CLK     CLK_b

M1      D       CLK_b     Q       0       nmos     l=Lmin      w=Wn
M2      Q       CLK       D       VD      pmos     l=Lmin      w='2*Wn'

C1      Q       0       0.01f
Vsupply     VD      0       VDD

.ends       TG

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

*********CLK_bar************
.subckt     CLK_bar     clk     clk_b       
X1      clk     clk_b       INV
.ends       CLK_bar

*********register************
.subckt     register      D       Q       CLK

X0      CLK     CLK_b       CLK_bar

X1      D       W1      CLK       CLK_b     TG
X2      W1      W2      INV
X3      W2      W3      CLK_b   CLK          TG
X4      W3      Q       INV


.ends       register

*********SIMULATION**********

X0      A_in    A_out   CLK     register
X1      B_in    B_out   CLK     register
X2      C_in    C_out   CLK     register

X3      A_out   B_out   C_out   V_in        AOI21

X4      V_in    V_out   CLK     register



V_clk   CLK     0       PULSE   0       VDD     0     10f       10f       10p     20p

V_A     A_in       0       PWL     0p       0, 50p     0 , '50p+t'      VDD , 400p       VDD, '400p+t'        0                          
V_B     B_in       0       PWL     0p       0, 50p     0 , '50p+t'      VDD , 400p       VDD, '400p+t'        0                          
V_C     C_in       0       PWL     0p       0, 50p     0 , '50p+t'      VDD , 400p       VDD, '400p+t'        0                          
*.meas   tran    Td_Setup_time    trig   v(D)    td=2ns   val='VDD/2'    cross=1 targ   v(W1)   val='VDD/2'     cross=1

*.vec 'VEC_FILE.txt'
.option post=2
.tran   1ps    1.5ns

.end
