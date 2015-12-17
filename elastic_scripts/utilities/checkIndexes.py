import json
from pprint import pprint
import sys

aliases = [];
errorCount = 0;

with open('temp.json') as data_file:
    data = json.load(data_file)

for index in data['indices']:
    if (index <> '_river'):
        alias = index[:-3]
        if (alias not in aliases):
            aliases.append(alias)

for alias in aliases:
    try:
        v1Count = data['indices'][alias +"_v1"]['primaries']['docs']['count']
        v2Count = data['indices'][alias +"_v2"]['primaries']['docs']['count']
    except KeyError:
        print "INFO : "+ alias +" missing a version"
        continue

    diff = abs(v1Count - v2Count)
    if (diff > 0):
        print(alias)
        percentDiff = (diff * 100) / v1Count
        if (percentDiff > 10):
            print "ERROR : "+ alias +" "+ str(percentDiff) +"% difference in record counts"
            errorCount += 1
        else:
            print "INFO : "+ alias +" "+ str(percentDiff) +"% difference in record counts"

if (errorCount > 0):
    sys.exit(1)
else:
    sys.exit(0)