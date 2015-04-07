JIRA Agile Stats
================

About
-----

Scripts to produce operational data, e.g. throughput, lead time, etc. from JIRA Agile.

How?
----

`performance.rb` is an example to begin. Identify your board and swimlane (for my case, swimlanes are types), and run the script:

    DATE_SINCE=2015-03-01 DATE_UNTIL=2015-03-31 ruby performance.rb 

