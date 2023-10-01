#!/bin/bash

# For each .adoc file in the current directory
for adoc_file in *.adoc
do
    # Convert .adoc to .xml
    xml_file="${adoc_file%.adoc}.xml"
    asciidoc -b docbook "$adoc_file"
    echo "Converted $adoc_file to $xml_file"
    
    # Convert .xml to .md
    md_file="${adoc_file%.adoc}.md"
    pandoc -f docbook -t markdown_strict "$xml_file" -o "$md_file"
    echo "Converted $xml_file to $md_file"
    
    # Delete the .xml file
    rm "$xml_file"
    echo "Deleted $xml_file"
done

echo "All .adoc files processed."
