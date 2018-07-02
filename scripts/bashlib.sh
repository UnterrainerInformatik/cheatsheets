#!/bin/bash

# Import further helpers from here:
#
# https://github.com/martinburger/bash-common-helpers/blob/master/bash-common-helpers.sh

bl_cc () {
    echo "\033[$1m"
}

###############################################################################
# Control code helpers.
###############################################################################
bl_CLEAR=$(bl_cc 0)
bl_I=$(bl_cc 7)
bl_I_END=$(bl_cc 27)
bl_B=$(bl_cc 1)
bl_B_END=$(bl_cc 21)

###############################################################################
# Color definitions.
###############################################################################
bl_DEFAULT=$(bl_cc 39)
bl_BLACK=$(bl_cc 30)
bl_RED=$(bl_cc 31)
bl_GREEN=$(bl_cc 32)
bl_YELLOW=$(bl_cc 33)
bl_BLUE=$(bl_cc 34)
bl_MAGENTA=$(bl_cc 35)
bl_CYAN=$(bl_cc 36)
bl_LIGHTGRAY=$(bl_cc 37)
bl_DARKGRAY=$(bl_cc 90)
bl_LIGHTRED=$(bl_cc 91)
bl_LIGHTGREEN=$(bl_cc 92)
bl_LIGHTYELLOW=$(bl_cc 93)
bl_LIGHTBLUE=$(bl_cc 94)
bl_LIGHTMAGENTA=$(bl_cc 95)
bl_LIGHTCYAN=$(bl_cc 96)
bl_WHITE=$(bl_cc 97)

###############################################################################
# Background-color definitions.
###############################################################################
bl_BG_DEFAULT=$(bl_cc 49)
bl_BG_BLACK=$(bl_cc 40)
bl_BG_RED=$(bl_cc 41)
bl_BG_GREEN=$(bl_cc 42)
bl_BG_YELLOW=$(bl_cc 43)
bl_BG_BLUE=$(bl_cc 44)
bl_BG_MAGENTA=$(bl_cc 45)
bl_BG_CYAN=$(bl_cc 46)
bl_BG_LIGHTGRAY=$(bl_cc 47)
bl_BG_DARKGRAY=$(bl_cc 100)
bl_BG_LIGHTRED=$(bl_cc 101)
bl_BG_LIGHTGREEN=$(bl_cc 102)
bl_BG_LIGHTYELLOW=$(bl_cc 103)
bl_BG_LIGHTBLUE=$(bl_cc 104)
bl_BG_LIGHTMAGENTA=$(bl_cc 105)
bl_BG_LIGHTCYAN=$(bl_cc 106)
bl_BG_WHITE=$(bl_cc 107)



###############################################################################
# Returns the given character repeated X times.
#
# Example:
# bl_repeat "#" 10
# returns: "##########"
###############################################################################
bl_repeat () {
  local str=$1
  local num=$2
  if [ $num -eq 0 ]; then
    echo ""
    exit 0
  fi
  v=$(printf "%-${num}s" "${str}")
  echo "${v// /${str}}"
}


###############################################################################
# Writes the given messages as a heading to standard output.
#
# Example:
# bl_echo_h "name_of_script.sh"
#
# will output a color formatted version of:
# bl_echo_h "#######################"
# bl_echo_h "## name_of_script.sh ##"
# bl_echo_h "#######################"
###############################################################################
bl_echo_h () {  
  function ech {
    echo -e "${bl_B}${bl_BG_DARKGRAY}${bl_BLUE}$@${bl_DEFAULT}${bl_BG_DEFAULT}${bl_B_END}"
  }

  local str=$1
  local len=${#str}
  local l=$((len+6))
  r=$(bl_repeat "#" $l)
  ech $r
  ech "## $1 ##"
  ech $r
}


###############################################################################
# Writes the given messages in italic letters to standard output.
#
# Example:
# bl_echo_i "Something important occured."
###############################################################################
bl_echo_i () {  
  echo -e "${bl_I}$@${bl_I_END}"
}


###############################################################################
# Writes the given messages in bold letters to standard output.
#
# Example:
# bl_echo_b "Disk is full!"
###############################################################################
bl_echo_b () {  
  echo -e "${bl_B}$@${bl_B_END}"
}


###############################################################################
# Writes the given messages in blue letters for a certain level to standard 
# output.
#
# Example:
# bl_echo_n 0 "root level"
# bl_echo_n 1 "first level"
# bl_echo_n 2 "second level" "some more"
###############################################################################
bl_echo_n () {
  local l=$1
  shift
  local r=$(bl_repeat " " $(($l*2)))
  if [ $l -eq 0 ]; then
    echo -e "${bl_LIGHTBLUE}${bl_B}$r$@${bl_B_END}${bl_DEFAULT}"
  else
    echo -e "${bl_LIGHTBLUE}$r$@${bl_DEFAULT}"
  fi
}


###############################################################################
# Writes the given messages in green letters to standard output.
#
# Example:
# bl_echo_info "Task completed."
###############################################################################
bl_echo_info () {
  echo -e "${bl_GREEN}$@${bl_DEFAULT}"
}


###############################################################################
# Writes the given messages in yellow letters to standard output.
#
# Example:
# bl_echo_warn "Please complete the following task manually."
###############################################################################
bl_echo_warn () {
  echo -e "${bl_YELLOW}$@${bl_DEFAULT}"
}


###############################################################################
# Writes the given messages in red letters to standard output.
#
# Example:
# bl_echo_err "There was a failure."
###############################################################################
bl_echo_err () {
  echo -e "${bl_RED}$@${bl_DEFAULT}"
}


###############################################################################
# Should be called at the beginning of every shell script.
#
# Exits your script if you try to use an uninitialised variable and exits your
# script as soon as any statement fails to prevent errors snowballing into
# serious issues.
#
# Example:
# bl_init
###############################################################################
bl_init () {
  # Will exit script if we would use an uninitialised variable:
  set -o nounset
  # Will exit script when a simple command (not a control structure) fails:
  set -o errexit
}


###############################################################################
# Makes sure that the script is run as root. If it is, the function just
# returns; if not, it prints an error message and exits with return code 1 by
# calling `bl_die`.
#
# Example:
# bl_assert_running_as_root
#
# Note that this function uses variable $EUID which holds the "effective" user
# ID number; the EUID will be 0 even though the current user has gained root
# priviliges by means of su or sudo.
###############################################################################
bl_assert_running_as_root () {
  if [[ ${EUID} -ne 0 ]]; then
    bl_die "This script must be run as root!"
  fi
}


###############################################################################
# Writes the given messages in red letters to standard error and exits with
# error code 1.
#
# Example:
# bl_die "An error occurred."
###############################################################################
bl_die () {
  echo >&2 -e "${bl_BG_RED}${bl_WHITE}${bl_B}$@${bl_B_END}${bl_DEFAULT}${bl_BG_DEFAULT}"
  exit 1
}


###############################################################################
# Makes sure that the given variables exist. The variables are specified by
# name.
#
# Example:
# bl_variables_exist "TESTING__somevars__var1" "TESTING__somevars__var2"
#
# This function uses indirect expansion: Bash uses the value of the variable
# formed from the rest of parameter as the name of the variable. This way,
# we can check if a variable with the given name is set.
###############################################################################
bl_variables_exist () {
  for variable in ${@}; do
    if [[ -z "${!variable-}" ]]; then
      return 1
    fi
  done
  return 0
}


###############################################################################
# Checks if the term you're working on is dumb or a real term.
# 
# Example:
# if bl_isterm; then echo "Yay!"; else echo "Oooh!"; fi
###############################################################################
bl_isterm () {
  if test -t 1; then
    # see if it supports colors...
    ncolors=$(tput colors)
    if test -n "$ncolors" && test $ncolors -ge 8; then
      return 0
    fi
  fi
  return 1
}


###############################################################################
# Makes sure that the given command is available.
#
# Example:
# bl_assert_command_available "ping"
###############################################################################
bl_assert_command_available () {
  local cmd=${1}
  type ${cmd} >/dev/null 2>&1 || bl_die "Cancelling because required command '${cmd}' is not available."
}


###############################################################################
# Makes sure that the given regular file exists. Thus, is not a directory or
# device file.
#
# Example:
# bl_assert_file_exists "myfile.txt"
###############################################################################
bl_assert_file_exists () {
  local file=${1}
  if [[ ! -f "${file}" ]]; then
    bl_die "Cancelling because required file '${file}' does not exist."
  fi
}


###############################################################################
# Makes sure that the given file does not exist.
#
# Example:
# bl_assert_file_does_not_exist "file-to-be-written-in-a-moment"
###############################################################################
bl_assert_file_does_not_exist () {
  local file=${1}
  if [[ -e "${file}" ]]; then
    bl_die "Cancelling because file '${file}' exists."
  fi
}


###############################################################################
# Asks the user - using the given message - to either hit 'y/Y' to continue or
# 'n/N' to cancel the script.
#
# Example:
# bl_ask_to_continue "Do you want to delete the given file?"
#
# On yes (y/Y), the function just returns; on no (n/N), it prints a confirmative
# message to the screen and exits with return code 1 by calling `bl_die`.
###############################################################################
bl_ask_to_continue () {
  local msg=${1}
  local waitingforanswer=true
  while ${waitingforanswer}; do
    read -p "${msg} (hit 'y/Y' to continue, 'n/N' to cancel) " -n 1 ynanswer
    case ${ynanswer} in
      [Yy] ) waitingforanswer=false; break;;
      [Nn] ) echo ""; bl_die "Operation cancelled as requested!";;
      *    ) echo ""; echo "Please answer either yes (y/Y) or no (n/N).";;
    esac
  done
  echo ""
}


###############################################################################
# Asks the user for her password and stores the password in a read-only
# variable with the given name.
#
# The user is asked with the given message prompt. Note that the given prompt
# will be complemented with string ": ".
#
# This function does not echo nor completely hides the input but echos the
# asterisk symbol ('*') for each given character. Furthermore, it allows to
# delete any number of entered characters by hitting the backspace key. The
# input is concluded by hitting the enter key.
#
# Example:
# bl_ask_for_password "THEVARNAME" "Please enter your password"
###############################################################################
bl_ask_for_password () {
  local VARIABLE_NAME=${1}
  local MESSAGE=${2}

  echo -n "${MESSAGE}: "
  stty -echo
  local CHARCOUNT=0
  local PROMPT=''
  local CHAR=''
  local PASSWORD=''
  while IFS= read -p "${PROMPT}" -r -s -n 1 CHAR
  do
    # Enter -> accept password
    if [[ ${CHAR} == $'\0' ]] ; then
      break
    fi
    # Backspace -> delete last char
    if [[ ${CHAR} == $'\177' ]] ; then
      if [ ${CHARCOUNT} -gt 0 ] ; then
        CHARCOUNT=$((CHARCOUNT-1))
        PROMPT=$'\b \b'
        PASSWORD="${PASSWORD%?}"
      else
        PROMPT=''
      fi
    # All other cases -> read last char
    else
      CHARCOUNT=$((CHARCOUNT+1))
      PROMPT='*'
      PASSWORD+="${CHAR}"
    fi
  done
  stty echo
  readonly ${VARIABLE_NAME}=${PASSWORD}
  echo
}


###############################################################################
# Asks the user for her password twice. If the two inputs match, the given
# password will be stored in a read-only variable with the given name;
# otherwise, it exits with return code 1 by calling `bl_die`.
#
# The user is asked with the given message prompt. Note that the given prompt
# will be complemented with string ": " at the first time and with
# " (again): " at the second time.
#
# This function basically calls `bl_ask_for_password` twice and compares the
# two given passwords. If they match, the password will be stored; otherwise,
# the functions exits by calling `bl_die`.
#
# Example:
# bl_ask_for_password_twice "THEVARNAME" "Please enter your password"
###############################################################################
bl_ask_for_password_twice () {
  local VARIABLE_NAME=${1}
  local MESSAGE=${2}
  local VARIABLE_NAME_1="${VARIABLE_NAME}_1"
  local VARIABLE_NAME_2="${VARIABLE_NAME}_2"

  bl_ask_for_password "${VARIABLE_NAME_1}" "${MESSAGE}"
  bl_ask_for_password "${VARIABLE_NAME_2}" "${MESSAGE} (again)"

  if [ "${!VARIABLE_NAME_1}" != "${!VARIABLE_NAME_2}" ] ; then
    bl_die "Error: password mismatch"
  fi

  readonly ${VARIABLE_NAME}="${!VARIABLE_NAME_2}"
}


###############################################################################
# Replaces given string 'search' with 'replace' in given files.
#
# Important: The replacement is done in-place. Thus, it overwrites the given
# files, and no backup files are created.
#
# Note that this function is intended to be used to replace fixed strings; i.e.,
# it does not interpret regular expressions. It was written to replace simple
# placeholders in sample configuration files (you could say very poor man's
# templating engine).
#
# This functions expects given string 'search' to be found in all the files;
# thus, it expects to replace that string in all files. If a given file misses
# that string, a warning is issued by calling `bl_echo_warn`. Furthermore,
# if a given file does not exist, a warning is issued as well.
#
# To replace the string, perl is used. Pattern metacharacters are quoted
# (disabled). The search is a global one; thus, all matches are replaced, and
# not just the first one.
#
# Example:
# bl_replace_in_files placeholder replacement file1.txt file2.txt
###############################################################################
bl_replace_in_files () {

  local search=${1}
  local replace=${2}
  local files=${@:3}

  for file in ${files[@]}; do
    if [[ -e "${file}" ]]; then
      if ( grep --fixed-strings --quiet "${search}" "${file}" ); then
        perl -pi -e "s/\Q${search}/${replace}/g" "${file}"
      else
        bl_echo_warn "Could not find search string '${search}' (thus, cannot replace with '${replace}') in file: ${file}"
      fi
    else
        bl_echo_warn "File '${file}' does not exist (thus, cannot replace '${search}' with '${replace}')."
    fi
  done

}


###############################################################################
# bl_parse_ini_file [--boolean --prefix STRING] file
#
# Parses given ini file using Ruediger Meier's "simple INI file parser".
#
# Example:
# 1: bl_parse_ini_file mycfg.ini
# 2: bl_parse_ini_file "mycfg.ini" --prefix "TESTING"
# 3: bl_parse_ini_file --prefix "I" bashlib.config
#
# Now, variables without sections will be available as
# 1: ${INI__varname}
# 2: ${TESTING__varname}
# 3: ${I__varname}.
# 
# and variables in assumed section [somevars] will be available as
# 1: ${INI__somevars__varname}
# 2: ${TESTING__somevars__varname}
# 3: ${I__somevars__varname}
#
# Array-declaration is space-delimited as follows:
# arr = ("one" "two" "three"  4)
# arr2=(true false "'hi'" '"there"' blah)
# 
# Within the config file you can use # to denote a comment.
#
# 
# Important: This function expects that `bl_init` was called before.
#
# Please note the the parser is included at the end of this file. Thus, you do
# not need to install that parser.
# See: https://github.com/rudimeier/bash_ini_parser
###############################################################################
bl_parse_ini_file () {

  set +o nounset
  set +o errexit
  bl_read_ini $@ && rc=$? || rc=$?
  set -o errexit
  set -o nounset

  if [[ ${rc} != 0 ]] ; then
    bl_die "bl_read_ini exited with error code ${rc}."
  fi

}


###############################################################################
# Makes sure that the given INI variables exist. The variables are specified by
# name.
#
# This function is intended to provide the user feedback if her INI file would
# miss some expected variable.
#
# Example:
# bl_assert_ini_variables_exist "TESTING__somevars__var1" "TESTING__somevars__var2"
#
# This function uses indirect expansion: Bash uses the value of the variable
# formed from the rest of parameter as the name of the variable. This way,
# we can check if a variable with the given name is set.
###############################################################################
bl_assert_ini_variables_exist () {
  for variable in ${@}; do
    if [[ -z "${!variable-}" ]]; then
      bl_die "Missing variable in INI file: ${variable}"
    fi
  done
}


###############################################################################
# Ruediger Meier's "simple INI file parser" follows.
# Commit: 8fb95e3b335823bc85604fd06c32b0d25f2854c5
# Date: 2014-10-21T08:40:19Z
#
# Copyright (c) 2009    Kevin Porter / Advanced Web Construction Ltd
#                       (http://coding.tinternet.info, http://webutils.co.uk)
# Copyright (c) 2010-2014     Ruediger Meier <sweet_f_a@gmx.de>
#                             (https://github.com/rudimeier/)
#
# License: BSD-3-Clause, see LICENSE file
# See: https://github.com/rudimeier/bash_ini_parser
###############################################################################
function bl_read_ini()
{
	# Be strict with the prefix, since it's going to be run through eval
	function check_prefix()
	{
		if ! [[ "${VARNAME_PREFIX}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] ;then
			echo "read_ini: invalid prefix '${VARNAME_PREFIX}'" >&2
			return 1
		fi
	}
	
	function check_ini_file()
	{
		if [ ! -r "$INI_FILE" ] ;then
			echo "read_ini: '${INI_FILE}' doesn't exist or not" \
				"readable" >&2
			return 1
		fi
	}
	
	# enable some optional shell behavior (shopt)
	function pollute_bash()
	{
		if ! shopt -q extglob ;then
			SWITCH_SHOPT="${SWITCH_SHOPT} extglob"
		fi
		if ! shopt -q nocasematch ;then
			SWITCH_SHOPT="${SWITCH_SHOPT} nocasematch"
		fi
		shopt -q -s ${SWITCH_SHOPT}
	}
	
	# unset all local functions and restore shopt settings before returning
	# from read_ini()
	function cleanup_bash()
	{
		shopt -q -u ${SWITCH_SHOPT}
		unset -f check_prefix check_ini_file pollute_bash cleanup_bash
	}
	
	local INI_FILE=""
	local INI_SECTION=""

	# {{{ START Deal with command line args

	# Set defaults
	local BOOLEANS=1
	local VARNAME_PREFIX=INI
	local CLEAN_ENV=0

	# {{{ START Options

	# Available options:
	#	--boolean		Whether to recognise special boolean values: ie for 'yes', 'true'
	#					and 'on' return 1; for 'no', 'false' and 'off' return 0. Quoted
	#					values will be left as strings
	#					Default: on
	#
	#	--prefix=STRING	String to begin all returned variables with (followed by '__').
	#					Default: INI
	#
	#	First non-option arg is filename, second is section name

	while [ $# -gt 0 ]
	do

		case $1 in

			--clean | -c )
				CLEAN_ENV=1
			;;

			--booleans | -b )
				shift
				BOOLEANS=$1
			;;

			--prefix | -p )
				shift
				VARNAME_PREFIX=$1
			;;

			* )
				if [ -z "$INI_FILE" ]
				then
					INI_FILE=$1
				else
					if [ -z "$INI_SECTION" ]
					then
						INI_SECTION=$1
					fi
				fi
			;;

		esac

		shift
	done

	if [ -z "$INI_FILE" ] && [ "${CLEAN_ENV}" = 0 ] ;then
		echo -e "Usage: read_ini [-c] [-b 0| -b 1]] [-p PREFIX] FILE"\
			"[SECTION]\n  or   read_ini -c [-p PREFIX]" >&2
		cleanup_bash
		return 1
	fi

	if ! check_prefix ;then
		cleanup_bash
		return 1
	fi

	local INI_ALL_VARNAME="${VARNAME_PREFIX}__ALL_VARS"
	local INI_ALL_SECTION="${VARNAME_PREFIX}__ALL_SECTIONS"
	local INI_NUMSECTIONS_VARNAME="${VARNAME_PREFIX}__NUMSECTIONS"
	if [ "${CLEAN_ENV}" = 1 ] ;then
		eval unset "\$${INI_ALL_VARNAME}"
	fi
	unset ${INI_ALL_VARNAME}
	unset ${INI_ALL_SECTION}
	unset ${INI_NUMSECTIONS_VARNAME}

	if [ -z "$INI_FILE" ] ;then
		cleanup_bash
		return 0
	fi
	
	if ! check_ini_file ;then
		cleanup_bash
		return 1
	fi

	# Sanitise BOOLEANS - interpret "0" as 0, anything else as 1
	if [ "$BOOLEANS" != "0" ]
	then
		BOOLEANS=1
	fi


	# }}} END Options

	# }}} END Deal with command line args

	local LINE_NUM=0
	local SECTIONS_NUM=0
	local SECTION=""
	
	# IFS is used in "read" and we want to switch it within the loop
	local IFS=$' \t\n'
	local IFS_OLD="${IFS}"
	
	# we need some optional shell behavior (shopt) but want to restore
	# current settings before returning
	local SWITCH_SHOPT=""
	pollute_bash
	
	while read -r line || [ -n "$line" ]
	do
#echo line = "$line"

		((LINE_NUM++))

		# Skip blank lines and comments
		if [ -z "$line" -o "${line:0:1}" = ";" -o "${line:0:1}" = "#" ]
		then
			continue
		fi

		# Section marker?
		if [[ "${line}" =~ ^\[[a-zA-Z0-9_]{1,}\]$ ]]
		then

			# Set SECTION var to name of section (strip [ and ] from section marker)
			SECTION="${line#[}"
			SECTION="${SECTION%]}"
			eval "${INI_ALL_SECTION}=\"\${${INI_ALL_SECTION}# } $SECTION\""
			((SECTIONS_NUM++))

			continue
		fi

		# Are we getting only a specific section? And are we currently in it?
		if [ ! -z "$INI_SECTION" ]
		then
			if [ "$SECTION" != "$INI_SECTION" ]
			then
				continue
			fi
		fi

		# Valid var/value line? (check for variable name and then '=')
		if ! [[ "${line}" =~ ^[a-zA-Z0-9._]{1,}[[:space:]]*= ]]
		then
			echo "Error: Invalid line:" >&2
			echo " ${LINE_NUM}: $line" >&2
			cleanup_bash
			return 1
		fi


		# split line at "=" sign
		IFS="="
		read -r VAR VAL <<< "${line}"
		IFS="${IFS_OLD}"
		
		# delete spaces around the equal sign (using extglob)
		VAR="${VAR%%+([[:space:]])}"
		VAL="${VAL##+([[:space:]])}"
		VAR=$(echo $VAR)


		# Construct variable name:
		# ${VARNAME_PREFIX}__$SECTION__$VAR
		# Or if not in a section:
		# ${VARNAME_PREFIX}__$VAR
		# In both cases, full stops ('.') are replaced with underscores ('_')
		if [ -z "$SECTION" ]
		then
			VARNAME=${VARNAME_PREFIX}__${VAR//./_}
		else
			VARNAME=${VARNAME_PREFIX}__${SECTION}__${VAR//./_}
		fi
		eval "${INI_ALL_VARNAME}=\"\${${INI_ALL_VARNAME}# } ${VARNAME}\""

		if [[ "${VAL}" =~ ^\".*\"$  ]]
		then
			# remove existing double quotes
			VAL="${VAL##\"}"
			VAL="${VAL%%\"}"
		elif [[ "${VAL}" =~ ^\'.*\'$  ]]
		then
			# remove existing single quotes
			VAL="${VAL##\'}"
			VAL="${VAL%%\'}"
		elif [ "$BOOLEANS" = 1 ]
		then
			# Value is not enclosed in quotes
			# Booleans processing is switched on, check for special boolean
			# values and convert

			# here we compare case insensitive because
			# "shopt nocasematch"
			case "$VAL" in
				yes | true | on )
					VAL=1
				;;
				no | false | off )
					VAL=0
				;;
			esac
		fi
		
		if [[ $VAL == \(* && $VAL == *\) ]]; then 	# if opening and closing parenthesis...
			# declare as an array
			eval "$VARNAME=$VAL"
		else
			# enclose the value in single quotes and escape any
			# single quotes and backslashes that may be in the value
			VAL="${VAL//\\/\\\\}"
			VAL="\$'${VAL//\'/\'}'"
			eval "$VARNAME=$VAL"
		fi
		
	done  <"${INI_FILE}"
	
	# return also the number of parsed sections
	eval "$INI_NUMSECTIONS_VARNAME=$SECTIONS_NUM"

	cleanup_bash
}

