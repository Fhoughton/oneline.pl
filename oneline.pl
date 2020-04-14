use warnings;
use strict;

sub menu {
    my $args    = shift;
    my $title   = $args->{title};
    my $choices = $args->{choices};

    while (1) {
        print "--------------------\n";
        print "$title\n";
        print "--------------------\n";
        for ( my $i = 1 ; $i <= scalar(@$choices) ; $i++ ) {
            my $itemHeading = $choices->[ $i - 1 ][0];
            print "$i. $itemHeading\n";
        }
        print "\n?: ";
        my $i = <STDIN>;
        chomp $i;
        if ( $i && $i =~ m/[0-9]+/ && $i <= scalar(@$choices) ) {
            &{ $choices->[ $i - 1 ][1] }();
        }
        else {
            print "\nInvalid input.\n\n";
        }
    }
}

sub replacephrase {
    print "File to replace in: ";
    my $fname = <STDIN>;
    chomp $fname;

    print "Phrase to replace: ";
    my $before = <STDIN>;
    chomp $before;

    print "Value to replace phrase: ";
    my $after = <STDIN>;
    chomp $after;

    rename( $fname, $fname . '.bak' );
    open( IN,  '<' . $fname . '.bak' ) or die $!;
    open( OUT, '>' . $fname )          or die $!;
    while (<IN>) {
        $_ =~ s/$before/$after/g;
        print OUT $_;
    }
    close(IN);
    close(OUT);
}

sub countfile {
    print "File to count contents of: ";
    my $fname = <STDIN>;
    chomp $fname;

    open( FILE, "<$fname" ) or die "Could not open file: $!";

    my ( $lines, $words, $chars ) = ( 0, 0, 0 );

    while (<FILE>) {
        $lines++;
        $chars += length($_);
        $words += scalar( split( /\s+/, $_ ) );
    }

    print("lines=$lines words=$words chars=$chars\n");
}

sub countwords {
    my %count;
    print "File to count in:";
    my $file = <STDIN>;
    chomp $file;
    open my $fh, '<', $file or die "Could not open '$file' $!";
    while ( my $line = <$fh> ) {
        chomp $line;
        foreach my $str ( split /\s+/, $line ) {
            $count{$str}++;
        }
    }

    foreach my $str ( sort keys %count ) {
        printf "%-31s %s\n", $str, $count{$str};
    }
}

sub randomstring {
    print "Enter string length: ";
    my $strlen = <STDIN>;
    chomp $strlen;

    my $password;
    my @characters =
      ( ( 'A' .. 'Z' ), ( 'a' .. 'z' ), ( '!', '@', '%', '^' ), ( 0 .. 9 ) );
    my $size = $#characters + 1;
    for ( 1 .. $strlen ) {
        $password .= $characters[ int( rand($size) ) ];
    }
    print "$password\n";
}

my $menus = {};
$menus = {
    "1" => {
        "title"   => "oneline.pl",
        "choices" => [

            #perl -pi -e 's/you/me/g' file
            [ "Replace a phrase in a file", sub { replacephrase; } ],

            #perl -ne 'print "$. $_"
            [
                "Count lines, words and characters in a file",
                sub { countfile; }
            ],

            #perl -le 'print map { (a..z)[rand 26] } 1..8'
            [ "Generate random string", sub { randomstring; } ],

            #can't find a suitable one-liner, code comes from https://perlmaven.com/count-words-in-text-using-perl
            [ "Count words within a file", sub { countwords; } ],

            [ "Exit", sub { exit; } ],
        ],
    }
};

menu( $menus->{1} );
