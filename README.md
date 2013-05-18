ConfidenceWeighted
========================

confidence weighted classifier
(http://www.cs.jhu.edu/~mdredze/publications/icml_variance.pdf)
(http://icml.cc/2012/papers/86.pdf)

[USAGE]
perl test.pl [confidence parameter] [mode] [mode parameter] [dimension of features]

[MODE]
available modes are below.
cw: confidence weighted. mode parameter is variance.
scw: soft confidence weighted (proposition 1). mode parameter is aggressiveness.

[EXAMPLE]
$$ perl test.pl 0.7 1 3 cw < colors.csv

