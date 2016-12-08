#!/bin/bash
#
# Bash Functions Library
#      - This contains common routines required by Bash scripts.
#
# @version 1.00
# ===========================================================
#  variables
# ===========================================================
short_hostname=`hostname -s`
domain_name="host.local"
puppetmaster_ip="172.22.6.139"

program_name="Please override program_name"
program_written="Please override program_written"
program_version="Please override program_version"

fully_automated=0

error_file="set_me_please.log"

debug=0
hide_output=">$error_file 2>&1"

# ===========================================================
#  functions
# ===========================================================
#
# Logs a message.
#
# log()
# IN: String to log
# OUT: nothing
#
function log
{
    echo "${@}" >&2
    echo "${@}" >&2 >> $error_file
}

#
# Trims leading and trailing white space.
#
# log()
# IN: String to trim
# OUT: Trimed string
#
function trim
{
   value=${1}
   value=${value%% }
   value=${value## }
   echo ${value}
}

#
# Logs an "error" message and exits.
#
# panic()
# IN: String to log
# OUT: nothing
#
function panic
{
    log "PANIC: ${@}"
    exit 1
}

#
# Determines if the user is currently logged in is 'root'.
#
# check_root()
# IN: nothing
# OUT: nothing
#
function check_root
{
    # make sure we are root
    if [ ${EUID} -ne 0 ]; then
       panic "This installer must be run as root!"
    fi
}

#
# Prints the standard program header
#
# print_header()
# IN: messages to include in header
# OUT: nothing
#
function print_header 
{
    real_program_written="Written by:\n  $program_written"

    # print header
    echo -e "$program_name $program_version\n - Running on ($short_hostname)\n$real_program_written"
    if [ ! -z $1 ]; then
        echo -e ""
        echo -e "$1"
    fi

    echo -e ""
    echo -e "================================================================================";
    echo -e ""
}

#
# Outputs a debug message depending on the debug level.
#
# print_debug
# IN: Debug Message and Debug Level the message gets printed at
# OUT: nothing
#
function print_debug
{
    if [ -z $0 ]; then echo "$0: called print_debug with no message!"; return; fi
    if [ -z $1 ]; then echo "$0: called print_debug with no debug level!"; return; fi;

    if [ $debug -ge $1 ]; then
        echo -e $0
    fi
}
