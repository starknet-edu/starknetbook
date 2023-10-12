PARAM1=$1
PARAM2=$2

# Function section
function serve_book() {
    LANG=$1

    # Rebuild english version, updating the `messages.pot` file where all chunks of texts
    # to be translated are extracted.
    MDBOOK_OUTPUT='{"xgettext": {"pot-file": "messages.pot"}}' \
        mdbook build -d po

    fix_pot
    # Build available LANGUAGES. po file must exist for the languages listed
    # in the LANGUAGE file. If it's not, you can add a language by running (xx replaced by the language code):
    # msginit -i po/messages.pot -l xx -o po/xx.po
    for po_lang in $(cat ./LANGUAGES); do
        echo merging and building "$po_lang"
        msgmerge --update po/"$po_lang".po po/messages.pot
        MDBOOK_BOOK__LANGUAGE="$po_lang" mdbook build -d book/"$po_lang"
    done

    # Serving the language, if any.
    if [ -z "$LANG" ]; then
        echo ""
        echo "No input language, stop after build."
        exit 0
    fi

    # Serve the input language, if available.
    MDBOOK_BOOK__LANGUAGE="$LANG" mdbook serve -d book/"$LANG"
}

function build_new_language() {
    LANG=$1
    FILE=po/"$LANG".po

    # Stop if no language paramter.
    if [ -z "$LANG" ]; then
        echo ""
        echo "No input language, stop."
        exit 0
    fi

    # Build a new LANGUAGE .po file if not exist .
    if test -f "$FILE"; then
        echo ""
        echo "File $FILE already exists. Ensure you're initiating a new translation. Alternatively, use './transaction.sh $LANG' to serve an existing one."
    else
        fix_pot
        msginit -i po/messages.pot -l "$LANG" -o po/"$LANG".po
    fi
}

# This function is a temporary solution for this issue: https://github.com/google/mdbook-i18n-helpers/issues/64
function fix_pot() {
    # Filter out empty msgid entries
    FILE="po/messages.pot"

    # Get line numbers with the pattern 'msgid ""' immediately followed by 'msgstr ""'
    line_numbers=($(grep -n -A1 'msgid ""' "$FILE" | grep -m2 'msgstr ""' | cut -d- -f1))

    # If we have two occurrences(It can not be more than 2)
    if [ ${#line_numbers[@]} -eq 2 ]; then
        echo "Duplicate empty entry detected! Correcting the messages.pot file."

        second_line=${line_numbers[1]}

        # Find the last empty line before the second occurrence
        last_empty_line=$(sed -n "1,${second_line}p" "$FILE" | tac | grep -n -m 1 '^$' | cut -d: -f1)

        # Calculate the start line to begin deletion
        start_delete=$((second_line - last_empty_line + 1))

        # Delete the range from the starting line to the specified line
        # Check OS and adjust the sed command accordingly
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # MacOS
            sed -i '' "${start_delete},${second_line}d" "$FILE"
        else
            # Linux/GNU
            sed -i "${start_delete},${second_line}d" "$FILE"
        fi
    fi
}

# Main section
if [ "$PARAM1" == "new" ]; then
    # The first parameter is 'new', PARAM2 is set to $LANG.
    LANG=$PARAM2
    build_new_language "$LANG"

else
    # The first parameter is not 'new', PARAM1 is set to $LANG.
    LANG=$PARAM1
    serve_book "$LANG"

fi
