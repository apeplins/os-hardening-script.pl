#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;

print <<"START";
Programmer: Alex Peplinski
Course: IA 462
Lab# Mod5
Date Created 10/16/2020
START

print "hello";
my $base = '/etc';
my $file = 'issue.net';
my $usr_dir = '/etc';
system('pwd');
if(defined $usr_dir && -e $usr_dir){
	chdir "$usr_dir" or die "cannot change directory";
}
system('pwd');
open my $fh, '>>',$file or die "Cant append a file:$!\n";
#if (!open my $fh,'>>',$file){
#	die("This file did not open:$!\n");
#}

print $fh "*******************************\n This is a private network. \n* You must be authorized to use these recourses. Unauthorized or criminal use \n* is prohibited. By your use of these recourses, you agree to abide by\n* \"Responsible Use of Information Resources,\" in addtion to all \n* relevant state and federal laws.\n****************";

close $fh;

$usr_dir = '/etc/ssh/';

if(defined $usr_dir && -e $usr_dir){
	chdir "$usr_dir" or die "cannot change directory";
}

$file = 'sshd_config';
open FH, '<',$file or die "Cant open a file:$!\n";

#i think m[ is so i cane use the "[" and ]m is for multi line and ]x is for whitespace and comments

foreach my $line (<FH>) {
	if($line =~ m[#Banner none]m){
    print $line;
	}
}
close FH;


print "changing sshd_cconfig line to:\n";
open IN, '<',$file or die "Cant open a file:$!\n";
open OUT,'>',"new".$file or die "Cant write a file:$!\n";

foreach my $line (<IN>) {

	if($line =~ s/#Banner none/Banner \/etc\/issue.net/g){
    	print $line, "\n";
	}
	print OUT $line;
}
close IN;
close OUT;
print "Replacing sshd_config with Banner update\n";
system('mv', 'newsshd_config', 'sshd_config');
print "installing epel-release\n";
system('yum', '-y','install', 'epel-release');
print "installing clamav\n";
system('yum', '-y', 'install', 'clamav-server', 'clamav-data', 'clamav-update', 'clamav-filesystem', 'clamav','clamav-scanner-systemd', 'clamav-devel', 'clamav-lib', 'clamav-server-systemd', 'clamav-db');
print "configuring daily scans";

$usr_dir = '/etc/cron.daily/';

if(defined $usr_dir && -e $usr_dir){
	chdir "$usr_dir" or die "cannot change directory";
}
system('pwd');
$file = 'manual_clamscan';

open OUT, '>', $file or die "Cant write a file:$!\n";
print OUT '#!/bin/bash',"\n", 'SCAN_DIR="/home"', "\n";
print OUT 'LOG_FILE="/var/log/clamav/manual_clamscan.log"',"\n";
print OUT '/usr/bin/clamscan -i -r $SCAN_DIR >> $LOG_FILE';

close OUT;
system('chmod', '+x', 'manual_clamscan');
system('sudo', 'freshclam');
system('sudo', 'clamscan', '-r', '--bell', '-i', '/');
