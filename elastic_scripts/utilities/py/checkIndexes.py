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
        print "INFO : '{0}' no old version found".format(alias)
        continue

    diff = abs(newCount - oldCount)
    if (diff <> 0):
        percentDiff = float(diff * 100) / oldCount
        if (percentDiff > 10):
            print "ERROR : '{0}' old count = {1:,}, new count = {2:,}, {3:.2f}% change".format(alias, oldCount, newCount, percentDiff)
            errorCount += 1
        else:
            print "WARNING : '{0}' old count = {1:,}, new count = {2:,}, {3:.2f}% change".format(alias, oldCount, newCount, percentDiff)
    else:
        print "INFO : '{0}' document count is the same".format(alias)

if (errorCount > 0):
    sys.exit(1)
else:
    sys.exit(0)