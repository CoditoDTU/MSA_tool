#!/usr/bin/env python3

# standard library modules
import sys, errno, re, json, ssl
import argparse
from urllib import request
from urllib.error import HTTPError
from time import sleep


def get_url_name(protein_ID):#, hmm_ID):

  # Template URL from interpro script
  BASE_URL = "https://www.ebi.ac.uk:443/interpro/api/protein/UniProt/entry/InterPro/{}/?page_size=200&extra_fields=sequence" 

  # Replaces the {} with the protein_ID variable which corresponds to the string id like IPR0...
  protein_ID_url = BASE_URL.format(protein_ID) 
  return protein_ID_url


def output_list(required_url):
  HEADER_SEPARATOR = "|"
  LINE_LENGTH = 80
  #disable SSL verification to avoid config issues
  context = ssl._create_unverified_context()

  next = required_url
  last_page = False

  
  attempts = 0
  while next:
    try:
      req = request.Request(next, headers={"Accept": "application/json"})
      res = request.urlopen(req, context=context)
      # If the API times out due a long running query
      if res.status == 408:
        # wait just over a minute
        sleep(61)
        # then continue this loop with the same URL
        continue
      elif res.status == 204:
        #no data so leave loop
        break
      payload = json.loads(res.read().decode())
      next = payload["next"]
      attempts = 0
      if not next:
        last_page = True
    except HTTPError as e:
      if e.code == 408:
        sleep(61)
        continue
      else:
        # If there is a different HTTP error, it wil re-try 3 times before failing
        if attempts < 3:
          attempts += 1
          sleep(61)
          continue
        else:
          sys.stderr.write("LAST URL: " + next)
          raise e

    for i, item in enumerate(payload["results"]):
      
      entries = None
      if ("entry_subset" in item):
        entries = item["entry_subset"]
      elif ("entries" in item):
        entries = item["entries"]
      
      if entries is not None:
        entries_header = "-".join(
          [entry["accession"] + "(" + ";".join(
            [
              ",".join(
                [ str(fragment["start"]) + "..." + str(fragment["end"]) 
                  for fragment in locations["fragments"]]
              ) for locations in entry["entry_protein_locations"]
            ]
          ) + ")" for entry in entries]
        )
        sys.stdout.write(">" + item["metadata"]["accession"] + HEADER_SEPARATOR
                          + entries_header + HEADER_SEPARATOR
                          + item["metadata"]["name"] + "\n")
      else:
        sys.stdout.write(">" + item["metadata"]["accession"] + HEADER_SEPARATOR + item["metadata"]["name"] + "\n")

      seq = item["extra_fields"]["sequence"]
      fastaSeqFragments = [seq[0+i:LINE_LENGTH+i] for i in range(0, len(seq), LINE_LENGTH)]
      for fastaSeqFragment in fastaSeqFragments:
        sys.stdout.write(fastaSeqFragment + "\n")
      
    # Don't overload the server, give it time before asking for more
    if next:
      sleep(1)

def main():
  """
    Main function to parse command-line arguments and functions.
  """
  parser = argparse.ArgumentParser(description='Looks for Ids in an interpro result json file')
  parser.add_argument("-i", "--input_file", required=True, help="String names of family ID and hmm ID")
  args = parser.parse_args()
  
  
  url = get_url_name(args.input_file)
  #print(url)
  output_list(url)  #Commented as It already worked


if __name__ == "__main__":
  main()
  