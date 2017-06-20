#!/bin/bash
#
# Name: test-bucket-1
#
# Purpose:
#    Performs the test-bucket number 1 for Product X.
#    (Actually, this is a sample shell script, which invokes some
#     system commands to illustrate how to construct a Bash script) 
#
# Notes:
# 1) The environment variable TEST_VAR must be set (as an example).
# 2) To invoke this shell script and redirect standard output and
#    standard error to a file (such as test-bucket-1.out) do the
#    following (the -s flag is "silent mode" to avoid prompts to the
#    user):
#
#    ./test-bucket-1  -s  2>&1  | tee test-bucket-1.out
#
# Return codes:
#  0 = All commands were successful
#  1 = At least one command failed, see the output file and search
#      for the keyword "ERROR".
#
######################################################################.#########

# ----------------------------
# Subroutine to echo the usage
# ----------------------------

usage()
{
 echo "USAGE: $CALLER [-h] [-s]"
 echo "WHERE: -h = help       "
 echo "       -s = silent (no prompts)"
 echo "PREREQUISITES:"
 echo "* The environment variable TEST_VAR must be set, such as: "
 echo "   export TEST_VAR=1"
 echo "$CALLER: exiting now with rc=1."
 exit 1
}

# ----------------------------------
# Subroutine to terminate abnormally
# ----------------------------------

terminate()
{
 echo "The execution of $CALLER was not successful."
 echo "$CALLER terminated, exiting now with rc=1."
 dateTest=`date`
 echo "End of testing at: $dateTest"
 echo ""
 exit 1
}

# ---------------------------------------------------------------------------
# The commands are called in a subroutine so that return code can be
# checked for possible errors.
# ---------------------------------------------------------------------------

ListFile()
{
 echo "ls -al $1"
 ls -al $1
 if [ $? -ne 0 ]
 then
  echo "ERROR found in: ls -al $1"
  let "errorCounter = errorCounter + 1"
 fi
}

################################################################################

# --------------------------------------------
# Main routine for performing the test bucket
# --------------------------------------------

CALLER=`basename $0`                    # The Caller name
SILENT="no"                             # User wants prompts
let "errorCounter = 0"

# ----------------------------------
# Handle keyword parameters (flags).
# ----------------------------------

# For more sophisticated usage of getopt in Linux, see
# the samples file: /usr/lib/getopt/parse.bash
TEMP=`getopt hs $*`
if [ $? != 0 ]
then
 echo "$CALLER: Unknown flag(s)"
 usage
fi

# Note the quotes around `$TEMP': they are essential! 
eval set -- "$TEMP"

while true                   
 do
  case "$1" in
   -h) usage "HELP";            shift;; # Help requested
   -s) SILENT="yes";            shift;; # Prompt is not needed
   --) shift ; break ;; 
   *) echo "Internal error!" ; exit 1 ;;
  esac
 done

# ------------------------------------------------
# The following environment variables must be set
# ------------------------------------------------

[ -z "$TEST_VAR" ] && { echo "The environment variable TEST_VAR is not set."; usage; }

# --------------------------------------------------
# Everything seems to be OK, prompt for comfirmation
# --------------------------------------------------

if [ "$SILENT" = "yes" ]
then
 RESPONSE="y"
else
 echo "The $CALLER will be performed."
 echo "Do you wish to proceed [y or n]? "
 read RESPONSE                         # Wait for response
 [ -z "$RESPONSE" ] && RESPONSE="n"
fi

case "$RESPONSE" in
 [yY]|[yY][eE]|[yY][eE][sS])
 ;;
 *)
  echo "$CALLER terminated with rc=1."
  exit 1
 ;;
esac

# --------------------------------------------------
echo "Subject: Product X, FVT testing"
dateTest=`date`
echo "Begin testing at: $dateTest"
echo ""
echo "Testcase: $CALLER"
echo ""
# --------------------------------------------------

# --------------------------------------------------
echo ""
echo "Listing files..."
# --------------------------------------------------

# The following file should be listed:
ListFile   $HOME/.profile

# The following file should NOT be listed:
ListFile   test-1

# --------------------------------------------------
echo ""
echo "Creating file 1"
# --------------------------------------------------

echo "This is file: test1" > test1
if [ $? -ne 0 ]
then
 echo "ERROR found in: creating file test1"
 let "errorCounter = errorCounter + 1"
fi

# --------------
# Exit
# --------------
if [ $errorCounter -ne 0 ]
then
 echo ""
 echo "*** $errorCounter ERRORS found during the execution of this test case. ***"
 terminate
else
 echo ""
 echo "*** Yeah! No errors were found during the execution of this test case. Yeah! ***"
fi

echo ""
echo "$CALLER complete."
echo ""
dateTest=`date`
echo "End of testing at: $dateTest"
echo ""

exit 0

# end of file
