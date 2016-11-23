#
# Use npm@2.X in the sails repo to speed installation
# npm i -g npm@2
#
ES_URL=http://localhost:9200/sails

rm -rf demo
curl -XDELETE "$ES_URL"
curl -XPUT "$ES_URL"
curl -XPUT "$ES_URL/events/_mapping" -d '
{
    "events" : {
      "properties": {
        "at": {
          "type" : "date",
          "format" : "epoch_millis"
        },
        "event": {
          "type": "string"
        },
        "data": {
          "type": "string"
        }
      }
    }
}
'
echo ""
../../repository/bin/sails.js new demo
cd demo
node --debug app.js
