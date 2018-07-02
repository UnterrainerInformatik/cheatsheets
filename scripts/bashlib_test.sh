#!/bin/bash
bl_echo_h "bashlib_test.sh"
. bashlib.sh
bl_init

echo This is a normal test
bl_echo_i This is an inverted test
bl_echo_b This is a bold test
echo -e This${bl_RED}is red${bl_CLEAR} and ${bl_BG_LIGHTBLUE}this is${bl_BG_GREEN} green${bl_CLEAR}
echo

bl_echo_info This is an info
bl_echo_warn This is a warning
bl_echo_err This is an error
echo

bl_parse_ini_file --prefix "I" bashlib.config
echo repo: $I__repo
echo dir: $I__dir
echo upstream: $I__upstream
echo message: $I__message
echo file: $I__files__file
echo arr: $I__arr
echo arr: $I__files__arr2

echo
echo arr2 as array:
for i in ${I__arr[@]}
do
    echo $i
done

echo
echo arr as array:
for i in ${I__files__arr2[@]}
do
    echo $i
done

echo
v=$(bl_repeat "+" 5)
echo ${v}
v=$(bl_repeat "+" 1)
echo ${v}
v=$(bl_repeat "+" 0)
echo ${v}

echo
bl_echo_n 0 "root level"
bl_echo_n 1 "first level"
bl_echo_n 2 "second level"
bl_echo_n 3 "third level"

bl_die Stirb
