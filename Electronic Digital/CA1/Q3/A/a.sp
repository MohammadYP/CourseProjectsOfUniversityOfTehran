Q3- PartA CA1
*********Library*********
.lib    'mm018.l'   180nm
********Parts************
M1      V2      V2      0       0       NMOS        L=Lmin    w=Wn
M2      VDD     VDD     V2      0      NMOS        L=Lmin    w=Wn
M3      V4      V4      0       0       NMOS        L=Lmin    w=Wn
M4      V4      V4      VDD     VDD     PMOS        L=Lmin    w=Wp
Vs      VDD      0      Vsweep

.probe DC I(M1) V(Vs)
.probe DC I(M3) V(Vs)
*******PARAMETERS********
.param Lmin=180n
.param Wn=4u
.param Wp=8u
.param Vsweep=0
*******SIMULATION********
.OPTIONS post=2
.DC     Vsweep  0       6     0.01
.end