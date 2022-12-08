#!/usr/bin/env sh
set -o errexit -o nounset -o noclobber

PROJECT_DIR=${PROJECT_DIR:-$1}
case "$PROJECT_DIR" in (-h|-?|help|-help|--help)
	echo "Usage: $(basename "$0") destination-dir [name] [description]"
	exit
esac
if [ "${PROJECT_DIR##*/}" != "$PROJECT_DIR" ]; then
	echo >&2 "$PROJECT_DIR seems to be a subdirectory, which is not supported"
	exit 4
fi
PROJECT_NAME=${PROJECT_NAME:-${2:-$PROJECT_DIR}}
PROJECT_DESCRIPTION=${PROJECT_DESCRIPTION:-${3:-$PROJECT_NAME}}
[ "$PROJECT_NAME" = '-' ] && PROJECT_NAME="$PROJECT_DIR"
[ "$PROJECT_DESCRIPTION" = '-' ] && PROJECT_DESCRIPTION="$PROJECT_NAME"
PROJECT_BASEDIR="$PWD/$PROJECT_DIR"

self=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd); cd "$self"


sed() {
	command sed <"$1" \
		-e "s/\$[{]PROJECT_NAME[}]/${PROJECT_NAME}/g" \
		-e "s/\$[{]PROJECT_DESCRIPTION[}]/${PROJECT_DESCRIPTION}/g"
}

rename () {
	case "$1" in
		editorconfig|env|gitignore) echo ."$1";;
		*) echo "$1"
	esac
}

mkdir "$PROJECT_BASEDIR"
for tmpl in "$self"/templates/*; do
	dest=$(rename "${tmpl##*/}")
	# echo "$dest"
	sed "$tmpl" > "$PROJECT_BASEDIR/$dest"
done
(cd "$PROJECT_BASEDIR" && {
	git init .
})
