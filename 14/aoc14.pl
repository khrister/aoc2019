#!/bin/env perl
# Copyright Christer Boräng (mort@chalmers.se) 2019

# Always use strict and warnings
use strict;
use warnings;
use Data::Dumper;

# Other modules

# Global variables


# 4 mat_a needs 10 mat_b, 12 mat_c, 4 mat_d ->
# %goods = ( mat_a => [ 4, mat_b, 10, mat_c, 12, mat_d, 4 ] )
my %goods = ();

my $ore_used = 0;

my %spares = ();


{
    my $fh;
    my $file = shift @ARGV;
    open($fh, '<', $file)
        or die("Could not open $file: ");
    while (my $line = <$fh>)
    {
        parseline($line);
    }
    close $fh;
}

produce("FUEL", 1);
print "$ore_used\n";

sub produce
{
    my $result = 0;
    my $mat = shift;
    my $amount = shift;

    if (!$goods{$mat})
    {
        print "No material $mat found\n";
        exit;
    }
    my @arr = @{$goods{$mat}};
    my $made = shift @arr;

    # How many do we need compares to how many we make per production
    my $multi = int($amount / $made);
    my $remain = $amount % $made;
    if ($remain)
    {
        $multi++;
        if ($spares{$mat})
        {
            $spares{$mat} += ($made - $remain);
        }
        else
        {
            $spares{$mat} = ($made - $remain);
        }
    }

    # Make the sub parts
    while (@arr)
    {
        my $nmat = shift @arr;
        my $namount = shift @arr;
        my $spare = 0;
        # If it's ORE
        if ($nmat eq "ORE")
        {
            $ore_used += $namount * $multi;
            return $namount;
        }

        if ($spares{$nmat})
        {
            if ($spares{$nmat} >= $namount * $multi)
            {
                $spares{$nmat} -= $namount * $multi;
                next;
            }
            $spare = $spares{$nmat};
            $spares{$nmat} = 0;
        }
        my $tmp = produce($nmat, $namount * $multi - $spare);
    }
}

sub parseline
{
    my $line = shift;
    chomp $line;
    my @lneeds = ();

    my ($a, $b) = split(/ => /, $line);
    my ($amount, $mat) = split(/ /, $b);
    $lneeds[0] = $amount;

    do
    {
        my $namount;
        my $n;
        ($namount, $n, $a) = split(/,? /, $a, 3);
        push(@lneeds, ($n, $namount));
    } while ($a and $a =~ / /);

    $goods{$mat} = \@lneeds;
}

# Debug printouts
sub D
{
    my $str = shift;
    print Dumper($str);
}


__END__

=head1 NAME

<application name> - one line description


=head1 VERSION

This documentation refers to <application name> version 0.0.1


=head1 USAGE


=head1 REQUIRED ARGUMENTS


=head1 OPTIONS


=head1 DESCRIPTION


=head1 DIAGNOSTICS


=head1 EXIT STATUS

=head1 CONFIGURATION


=head1 DEPENDENCIES
=head1 INCOMPATIBILITIES
=head1 BUGS AND LIMITATIONS
=head1 AUTHOR

Written by Christer Boräng (mort@chalmers.se)


=head1 LICENSE AND COPYRIGHT

Copyright Christer Boräng 2019

=cut