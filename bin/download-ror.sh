#!/bin/bash
#
#  Script to download ROR Data Dump from Zenodo.
#
#  The script checks whether the latest version is already present, to
#  avoid unnecessary downloads.  Therefore, it should be safe to run
#  this script periodically (e.g., via cron), within reason.
#
#  If a new Data Dump version is detected then it is downloaded.  The
#  old Data Dump json file is NOT deleted.
#
#  A symbolic link 'latest-ror-data.json' is maintained so it always
#  points to the latest version.

# URL for fetching the ROR data
metadata_url="https://zenodo.org/api/records/?communities=ror-data&sort=mostrecent"
# Fetch metadata and follow any redirects
metadata=$(curl -sL "$metadata_url")

# Parse the metadata to extract the download link
zip_url=$(echo "$metadata" | jq -r '.hits.hits[0].files[0].links.self')

# Check if jq was able to parse the URL correctly
if [[ "$zip_url" == "null" || -z "$zip_url" ]]; then
    echo "Error: Could not find the download URL in the response."
    exit 1
fi

echo "Found latest ROR Data Dump at $zip_url"
zip_filename=${zip_url##*/}

echo "Downloading $zip_filename ..."
curl -O $zip_url

json_filename=$(unzip -l $zip_filename | tail -n +4 | head -n -2 | sort -n | tail -1 | awk '{print $4}')
unzip -q -o $zip_filename $json_filename
rm -f $zip_filename

ln -s $json_filename latest-ror-data.json.new
mv latest-ror-data.json.new latest-ror-data.json
