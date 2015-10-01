echo "Search 1a"
curl -XGET 'localhost:9200/applicationorgnametest/_analyze?pretty=1&analyzer=standard' -d 'd.h.l.(abcde).fghi.jkl.mnr.o'
echo "Search 1b"
curl -XGET 'localhost:9200/applicationorgnametest/_analyze?pretty=1&analyzer=standard' -d 'd h l abcde fghi jkl mnr o'
echo "Search 2"
curl -XGET 'localhost:9200/_analyze?analyzer=standard&pretty=1' -d 'd.h.l.i abcde.fghi.jkl.mnr.o'
echo "Search 3"
curl -XGET 'localhost:9200/applicationorgnametest/_analyze?field=org_name&pretty=1' -d 'd.h.l.i abcde.fghi.jkl.mnr.o'
echo "Search 4"
curl -XGET 'localhost:9200/applicationorgnametest/_analyze?field=correspondence_postcode&pretty=1' -d 'd.h.l.i abcde.fghi.jkl.mnr.o'
echo "Search 5"
curl -XGET 'localhost:9200/applicationorgnametest/_analyze?field=lic_no&pretty=1' -d 'd.h.l.i abcde.fghi.jkl.mnr.o'
echo "Search 6"
curl -XGET 'localhost:9200/vehicle_current/_analyze?pretty=1&analyzer=vehicle_current_ngram_analyzer' -d 'CRITERIA LINAY LENCOLL'

