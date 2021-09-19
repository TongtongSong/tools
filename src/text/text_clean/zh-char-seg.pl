#!/usr/bin/perl -w
#  Description:
#    Segment the chinese string into a character sequence. Each word is seperated
#    by a space. Note that the word string should be segmented first by a Chinese
#    segmenter.
#
#  Usage:
#    zh-char-seg.pl -t [xml|plain] < input > output
#
##################################################################################

use utf8;
use Getopt::Long;

binmode STDIN,  ":utf8";
binmode STDOUT, ":utf8";
$|=1;

my $official = 0;
my $type = "plain";
GetOptions(
"t|type=s"  => \$type,
"o|official" => \$official,
"h|help"    => \$help
) or die &usage;

if($help)
{
    &usage;
    exit;
}

while(<>)
{
    chomp();
    my $line = $_;
    my $text = $_;
    my $id   = -1;
    if($type eq "xml")
    {
        if($line =~ /<seg id="(.*)">\s*(.*)\s*<\/seg>/)
        {
            $id   = $1;
            $text = $2;
        }else{
            print $line."\n";
            next;
        }
    }

    if($official){
        $text = chn_char_segmentation_official($text);
    }else{
        $text = chn_char_segmentation($text);
    }

    if($type eq "xml")
    {
        $line = "<seg id=\"$id\"> $text <\/seg>";
    }else{
        $line = $text;
    }

    print "$line\n";
}

## End of main
##################################################################################
# Segment a word string into char sequence. The english word will not be divided
# into char sequences.
sub chn_char_segmentation_official
{
    my $text     = $_[0];
    my @chars    = split //,$text;
    my $seg = join(" ",@chars);
    $seg =~ s/\s+/ /g;
    $seg =~ s/^\s*//;
    $seg =~ s/\s*$//;
    return $seg;
}



##################################################################################
# Segment a word string into char sequence. The english word will not be divided
# into char sequences.
sub chn_char_segmentation
{
    my $text     = $_[0];
    my @words    = split /\s+/,$text;
    my $seg = "";
    foreach my $word (@words)
    {
            my @chars = ();
            my $tmp_str = $word;
            if ($word =~ m/^\$(NUMBER|NUM|TERM|DATE|TIME|LOCATION|LOC|PERSON|PER|LITERAL)$/)
            {
                push(@chars, $word);
            }else{
                while($tmp_str){
                if($tmp_str =~ /^([^\x00-\x7f])/){ # any non-ascii word
                    push(@chars, $1);
                    $tmp_str =~ s/^.//;
                }elsif($tmp_str =~ /^([a-zA-Z]+)/){ # a english word
                    push(@chars, $1);
                    $tmp_str =~ s/^$1//;
                }elsif($tmp_str =~ /^(-?[\d,]+\.?\d+)/){ # a number
                    push(@chars, $1);
                    $tmp_str =~ s/^$1//;
                }elsif($tmp_str =~ /^(.)/){ # any char
                    push(@chars,$1);
                    $tmp_str =~ s/^.//;
                }
                }
            } 
            $seg .= " ".join(" ",@chars);
    }
    $seg =~ s/([、。"\'])/ $1 /g; # fix a few cases
    $seg =~ s/([^\d]) ,(\d+)/$1 , $2/g;
    $seg =~ s/\s+/ /g;
	$seg =~ s/^\s*//;
    $seg =~ s/\s*$//;

    return $seg;
}



##################################################################################
sub usage
{
print <<__USAGE__;
usage: $0 -type plain < input > output
   -t,type     type of the input ( xml or plain )
   -o,offical  use offical segmentation
   -h,help     print this help information
   
__USAGE__

}
