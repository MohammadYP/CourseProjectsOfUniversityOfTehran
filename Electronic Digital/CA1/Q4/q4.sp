Q4- INVERTER
*********Library*********
.lib    'mm018.l'   180nm
********Parts************
M1      Vout      Vin      0       0       NMOS        L=L1   w=W1
M2      Vout      Vin      VDD     VDD     PMOS        L=L2   w=W2
Vs      VDD       0        1.8
Vinput      Vin       0       0.8
*******PARAMETERS********
.param L1=0.18u
.param W1=0.6u
.param L2=0.18u
.param W2=0.1u
*******SIMULATION********
.DC        W2      0.1u        3u     10n
.OPTIONS post = 2
.end