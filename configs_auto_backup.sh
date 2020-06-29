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
#     /home/ale/configs_bck IN_MODIFY bash -c '/home/ale/configs_bck/configs_auto_backup.sh' ale
#



function check_command() {
  #
  # Function usage:
	# some_command >${TMP_ERROR} 2>&1
  # check_command $?
  #

   if [ $1 -ne 0 ]; then
    do_log error "$(cat ${TMP_ERROR} 2>/dev/null)"
    cp -f ${TMP_ERROR} /home/ale/Desktop
    rm -f ${TMP_ERROR}

    do_log bad_exit "EXIT"
    sync
    exit $1
  fi
  rm -f ${TMP_ERROR}
}

function do_logsetup() {
  #
  # Call in int function if you wanto to write logs into ${LOGFILE}
  #

  LOG_TMP=$(tail -n $RETAIN_NUM_LINES $LOGFILE 2>/dev/null) \
          && echo "${LOG_TMP}" > $LOGFILE
  exec > >(tee -a $LOGFILE)
  exec 2>&1
}

function do_log() {
  #
  # Function usage:
  # do_log debug "Waiting for all do_send_manifest_pids"
  #

  local arg="$2"
  COLUMNS=90
  case $1 in
    info)
      echo -e "[$(date "+%H:%M:%S:%3N")]:    ${NORMAL_COLOR}  [Info] ${NORMAL_COLOR} $arg"
      ;;
    success)
      echo -e "[$(date "+%H:%M:%S:%3N")]: ${GREEN__COLOR}  [Success] ${NORMAL_COLOR} $arg"
      ;;
    error)
      echo -e "[$(date "+%H:%M:%S:%3N")]:   ${RED____COLOR}  [Error] ${NORMAL_COLOR} $arg"
      ;;
    warning)
      echo -e "[$(date "+%H:%M:%S:%3N")]: ${YELLOW_COLOR}  [Warning] ${NORMAL_COLOR} $arg"
      ;;
    curlwarn)
      echo -e "[$(date "+%H:%M:%S:%3N")]: ${PURPLE_COLOR} [CurlWarn] ${NORMAL_COLOR} $arg"
      ;;
    title)
      echo -ne "${CYAN___COLOR}"
      printf "%*s\n" $COLUMNS | tr ' ' '='
      printf "[$(date "+%H:%M:%S:%3N")]:     %s\n" "$arg"
      printf "%*s\n" $COLUMNS | tr ' ' '='
      echo -ne "${NORMAL_COLOR}"
      ;;
    bad_exit)
      echo -ne "${RED____COLOR}"
      printf "%*s\n" $COLUMNS | tr ' ' '='
      printf "[$(date "+%H:%M:%S:%3N")]:     %s\n" "$arg"
      printf "%*s\n" $COLUMNS | tr ' ' '='
      echo -ne "${NORMAL_COLOR}"
      ;;
    good_exit)
      echo -ne "${GREEN__COLOR}"
      printf "%*s\n" $COLUMNS | tr ' ' '='
      printf "[$(date "+%H:%M:%S:%3N")]:     %s\n" "$arg"
      printf "%*s\n" $COLUMNS | tr ' ' '='
      echo -ne "${NORMAL_COLOR}"
      ;;
    section)
      echo -ne "${WHITE__COLOR}"
      printf "%*s\n" $COLUMNS | tr ' ' '-'
      printf "[$(date "+%H:%M:%S:%3N")]:     %s\n" "$arg"
      printf "%*s\n" $COLUMNS | tr ' ' '-'
      echo -ne "${NORMAL_COLOR}"
      ;;
    debug)
      if [ "$DEBUG" = "true" ]; then
        echo -e "[$(date "+%H:%M:%S:%3N")]:   ${CYAN___COLOR}  [Debug] ${NORMAL_COLOR} $arg"
      fi
    # *)
    #   echo -e "[$(date "+%H:%M:%S:%3N")]:                [SpareInfo] $arg"
    #   ;;
  esac
}

case "$item" in
  1)
    echo "case 1"
  ;;
  2|3)
    echo "case 2 or 3"
  ;;
  *)
    echo "default"
  ;;
esac


function exitFunction() {
  #
  # exit stuff useful for trap and exit
  #

  rm -rf ${TMPDIR}
  cd -
}

function do_init() {

  # move in script directory (used if launched qith automatic tools e.g. incrontab
  # that run from another dir)
  cd "$(dirname "$0")"

  TMPDIR=$(mktemp -d)
  trap "exitFunction;" EXIT

  SCRIPTNAME="$(basename "$0" .sh)"
  LOGFILE="${SCRIPTNAME}.log"
  RETAIN_NUM_LINES=1000
  TMP_ERROR="/${TMPDIR}/err_${SCRIPTNAME}"

  WHITE__COLOR="\033[1m"
  RED____COLOR="\033[1;31m"
  GREEN__COLOR="\033[1;32m"
  YELLOW_COLOR="\033[1;33m"
  BLUE___COLOR="\033[1;34m"
  PURPLE_COLOR="\033[1;35m"
  CYAN___COLOR="\033[1;36m"
  NORMAL_COLOR="\033[0m"

  do_logsetup
}

###############################################################################
# main # main # main # main # main # main # main # main # main # main # main #
###############################################################################
function main()
{
  do_init

  do_log title "Starting $SCRIPTNAME"

  if [ $(git status --porcelain | wc -l) -eq "0" ]; then
    do_log info "Git repo is clean. Exiting."
    return
  fi

  BRANCH="automatic"

  git ls-remote 2> ${TMP_ERROR}
  check_command $?

  do_log section "git checkout $BRANCH"
  git checkout $BRANCH 2> ${TMP_ERROR}
  check_command $?

  do_log section "git add --all"
  git add --all 2> ${TMP_ERROR}
  check_command $?

  do_log section "git commit -am "Automatic commit.""
  git commit -am "Automatic commit." 2> ${TMP_ERROR}
  check_command $?

  do_log section "git push origin $BRANCH"
  git push origin $BRANCH 2> ${TMP_ERROR}
  check_command $?
}

main

do_log good_exit "End"
exit 0
