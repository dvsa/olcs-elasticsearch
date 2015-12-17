import json
from pprint import pprint
import sys

# get alias name we're interested in
aliases = sys.argv
# remove script name
aliases.pop(0)
# new version
newVersion = aliases.pop(0)
errorCount = 0;

# get the doc count for another index besides the new one
def getOldCount( alias, data ):
    for index in data['indices']:
        # if index name begins with the alias AND it is not the newVersion
        if index.find(alias) == 0 and index != alias +'_v'+ newVersion:
            return data['indices'][index]['primaries']['docs']['count']
    return None


with open('temp.json') as data_file:
    data = json.load(data_file)

for alias in aliases:
    newCount = data['indices'][alias +"_v"+ newVersion]['primaries']['docs']['count']
    oldCount = getOldCount(alias, data)

    if oldCount == None:
        print "INFO : "+ alias +" no old version"
        continue

    diff = abs(oldCount - newCount)
    if (diff > 0):
        percentDiff = (diff * 100) / oldCount
        if (percentDiff > 10):
            print "ERROR : "+ alias +" "+ str(percentDiff) +"% difference in record counts"
            errorCount += 1
        else:
            print "WARNING : "+ alias +" "+ str(percentDiff) +"% difference in record counts"
    else:
        print "INFO : "+ alias +" same"

if (errorCount > 0):
    sys.exit(1)
else:
    sys.exit(0)