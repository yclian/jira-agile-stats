JIRA Agile Stats
================

About
-----

Scripts to produce operational data, e.g. throughput, lead time, etc. from JIRA Agile.

How?
----

`performance.rb` is an example to begin. Identify your board and swimlane (for my case, swimlanes are types), and run the script:

    DATE_SINCE=2015-03-01 DATE_UNTIL=2015-03-31 ruby performance.rb 

In a similar fashion, run `defects.rb`, which returns basic statistics according to configured issue filters:

    DATE_SINCE=2015-03-01 DATE_UNTIL=2015-03-31 ruby defects.rb

And for scope (burndown) data, run `scope.rb` this way, by the number of sprints to inspect:

    SPRINTS=5 ruby scope.rb

