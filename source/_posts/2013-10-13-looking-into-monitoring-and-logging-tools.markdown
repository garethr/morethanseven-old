---
layout: post
title: "Looking into monitoring and logging tools"
date: 2013-10-13 12:00
comments: true
categories: logging monitoring
---

_Originally published on [Medium](https://medium.com/p/1cbb173faa3a)._

We have a bunch of internal mailing lists at [work](http://digital.cabinetoffice.gov.uk/), and on one of them someone asked:

> we’re looking into monitoring/logging tools…

I ended up writing a bit of a long reply which a few people found useful, so I thought I’d repost it here for posterity. I’m sure this will date but I think it’s a reasonable snapshot of the state of open source monitoring tools at the end of 2013.

Simply put, think about four elements and you won’t be far off on the
technical front. Miss one and you’re probably in trouble.

* logs
* metric storage
* metric collection
* monitoring checks

For logs, some combination of syslog at one end and elasticsearch and
[Kibana](http://www.elasticsearch.org/overview/kibana/) at the other are probably the state of the open source art at
the moment. The shipping around is more interesting; [Logstash](http://logstash.net/) is improving constantly, [Heka](http://heka-docs.readthedocs.org/en/latest/) is an similar alternative from Mozilla, and [Fluentd](http://fluentd.org/) looks nice too.

For pure metrics it’s all about [Graphite](http://graphite.wikidot.com/), which is both awesome and
perilous. Not much else really competes in the open source world at
present. Maybe [OpenTSB](http://opentsdb.net/) (is you’re into a Hadoop stack.)

For collecting metrics on boxes I’d probably look at [collectd](http://collectd.org/) or [diamond](https://github.com/BrightcoveOS/Diamond) both of which have pros and cons but work well. [Statsd](https://github.com/etsy/statsd/) is also useful here for different types of metric collection and aggregation. [Ganglia](http://ganglia.sourceforge.net/) is interesting too, it combines some aspects of the metrics collection tools with an integrated storage and visualisation tool similar to Graphite.

Monitoring checks is a bit more painful. I’ve been experimenting with [Sensu](http://sensuapp.org/) in hope of not installing Nagios. Nagios works but it’s just a bit ungainly. But you do need somewhere to write checks against metrics or other aspects of your system and to issue alerts.

At this point everyone loves dashboards, and [Dashing](http://shopify.github.io/dashing/) is particularly lovely. [Graphiti](https://github.com/paperlesspost/graphiti) and [Tasseo](https://github.com/obfuscurity/tasseo) for Graphite are useful too.

For bonus points things like [Flapjack](http://flapjack.io/) and [Reimann](http://riemann.io/) provide some interesting extra capabilities around alert control or real time monitoring respectively.

And for that elusive top of the class grade take a look at [Kale](http://codeascraft.com/2013/06/11/introducing-kale/), which provides anomaly detection on top of Graphite and Elasticsearch .

You might be thinking that’s a lot of moving parts and you’d be right. If you’re a small project running all of that is too much overhead, turning to something like Zabbix might be more sensible.

Depending on money/sensitivity/control issues lots of nice and not so
nice commercial products exist. [Circonus](http://www.circonus.com/), [Splunk](http://www.splunk.com/), [New Relic](http://newrelic.com/), [Boundary](http://boundary.com/) and [Librato Metrics](https://metrics.librato.com/) are all lovely in different ways and provide part of the puzzle.

And that’s just the boring matter of tools. Now you get into alert design and other gnarly people stuff.

If you got this far you should watch all the [Monitorama videos](http://vimeo.com/monitorama) too.
