#!/bin/bash

#
# Used with incrontab:
#   install incrontab:
#     $ sudo apt install incrontab
#   configure incrontab:
#     $ sudo gedit /etc/incron.allow
#     and insert
#       root
#       ale
#     $ incrontab -e
#     and insert
#       /home/ale/configs_bck IN_MODIFY bash /home/ale/configs_bck/configs_auto_backup.sh
#

TMPDIR=$(mktemp -d)
trap "rm -rf ${TMPDIR}" EXIT
SCRIPTNAME="$(basename "$0" .sh)"
TMP_ERROR="/${TMPDIR}/err_${SCRIPTNAME}"

function check_command() {
  #
  # Function usage:
	# some_command >${TMP_ERROR} 2>&1
  # check_command $?
  #

   if [ $1 -ne 0 ]; then
    do_log error "$(cat ${TMP_ERROR} 2>/dev/null)"
    rm -f ${TMP_ERROR}
    sync
    exit $1
  fi
  rm -f ${TMP_ERROR}
}

BRANCH="automatic"

git checkout $BRANCH >${TMP_ERROR} 2>&1
check_command $? 2>&1

git add --all >${TMP_ERROR} 2>&1
check_command $?

git commit -am "Automatic commit." >${TMP_ERROR} 2>&1
check_command $?

git push origin $BRANCH >${TMP_ERROR} 2>&1
check_command $?

exit 0
