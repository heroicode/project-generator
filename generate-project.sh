#!/usr/bin/env sh
set -o errexit -o nounset -o noclobber

PROJECT_DIR=${PROJECT_DIR:-$1}
case "$PROJECT_DIR" in (-h|-?|help|-help|--help)
	echo "Usage: $(basename "$0") destination-dir [name] [description]"
	exit
esac
if [ "${PROJECT_DIR##*/}" != "$PROJECT_DIR" ]; then
	PROJECT_BASEDIR="$PROJECT_DIR"
	PROJECT_DIR="${PROJECT_DIR##*/}"
fi
PROJECT_NAME=${PROJECT_NAME:-${2:-$PROJECT_DIR}}
PROJECT_DESCRIPTION=${PROJECT_DESCRIPTION:-${3:-$PROJECT_NAME}}
[ "$PROJECT_NAME" = '-' ] && PROJECT_NAME="$PROJECT_DIR"
[ "$PROJECT_DESCRIPTION" = '-' ] && PROJECT_DESCRIPTION="$PROJECT_NAME"
PROJECT_BASEDIR="${PROJECT_BASEDIR:-$PWD/$PROJECT_DIR}"
GIT_USER=$(git config --get user.email || echo "${USER}@localhost")
IGNORE_FILES=${IGNORE_FILES:-}

self=$(CDPATH='' cd -- "$(dirname -- "$(realpath $0)")" && pwd); cd "$self"


sed() {
	command sed <"$1" \
		-e "s/\$[{]PROJECT_NAME[}]/${PROJECT_NAME}/g" \
		-e "s/\$[{]PROJECT_DESCRIPTION[}]/${PROJECT_DESCRIPTION}/g" \
		-e "s/\$[{]GIT_USER[}]/${GIT_USER}/g"
}

rename () {
	case "$1" in
		editorconfig|env|gitignore|gitattributes)
		   echo ."$1";;
		*) echo "$1"
	esac
}

ignore() {
	for i in ${IGNORE_FILES}; do
		[ "$1" = "$i" ] && return
	done
	false
}

mkdir -p "$PROJECT_BASEDIR"

process_templates() {
	for tmpl in "$@"; do
		dest=$(rename "${tmpl##*/}")
		# echo "$dest"
		if ignore "$dest"; then
			:
		elif [ -f "$tmpl" ] && ! ignore "$dest"; then
			sed "$tmpl" > "$PROJECT_BASEDIR/$dest"
		elif [ -d "$tmpl" ]; then
			mkdir "$PROJECT_BASEDIR/$dest"
			# shellcheck disable=SC2030
			(
				PROJECT_BASEDIR="$PROJECT_BASEDIR/$dest"
				TEMPLATE_BASE="$TEMPLATE_BASE/$dest"
				process_templates "$TEMPLATE_BASE"/*
			)
		else
			echo >&2 "Found $dest but have no logic to process it"
		fi
	done
}

TEMPLATE_BASE="$self"/templates/
process_templates "$TEMPLATE_BASE"/*

(cd "$PROJECT_BASEDIR" && {
	git init .
})
