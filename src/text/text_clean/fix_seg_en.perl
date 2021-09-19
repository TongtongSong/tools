#!/bin/env perl
#
while(<STDIN>){
    chomp();
    #s/\./ \. /g;
    #s/ ' (s|m|t|re|ll|d|re|ve) /'$1 /g;
    #s/ ' (s|m|t|re|ll|d|re|ve)$/'$1/g;
    #s/ '(s|m|t|re|ll|d|re|ve) /'$1 /g;
    #s/ '(s|m|t|re|ll|d|re|ve)$/'$1/g;
    #s/(s|m|t|re|ll|d|re|ve)$ '/$1'/g;
    #s/ (Mrs|mr|mrs|dr) \. / $1\. /g;
    #s/ (Mrs|mr|mrs|dr) \.$/ $1\./g;
    #s/^(Mrs|mr|mrs|dr) \. /$1\. /g;
    #s/ u \. s \. a \. / u\.s\.a\. /g;
    #s/ a \. m \. / a\.m\. /g;
    #s/ p \. m \. / p\.m\. /g;
    #s/ u \. s \. / u\.s\. /g;
    #s/ no \. / no\. /g;
    #s/ d \. c \. / d\.c\. /g;
    #s/ e \. g \. / e\.g\. /g;
    #s/ i \. e \. / i\.e\. /g;
    s/([0-9])([a-z])/$1 $2/g;
    s/([a-z])([0-9])/$1 $2/g;
    s/ co  \. / co\. /g;
    s/ u \. s  / u\.s /g;
    s/ u \. k \. / u\.k\. /g;
    s/ e \. g / e\.g /g;
    s/ ph \. / ph\. /g;
    s/([0-9]) \. ([0-9])/$1\.$2/g;
    print "$_\n";
}

