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

C1      Q       0       1f
Vsupply     VD      0       VDD

.ends       TG

*********CLK_bar************
.subckt     CLK_bar     clk     clk_b       
X1      clk     w1       INV
X2      w1      w2       INV
X3      w2      w3       INV
X4      w3      w4       INV
X5      w4      w5       INV
X6      w5      w6       INV
X7      w6      w7       INV
X8      w7      w8       INV
X9      w8      w9       INV
X10     w9      w10      INV
X11     w10     w11      INV

X12     w11     w12      INV
X13     w12     w13      INV
X14     w13     w14      INV
X15     w14     w15      INV
X16     w15     w16      INV
X17     w16     w17      INV
X18     w17     w18      INV
X19     w18     w19      INV
X20     w19     w20      INV
X21     w20     clk_b    INV

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
*X0      CLK     CLK_b       CLK_bar

X1      D       W1      CLK       CLK_b     TG
X2      W1      W2      INV

X3      W2      W3      CLK_b     CLK       TG
X4      W3      Q       INV

V_clk       CLK     0       PWL     0n 0,2n 0,'2n+t' VDD,4n VDD,'4n+t' 0,6n 0, '6n+t' VDD,8n VDD,'8n+t' 0,10n 0, '10n+t' VDD,12n VDD, '12+t' 0
V_clk_b     CLK_b   0       PWL     0n VDD,2.7n VDD,'2.7n+t' 0,4.7n 0,'4.7n+t' VDD,6.7n VDD, '6.7n+t' 0,8.7n 0,'8.7n+t' VDD,10.7n VDD, '10.7n+t' 0,12.7n 0, '12.7+t' VDD
V_input     D       0       PWL     0n 0,5n 0,'5n+t' VDD,7.9n VDD,'7.9n+t' 0


*.meas   tran    Td_Setup_time    trig   v(D)    td=2ns   val='VDD/2'    cross=1 targ   v(W1)   val='VDD/2'     cross=1

*.vec 'VEC_FILE.txt'
.option post=2
.tran   1ps    16ns

.end
