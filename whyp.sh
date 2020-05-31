#! /usr/bin/env head -n 3

# This script is intended to be sourced, not run

if [[ "$0" == $BASH_SOURCE ]]; then
    echo "This file should be run as"
    echo "  source $0"
    echo "and should not be run as"
    echo "  sh $0"
fi
#
license_="This script is released under the MIT license, see accompanying LICENSE file"
#
heading_lines_=13 # Text before here was copied to template scripts, YAGNI


export WHYP_SOURCE=$BASH_SOURCE
export WHYP_DIR=$(dirname $(readlink -f $WHYP_SOURCE))
export WHYP_BIN=$WHYP_DIR/bin
export WHYP_VENV=
[[ -d $WHYP_DIR/.venv ]] && WHYP_VENV=$WHYP_DIR/.venv
[[ -d $WHYP_VENV ]] || WHYP_VENV=~/.virtualenvs/whyp
export WHYP_PY=$WHYP_DIR/whyp

# x

# https://www.reddit.com/r/commandline/comments/2kq8oa/the_most_productive_function_i_have_written/
e () {
    local __doc__="""Edit the first argument as if it's a type, pass on $@ to editor"""
    local ought_= ile_=
    is_bash "$1" && return
    is_file "$1" && dit_file_ "$@" && return $?
    if is_function "$1"; then
        arse_function_ "$1"
        dit_function_ "$@"
        return 0
    fi
    if is_alias "$1"; then
        dit_alias_ "$1"
        return 0
    fi
    python_will_import "$1" && ile_=$(python_module "$1") || ile_="$1"; shift
    ought_="$1"; shift
    whyp_edit_file "$ile_" +/"$ought_" "$@"_
}

w () {
    local __doc__="""w extends type"""
    [[ "$@" ]] || echo "Usage: w <command>"
    # -a, --all
    local lls_regexp_="--*[al]*" options_=
    [[ "$1" =~ $lls_regexp_ ]] && options_=--all
    [[ $options_ ]] && shift
    if is_file "$@"; then
        type "$@"
        echo
        which $options_ "$@" 2>/dev/null
        return 0
    else
        type "$@" 2>/dev/null || /usr/bin/env | grep --colour "$@"
    fi
    ww "$@"
}

alias .=ws

# xx

[[ $ALIAS_CC ]] && alias cc=e
alias .w=dot_w
alias wa='w --all'

ws () {
    local __doc__="""Source a file (that may set some aliases) and remember that file"""
    local ilename_=$(readlink -f "$1") ptional_=
    [[ $2 == "optional" ]] && ptional_=1
    if [[ -f $ilename_ ]]; then
      source $ilename_
      return 1
    fi
    [[ -f $ilename_ || $ptional_ ]] || echo Cannot source \"$1\". It is not a file. >&2
    [[ -f $ilename_ ]] || return
    source "$ilename_"
}

wq () {
    quietly w "$@"
}

ww () {
    local __doc__="""ww expands type"""
    [[ "$@" ]] || return 1
    local hyp_options_=$(ww_option "$@")
    [[ $hyp_options_ ]] && shift
    local ame_="$1"; shift
    ww_show "$ame_"
    [[ $? == 0 ]] && return 0
}

alias .w="ws $WHYP_SOURCE"

# xxx

ses () {
    if [[ $1 == -e ]]; then
        sed "$@"
    else
        sed -e "s,$1,$2",
    fi
}

wat () {
    local md_=cat
    is_file kat && md_=kat
    is_file bat && md_=bat
    $md_ "$@"
}
# xxxx

whyp () {
  w "$@"
}

ww_help () {
    local unction_=$1; shift
    rm -f /tmp/err
    [[ $1 =~ (-h|--help) ]] && ww $unction_ 2>/tmp/err
    local esult_=$?
    [[ -f /tmp/err ]] && return 2
    return $esult_
}

de_alias () {
    sed -e "/is aliased to \`/s:.$::" -e "s:.* is aliased to [\`]*::"
}

de_file () {
    sed -e "s:[^ ]* is ::"
}

de_hashed () {
    local ommand_=$1
    local ype_="$@"
    if [[ $ype_ =~ hashed ]]; then
        local ehash_=$(echo $ype_ | sed -e "s:.*hashed (\([^)]*\)):\1:")
        ype_="$ommand_ is $ehash_"
    fi
    echo $ype_
}

de_typed () {
    de_hashed $(quietly w "$@") | de_file | de_alias
}

deafened () {
    echo $(de_hashed $(wq "$@")) | de_alias | de_file
}

defended () {
    $( "$@") | de_alias | de_file
}

runnable () {
    QUIETLY type "$@"
}

ww_executable () {
    QUIETLY type $(deafened "$@")
}

# xxxxx
dot_w () {
    . $WHYP.sh
}

# xxxxx*

ww_bin () {
    local __doc__="""Full path to a script in whyp/bin"""
    echo $WHYP_BIN/"$1"
}

whyp_bin_run () {
    local __doc__="""Run a script in whyp/bin"""
    local cript_=$(ww_bin $1); shift
    if [[ -d $WHYP_VENV ]]; then
        (
            source "$WHYP_VENV/bin/activate"
            PYTHONPATH=$WHYP_DIR $cript_ "$@"
        )
    else
        PYTHONPATH=$WHYP_DIR $cript_ "$@"
    fi
}

whyp_pudb_run () {
    local __doc__="""Debug a script in whyp/bin"""
    local cript_=$(ww_bin $1); shift
    set -x
    PYTHONPATH=$WHYP_DIR pudb $cript_ "$@"
    set +x
}

ww_py () {
    python3 -m whyp "$@"
}

whyp_py_file () {
    python3 -m whyp -f "$@"
}

whyp_edit_file () {
    local __doc__="""Edit the first argument if it's a file"""
    local ile_=$1; shift
    [[ -f $ile_ ]] || return 1
    local ir_=$(dirname $ile_)
    [[ -d $ir_ ]] || ir_=.
    local ase_=$(basename $ile_)
    (cd $ir_; $EDITOR $ase_ "$@")
}

python_has_debugger () {
    [[ $1 =~ ^((3(.[7-9])?)|([4-9](.[0-9])?))$ ]]
}

looks_versiony () {
    [[ ! $1 ]] && return 1
    [[ $1 =~ [0-9](.[0-9])* ]]
}

local_python () {
    local ocal_python_name_=python
    if looks_versiony $1; then
        if python_has_debugger $1; then
            ocal_python_name_=python$1
        else
            ocal_python_name_=python2
            echo "Requested python version too old" >&2
        fi
        shift
    else
        ocal_python_name_=python3
    fi
    local ocal_python_=$(PATH=/usr/local/bin:/usr/bin/:/bin which $ocal_python_name_ 2>/dev/null)
    [[ $ocal_python_ ]] && $ocal_python_ -c "import sys; sys.stdout.write(sys.executable)"
}

ww_option () {
    local ptions_=
    [[ $1 == -q ]] && ptions_=quiet
    [[ $1 == -v ]] && ptions_=verbose
    [[ $1 == verbose ]] && ptions_=verbose
    [[ $1 == quiet ]] && ptions_=quiet
    [[ $1 == -f ]] && ptions_="$ptions_ --is-function"
    [[ $1 == -a ]] && ptions_="$ptions_ --is-alias"
    [[ $ptions_ ]] || return 1
    echo $ptions_
    return 0
}

looks_like_python_name () {
    local __doc__="""Whether arg looks like a python name"""
    # Python names do not start with numbers
    [[ $1 =~ ^[0-9] ]] && return 1
    # Python names do not have hyphens, nor code
    [[ $1 =~ [-/] ]] && return 1
    return 0
}

python_will_import () {
    local __doc__="""test that python will import any args"""
    for arg in "$@"; do
        looks_like_python_name $arg || continue
        python -c "import $arg" >/dev/null 2>&1 || return 1
    done
    return 0
}

python_module () {
    local __doc__="""the files that python imports args as"""
    local esult_=1
    for arg in "$@"; do
        looks_like_python_name $arg || continue
        python -c "import $arg; print($arg.__file__)" 2>/dev/null || continue
        esult_=0
    done
    return $esult_
}

python_module_version () {
    local __doc__="""the installed version of that python package"""
    local esult_=1 rg_=
    for rg_ in "$@"; do
        python_will_import $rg_ || continue
        python -c "import $rg_; module=$rg_; print(f'{module.__file__}: {module.__version__}')" 2>/dev/null || continue
        esult_=0
    done
    return $esult_
}

quietly () {
    "$@" 2>/dev/null
}

quiet_out () {
    "$@" >/dev/null
}

QUIETLY () {
    "$@" >/dev/null 2>&1
}

make_shebang () {
    sed -e "1s:.*:#! /bin/bash:"
}

wat () {
    local __doc__="""Choose best avalaible cat"""
    local __todo__="""Add vimcat, kat, pygments, ..."""
    local ines_=
    if [[ $1 =~ ^[0-9]+$ ]]; then
        ines_=$1
        shift
    fi
    if runnable bat; then
        bat --language=bash --style=changes,grid,numbers "$@"
    elif runnable kat; then
        kat --numbers "$@"
    elif [[ $ines_ > 40 ]]; then
        less "$@"
    else
        cat "$@"
    fi
    [[ $1 ]] || return 0
    ines_=$(wc -l "$1" | sed -e "s, .*,," 2>/dev/null)
    [[ $ines_ == 0 ]] || return 0
    set -x
    rri "$1"
    set +x
}


ww_bash () {
    local __doc__="""help on bash builtin"""
    is_bash "$@" || return 1
    help "$@"
    return 0
}

ww_function () {
    local __doc__="""whyp a function"""
    is_function "$@" || return 1
    arse_function_ "$@"
    [[ -f $path_to_file ]] || return 1
    type $1 | sed -e "/is a function$/d" | wat
    echo "'$path_to_file:$line_number' $function ()"
    echo "$EDITOR $path_to_file +$line_number"
    return 0
}

ww_alias () {
    is_alias "$@" || return 1
    alias $1
    local tdout_=$(alias $1)
    if [[ $tdout_  =~ is.a.function ]]; then
        ame_=$(defended $ame_)
        ww_function $ame_
    else
        local uffix_=${tdout_//*=\'}
        local ommand_=${uffix_//\'}
        w $ommand_
    fi
}

ww_file () {
    is_file "$@" || return 1
    local ath_=$(type "$1" | sed -e "s:.* is ::")
    local ommand_=less
    runnable bat && ommand_=bat
    $ommand_ $ath_
    ls -l $ath_
    return $ass_
}

is_type () {
    local s_type_=$1
    local hing_="$2"
    $s_type_ "$hing_" && return 0
    return 1
}

ww_args () {
    local rg_= ption_= hifts_=
    for rg_ in "$@"; do
        [[ $rg_ == -v ]] && ption_=-v
        [[ $rg_ == verbose ]] && ption_=-v
        [[ $rg_ == -q ]] && ption_=-q
        [[ $rg_ == quiet ]] && ption_=-q
        [[ $rg_ == -vv ]] && ption_=-v
        [[ $ption_ ]] || continue
        WOPTS=$ption_
        echo $rg_
    done
}

whyp_show_ () {
    WOPTS=
    local hower_=quietly rgs_=$(ww_args "$@") rg_= ame_= ype_=
    [[ $WOPTS == -v ]] && hower_=
    for rg_ in $rgs_; do
        ame_="$rg_"; shift
        ype_="$hower_ $rg_"; shift
        $ype_
    done
    return 0
}

ww_show () {
    local hyp__= ame_="$1"
    shift
    for whyp_ in ww_bash ww_function ww_alias ww_file ; do
        whyp_show_ $ame_ $whyp_ || continue
        return 0
    done
    return 1
}

ww_command () {
    local __doc__="""find what will be executed for a command string"""
    PATH_TO_ALIASES=/tmp/aliases
    PATH_TO_FUNCTIONS=/tmp/functions
    alias > $PATH_TO_ALIASES
    declare -f > $PATH_TO_FUNCTIONS
    ww_py --aliases=$PATH_TO_ALIASES --functions=$PATH_TO_FUNCTIONS "$@";
    # local return_value=$?
    # rm -f $PATH_TO_ALIASES
    # rm -f $PATH_TO_FUNCTIONS
    # return $return_value
}

ww_debug () {
    (DEBUGGING=www;
        local ommand_="$1"; shift
        ww $ommand_;
        w $ommand_;
        (set -x; $ommand_ "$@" 2>&1 )
    )
}

dit_alias_ () {
    local __doc__="""Edit an alias in the file $ALIASES, if that file exists"""
    ources_ --any || return
    local hyp_sources_=$(ources_ --all --optional)
    for sourced_file in $hyp_sources_; do
        [[ -f $sourced_file ]] || continue
        line_number=$(grep -nF "alias $1=" $sourced_file | cut -d ':' -f1)
        if [[ -n "$line_number" ]]; then
            whyp_edit_file $sourced_file +$line_number
            return 0
        fi
    done
    echo "Did not find a file with '$1'" >&2
    return 1
}

dit_function_ () {
    local __doc__="""Edit a function in a file"""
    local ade_=
    ake_path_to_file_exist_ && ade_=1
    local egexp_="^$function[[:space:]]*()[[:space:]]*{[[:space:]]*$"
    local ew_=
    if ! grep -q $egexp_ "$path_to_file"; then
        line_number=$(wc -l "$path_to_file")
        echo "Add $function onto $path_to_file at new line $line_number"
        set +x; return 0
    fi
    local ine_=; [[ -n "$line_number" ]] && ine_=+$line_number
    local eek_=+/$egexp_
    [[ "$@" =~ [+][/] ]] && eek_=$(echo "$@" | ses ".*\([+][/][^ ]*\).*" "\1")
    whyp_edit_file "$path_to_file" $ine_ $eek_
    test -f "$path_to_file" || return 0
    ls -l "$path_to_file"
    ww_source "$path_to_file"
    [[ $(basename $(dirname "$path_to_file")) == tmp ]] && rm -f "$path_to_file"
    return 0
}

dit_file_ () {
    local __doc__="""Edit a file, it is seems to be text, otherwise tell user why not"""
    local ile_=$(ww_py $1)
    [[ -f $ile_ ]] || return 1
    if file $ile_ | grep -q text; then
        whyp_edit_file  $ile_
    else
        echo $ile_ is not text >&2
        file $ile_ >&2
    fi
}

ww_source () {
    local __doc__="""Source optionally"""
    ws "$@" optional
}


quietly unalias .


# xxxx_+

www_ () {
    ww verbose "$@"
}

arse_function_ () {
    __parse_function_line_number_and_path_to_file $(ebug_declare_function_ "$1")
}

def_executable () {
    local __doc__="""Hello to the Pythonistas"""
    QUIETLY type $(deafened "$@")
}


old_whyp_type () {
    if is_alias "$1"; then
        type "$1"
    elif is_function "$1"; then
        type "$1"
        echo
        local bove_=$(( $line_number - 1 ))
        echo "whyp_edit_file $(relpath ""$path_to_file"") +$bove_ +/'\\<$function\\zs.*'"
    elif def_executable "$1"; then
        real_file=$(readlink -f $(which "$1"))
        [[ $real_file != "$1" ]] && echo -n "$1 -> "
        echo "$real_file"
    else type "$1"
    fi
}


# Methods starting with underscores are intended for use in this file only
#   (another convention borrowed from Python)


ources_ () {
    whyp_bin_run sources "$@"
}

rite_new_file_ () {
    local __doc__="""Copy the head of this script to file"""
    head -n $eading_lines_ $BASH_SOURCE > "$path_to_file"
}

reate_function_ () {
    local __doc__="""Make a new function with a command in shell history"""
    local doc="copied from $(basename $SHELL) history on $(date)"
    local history_command=$(how_history_command_)
    quietly eval "$function() { local __doc__="""$doc"""; $history_command; }"
}

ake_path_to_file_exist_ () {
    local __doc__="""make sure the required file exists, either an existing file, a new file, or a temp file"""
    if [[ -f "$path_to_file" ]]; then
        cp "$path_to_file" "$path_to_file~"
        return 0
    fi
    [[ ! "$path_to_file" || $path_to_file == main ]] && path_to_file=$(mktemp /tmp/function.XXXXXX)
    rite_new_file_ "$path_to_file"
}

im_line_ () {
    local ile_="$1";shift
    local ine_="$1";shift
    whyp_edit_file  "$ile_" +$line
}

how_history_command_ () {
    local __doc__="""Get a command from the end of current bash history"""
    local line=
    local words=$(fc -ln -$history_index -$history_index)
    for word in $words
    do
        if [[ ${word:0:1} != "-" ]]; then
            is_alias $word && word="\\$word"
        fi
        [[ -z $line ]] && line=$word || line="$line $word"
    done
    echo $line
}

ebug_declare_function_ () {
    local __doc__="""Find where the first argument was loaded from"""
    shopt -s extdebug
    declare -F "$1"
    shopt -u extdebug
}

ddf () {
    local __doc__="""where the arg came from"""
    ( shopt -s extdebug; declare -F "$1" )
}

__parse_function_line_number_and_path_to_file () {
    local __doc__="""extract the ordered arguments from a debug declare"""
    function="$1";
    shift;
    line_number="$1";
    shift;
    path_to_file="$*";
}

source_path () {
    test -f "$1" || return 1
    whyp_source "$@"
}

is_alias () {
    local __doc__="""Whether $1 is an alias"""
    [[ "$(type -t $1)" == "alias" ]]
}

is_function () {
    local __doc__="""Whether $1 is a function"""
    [[ "$(type -t $1)" == "function" ]]
}

is_bash () {
    local __doc__="""Whether the first argument is a keyword or builtin"""
    is_keyword $1 || is_builtin $1
}

is_keyword () {
    local __doc__="""Whether $1 is a keyword"""
    [[ "$(type -t $1)" == "keyword" ]]
}

is_builtin () {
    local __doc__="""Whether $1 is a builtin"""
    [[ "$(type -t $1)" == "builtin" ]]
}

is_file () {
    local __doc__="""Whether $1 is an executable file"""
    [[ "$(type -t $1)" == "file" ]]
}

is_unrecognised () {
    local __doc__="""Whether $1 is unrecognised"""
    [[ "$(type -t $1)" == "" ]]
}
