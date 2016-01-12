import json
from pprint import pprint
import sys

# get index name from command line arg
index = sys.argv[1]

#get json from stdin
data = json.load(sys.stdin)

print(data['indices'][index]['index']['size_in_bytes'])


