#!/bin/env perl
#
while(<STDIN>){
    chomp();
    s/ ' (s|m|t|re|ll|d|re|ve) /'$1 /g;
    s/ ' (s|m|t|re|ll|d|re|ve)$/'$1/g;
    s/ '(s|m|t|re|ll|d|re|ve) /'$1 /g;
    s/ '(s|m|t|re|ll|d|re|ve)$/'$1/g;
    s/ (Mrs|mr|mrs|dr) \. / $1\. /g;
    s/ (Mrs|mr|mrs|dr) \.$/ $1\./g;
    s/^(Mrs|mr|mrs|dr) \. /$1\. /g;
    print "$_\n";
}

