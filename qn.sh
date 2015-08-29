#!/bin/bash -

# vim: filetype=sh

# Set IFS explicitly to space-tab-newline to avoid tampering
IFS=' 	
'

# If found, use getconf to constructing a reasonable PATH, otherwise
# we set it manually.
if [[ -x /usr/bin/getconf ]]
then
  PATH=$(/usr/bin/getconf PATH)
else
  PATH=/bin:/usr/bin:/usr/local/bin
fi

QN_FOLDER=${QN_FOLDER:-$HOME/Documents/qn}
QN_TEMPLATE_FOLDER=${QN_TEMPLATE_FOLDER:-.templates}
QN_FILENAME_PREFIX=${QN_FILENAME_PREFIX:-`date '+%Y%m%d-'`}
QN_FILENAME_SUFFIX=${QN_FILENAME_SUFFIX:-.md}


function usage()
{
  cat <<Usage_Heredoc
Usage: $(basename $0) [OPTIONS] COMMAND

TODO: Write this

Where valid OPTIONS are:
  -h, --help  display usage

Where valid COMMANDs are:
  new
  list
  edit

See $(basename $0) COMMAND -h for information on that particular command.
Usage_Heredoc
}

function error()
{
  echo "Error: $@" >&2
  exit 1
}

function parse_options_new()
{
  while (($#))
  do
    case $1 in
      -h|--help)
        cat <<New_Usage_Heredoc
Usage: $(basename $0) n|new FILENAME PROJECT [TEMPLATE]

TODO: Write how new command works.

Where valid OPTIONS are:
  -h, --help  display usage
New_Usage_Heredoc
        exit 0
        ;;
      *)
        if [[ -z $new_filename ]]
        then
          new_filename=$1
        elif [[ -z $new_project ]]
        then
          new_project=$1
        elif [[ -z $new_template ]]
        then
          new_template=$1
        else
          error "Unknown option: $1. Try $(basename $0) n|new -h for options."
        fi
        ;;
    esac

    shift
  done

  test -n $new_filename || error "FILENAME not specified."
  test -n $new_project || error "PROJECT not specified."
  test -d $QN_FOLDER || error "$QN_FOLDER: no such folder"
  test -d $QN_FOLDER/$new_project || mkdir -p $QN_FOLDER/$new_project

  if [[ -n $new_template ]]
  then
    test -f $QN_FOLDER/$QN_TEMPLATE_FOLDER/$new_template.tmpl || error "$new_template: no such template."

    cp $QN_FOLDER/$QN_TEMPLATE_FOLDER/$new_template.tmpl \
      $QN_FOLDER/$new_project/$QN_FILENAME_PREFIX$new_filename$QN_FILENAME_SUFFIX
  fi

  $EDITOR $QN_FOLDER/$new_project/$QN_FILENAME_PREFIX$new_filename$QN_FILENAME_SUFFIX
}

function parse_options_list()
{
  local _doc_shortno=0

  while (($#))
  do
    case $1 in
      -h|--help)
        cat <<List_Usage_Heredoc
Usage: $(basename $0) l|list [OPTIONS]

List all documents available for edit

Where valid OPTIONS are:
  -h, --help  display usage
List_Usage_Heredoc
        exit 0
        ;;
      *)
        error "Unknown option: $1. Try $(basename $0) l|list -h for options."
        ;;
    esac

    shift
  done

  test -d $QN_FOLDER || error "$QN_FOLDER: no such folder"

  for file in `find $QN_FOLDER -type f -name "*$QN_FILENAME_SUFFIX"| fgrep -v $QN_TEMPLATE_FOLDER`
  do
    ((_doc_shortno=_doc_shortno+1))
    echo "`basename $file` [`dirname $file | sed -e 's/\.\///g'`] %$_doc_shortno"
  done
}

function parse_options_edit()
{
  while (($#))
  do
    case $1 in
      -h|--help)
        cat <<New_Usage_Heredoc
Usage: $(basename $0) e|edit FILENAME PROJECT

TODO: Write how new command works.

Where valid OPTIONS are:
  -h, --help  display usage
New_Usage_Heredoc
        exit 0
        ;;
      *)
        if [[ -z $edit_filename ]]
        then
          edit_filename=$1
        elif [[ -z $edit_project ]]
        then
          edit_project=$1
        else
          error "Unknown option: $1. Try $(basename $0) e|edit -h for options."
        fi
        ;;
    esac

    shift
  done

  test -n $edit_filename || error "FILENAME not specified."
  test -n $edit_project || error "PROJECT not specified."
  test -d $QN_FOLDER || error "$QN_FOLDER: no such folder"
  test -d $QN_FOLDER/$edit_project || error"$edit_project: no such project."

  if [[ $edit_filename =~ ^%[0-9]+$ ]]
  then
    local _doc_shortno=0
    local _expected=${edit_filename#"%"}
    for file in `find $QN_FOLDER -type f -name "*$QN_FILENAME_SUFFIX"| fgrep -v $QN_TEMPLATE_FOLDER`
    do
      ((_doc_shortno=_doc_shortno+1))
      if [[ $_doc_shortno -eq $_expected ]]
      then
        $EDITOR $file
        return
      fi
    done
    error "$edit_filename: invalid shortno."
  elif [[ -f $QN_FOLDER/$edit_project/$edit_filename ]]
  then
    $EDITOR $QN_FOLDER/$edit_project/$edit_filename
  elif [[ -f $QN_FOLDER/$edit_project/$edit_filename$QN_FILENAME_SUFFIX ]]
  then
    $EDITOR $QN_FOLDER/$edit_project/$edit_filename$QN_FILENAME_SUFFIX
  else
    error "$edit_filename: no such file."
  fi
}

function parse_options()
{
  while (($#))
  do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      new|n)
        shift
        parse_options_new $@
        exit 0
        ;;
      list|l)
        shift
        parse_options_list $@
        exit 0
        ;;

      edit|e)
        shift
        parse_options_edit $@
        exit 0
        ;;
      *)
        error "Unknown option: $1. Try $(basename $0) -h for options."
        ;;
    esac

    shift
  done

  usage
  exit 0
}


parse_options "$@"


