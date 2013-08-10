package SoftConfidenceWeighted;
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
                   defined $args{aggressiveness} and 0 < $args{aggressiveness} and
                   defined $args{dimension} and 0 <  $args{dimension});

    $self->{dimension}      = $args{dimension};
    $self->{aggressiveness} = $args{aggressiveness};
    $self->{phi}            = $self->_probit($args{confidence});
    return unless ($self->{phi});

    $self->{psi}   = 1 + $self->{phi} * $self->{phi} / 2;
    $self->{zeta}  = 1 + $self->{phi} * $self->{phi};
    $self->{mu}    = [];
    $self->{sigma} = [];
    for my $i (0 .. ($self->{dimension} - 1)) {
        push(@{$self->{mu}}, 0);
        my $row = [];
        for my $j (0 .. ($self->{dimension} - 1)) {
            push(@$row, ($i == $j) ? 1 : 0);
        }
        push(@{$self->{sigma}}, $row);
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

    my $sigma_x           = $self->_get_sigma_x($args{data});
    my ($mean, $variance) = $self->_get_margin_mean_and_variance(
                                $args{label}, $args{data}, $sigma_x);
    return 1 if (($self->{phi} * sqrt($variance)) <= $mean);

    my ($alpha, $beta) = $self->_get_alpha_and_beta($mean, $variance);
    next unless ($alpha and $beta);

    for my $i (0 .. ($self->{dimension} - 1)) {
        $self->{mu}[$i] +=
            $alpha * $args{label} * $sigma_x->[$i];
        for my $j (0 .. ($self->{dimension} - 1)) {
            $self->{sigma}[$i][$j] -=
                $beta * $sigma_x->[$i] * $sigma_x->[$j];
        }
    }
    return 1;
}

sub _get_sigma_x {
    my ($self, $data) = @_;

    my $sigma_x = [];
    for my $i (0 .. ($self->{dimension} - 1)) {
        my $num = 0;
        for my $j (0 .. ($self->{dimension} - 1)) {
            $num += $self->{sigma}[$i][$j] * $data->[$j];
        }
        push(@$sigma_x, $num);
    }
    return $sigma_x;
}

sub _get_margin_mean_and_variance {
    my ($self, $label, $data, $sigma_x) = @_;

    my $mean     = 0;
    my $variance = 0;
    for my $i (0 .. ($self->{dimension} - 1)) {
        $mean     += $data->[$i] * $self->{mu}[$i];
        $variance += $data->[$i] * $sigma_x->[$i];
    }
    $mean *= $label;
    return ($mean, $variance);
}

sub _get_alpha_and_beta {
    my ($self, $mean, $variance) = @_;

    my $alpha_den = $variance * $self->{zeta};
    return unless ($alpha_den);

    my $term1 = $mean * $self->{phi} / 2;
    my $alpha = (-1 * $mean * $self->{psi} +
                 $self->{phi} *
                 sqrt($term1 * $term1 + $alpha_den)
                ) / $alpha_den;

    return (0, 0) if ($alpha <= 0);
    $alpha = ($alpha < $self->{aggressiveness}) ? $alpha : $self->{aggressiveness};


    my $beta_num = $alpha * $self->{phi};
    my $term2    = $variance * $beta_num;
    my $beta_den = $term2 +
                   (-1 * $term2 + sqrt($term2 * $term2 + 4 * $variance)) / 2;
    return unless ($beta_den);
    my $beta = $beta_num / $beta_den;

    return ($alpha, $beta);
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

