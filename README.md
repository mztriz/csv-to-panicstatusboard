csv-to-json
===========

Convert a [CSV](http://en.wikipedia.org/wiki/Comma-separated_values) file to [JSON](http://en.wikipedia.org/wiki/JSON) with attributes for [Panic Status Board](http://panic.com/statusboard/).

How does it work?
----
`csv-to-json.rb` takes in a file from the web, attemps to convert it to JSON and uploads the file to your Dropbox account with andreafabrizi's [Dropbox-Uploader](https://github.com/andreafabrizi/Dropbox-Uploader) bash script.

Sample conversion
----
Input CSV file:
`````csv
Daily Change,Open,Closed
5/4/9000 15:27:51, 169, 1024

`````
Output JSON file:
``````json
{
   "graph":{
      "title":"Daily Change",
      "type":"bar",
      "datasequences":[
         {
            "title":"open",
            "datapoints":[
               {
                  "title":"5/4/9000 15:53:11",
                  "value":169
               }
            ],
            "color":"red"
         },
         {
            "title":"closed",
            "datapoints":[
               {
                  "title":"5/4/9000 15:53:11",
                  "value":1053
               }
            ],
            "color":"green"
         }
      ]
   }
}
``````
