import json
from pprint import pprint
import sys

#get json from stdin
data = json.load(sys.stdin)

try:
  index =data['indices'].keys()[0]
  print(data['indices'][index]['primaries']['store']['size_in_bytes'])
except Exception as e:
  print 0