register

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

C1      Q       0       10f
Vsupply     VD      0       VDD

.ends       TG

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
X0      CLK     CLK_b       CLK_bar

X1      D       W1      CLK       CLK_b     TG
X2      W1      W2      INV

X3      W2      W3      CLK_b   CLK          TG
X4      W3      Q       INV

V_clk       CLK     0       PWL     0n 0,2n 0,'2n+t' VDD,4n VDD,'4n+t' 0,6n 0, '6n+t' VDD,8n VDD,'8n+t' 0,10n 0, '10n+t' VDD,12n VDD, '12+t' 0
V_input     D       0       PWL     0n 0,5n 0,'5n+t' VDD,6n VDD,'6n+t' 0

.meas   tran    Td_Setup_time    trig   v(D)    td=2ns   val='VDD/2'    cross=1 targ   v(W1)   val='VDD/2'     cross=1

.meas   tran    Td_CLK-Q         trig   v(CLK)  td=6ns   val='VDD/2'    cross=1 targ   v(Q)    val='VDD/2'     cross=1

.meas   tran    Td_rise_time     trig   v(Q)    td=6ns   val='VDD/10'   cross=1 targ   v(Q)    val='VDD*9/10'  cross=1

.meas   tran    Td_fall_time     trig   v(Q)    td=10ns  val='VDD*9/10' cross=1 targ   v(Q)    val='VDD/10'    cross=1

*.vec 'VEC_FILE.txt'
.option post=2
.tran   1ps    16ns

.end
