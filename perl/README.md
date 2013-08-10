perl
========================

[USAGE]
perl test.pl [confidence parameter] [mode] [mode parameter] [dimension of features]

[MODE]
available modes are below.
cw: confidence weighted. mode parameter is variance.
scw: soft confidence weighted (proposition 1). mode parameter is aggressiveness.
fscw: scw, but sigma has only diagonal elements.

[EXAMPLE]
$$ perl test.pl 0.7 cw 1 3 < colors.csv

