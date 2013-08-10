package ConfidenceWeighted;
use strict;
use warnings;
use Math::Trig qw/pi/;
use constant {
    ERF_ORDER => 30,
};

sub new {
    my ($class, %args) = @_;
    my $self = \%args;
    return bless($self, $class);
}

sub initialize {
    my ($self, %args) = @_;
    return unless (defined $args{confidence} and
                   0 <= $args{confidence} and $args{confidence} <= 1 and
                   defined $args{variance} and 0 <  $args{variance} and
                   defined $args{dimension} and 0 <  $args{dimension});

    $self->{dimension} = $args{dimension};
    $self->{phi}       = $self->_probit($args{confidence});
    return unless ($self->{phi});
    $self->{mu}    = [];
    $self->{sigma} = [];
    for (1 .. $self->{dimension}) {
        push(@{$self->{mu}},    0);
        push(@{$self->{sigma}}, $args{variance});
    }
    return 1;
}

sub classify {
    my ($self, %args) = @_;
    return unless (defined $args{data} and @{$args{data}} == $self->{dimension});

    my $margin = 0;
    for my $i (0 .. ($self->{dimension} - 1)) {
        $margin += $args{data}[$i] * $self->{mu}[$i];
    }
    return (($margin > 0) ? 1 : -1);
}

sub update {
    my ($self, %args) = @_;
    return unless (defined $args{data}  and @{$args{data}} == $self->{dimension} and
                   defined $args{label} and ($args{label} == -1 or $args{label} == 1));

    my $alpha = $self->_get_alpha(%args);
    return 1 unless ($alpha);
    for my $i (0 .. ($self->{dimension} - 1)) {
        $self->{mu}[$i] += $alpha * $args{label} *
                           $self->{sigma}[$i] * $args{data}[$i];
        next unless ($self->{sigma}[$i]);
        my $sigma_inv = 1 / $self->{sigma}[$i] +
                        2 * $alpha * $self->{phi} * $args{data}[$i];
        next unless ($sigma_inv);
        $self->{sigma}[$i] = 1 / $sigma_inv;
    }
    return 1;
}

sub _get_alpha {
    my ($self, %args) = @_;

    my $mean     = 0;
    my $variance = 0;
    for my $i (0 .. ($self->{dimension} - 1)) {
        $mean     += $args{data}[$i] * $self->{mu}[$i];
        $variance += $args{data}[$i] * $args{data}[$i] * $self->{sigma}[$i];
    }
    $mean *= $args{label};

    my $term      = 1 + 2 * $self->{phi} * $mean;
    my $gamma_num = -1 * $term +
                    sqrt($term * $term -
                         8 * $self->{phi} *
                         ($mean - $self->{phi} * $variance));
    my $gamma_den = 4 * $self->{phi} * $variance;
    return unless ($gamma_den);

    my $gamma = $gamma_num / $gamma_den;
    return (($gamma > 0) ? $gamma : 0);
}

sub _probit {
    my ($self, $p) = @_;

    return sqrt(2) * $self->_erf_inv(2 * $p - 1);
}

sub _erf_inv {
    my ($self, $z) = @_;

    my $value  = 1;
    my $term   = 1;
    my @c_memo = (1);
    for my $n (1 .. ERF_ORDER) {
        $term  *= (pi() * $z * $z / 4);
        my $c = 0;
        for my $m (0 .. ($n - 1)) {
            $c += ($c_memo[$m] * $c_memo[$n - 1 - $m] /
                   ($m + 1) / (2 * $m + 1));
        }
        push(@c_memo, $c);
        $value += ($c * $term / (2 * $n + 1));
    }
    return (sqrt(pi()) * $z * $value / 2);
}

1;

__END__

