
REGISTER datafu-1.2.1.jar;

DEFINE SetDifference datafu.pig.sets.SetDifference();


A = load 'input.txt' as (ip: chararray);
B = filter A by ip == '109.112.0.0';

G1 = group A all;
G2 = group B all;

P1 = foreach G1 generate A;
P2 = foreach G2 generate B;

CR = cross P1, P2;

O = foreach CR generate P1::A.ip as A, P2::B.ip as B;

Diff = foreach O {
    x = order A by ip;
    y = order B by ip;
    generate SetDifference(x, y) as C;
};

describe Diff;

C = foreach Diff generate flatten(C);
C = order C by $0;

G3 = group C all;

G1_Num = foreach G1 generate COUNT(A);
G2_Num = foreach G2 generate COUNT(B);
G3_Num = foreach G3 generate COUNT(C);

XXX = UNION G1_Num, G2_Num, G3_Num;

dump XXX;

--describe C;
--dump C;
