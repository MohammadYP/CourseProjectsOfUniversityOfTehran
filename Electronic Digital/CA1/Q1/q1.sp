1- NMOS Q1 CA1
*********Library*********
.lib    'mm018.l'   180nm
********NMOS*************
M1      Vd      Vg_node      0       0       NMOS        L=Lmin    w=Wn
Vs      Vd      0       0
Vg      Vg_node    0       0.4

.probe DC I(M1) V(Vs)
*******PARAMETERS********
.param Lmin=180n
.param Wn=4u
*******SIMULATION********
.DC Vs 0 1.5 0.01
.alter 
Vg      Vg_node    0       0.4
.OPTIONS post=2 nomod file='sim2.sw0'


.alter 
Vg      Vg_node    0       0.6
.OPTIONS post=2 nomod file='sim2.sw1'

.alter 
Vg      Vg_node    0       0.8
.OPTIONS post=2 nomod file='sim2.sw2'

.alter 
Vg      Vg_node    0       1
.OPTIONS post=2 nomod file='sim2.sw3'



.end