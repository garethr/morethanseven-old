---
layout: post
title: "Buy vs Build your Monitoring System"
date: 2014-02-16 19:29
comments: true
categories: monitoring  
---

At the excellent [London Devops meetup](http://www.theguardian.com/info/developer-blog/2014/feb/15/london-devops-meetup-held-at-the-guardian) last week I asked what was
apparently a controversial question:

> should you just use software as a service monitoring products rather than integrate lots of open source tools?

This got a few people worked up and I promised a blog post.

Note that I wrote a post listing lots of [open source monitoring tools](http://www.morethanseven.net/2013/10/13/looking-into-monitoring-and-logging-tools/)
not that long ago. And I've been to both the
[Monitorama](http://monitorama.com/) events about open source
monitoring. And have a bunch of [Puppet modules for open source monitoring tools](http://forge.puppetlabs.com/garethr?q=monitoring). I'm
a fan of both open source and of open source monitoring. Please don't
read this as an attack on either, and particularly on the work of
awesome people working on  great open source monitoring products.

## Some assumptions

1. No one product exists that does everything. I think this is true for
   SaaS as much as for open source.
2. Lets work with about 200 hosts. This is a somewhat arbitrary number I
   know, some people will have more and others less.
3. If it saves money we'll pay yearly, rather than monthly or hourly.
4. We could probably get some volume discounts from some of the
   suppliers, but we'll use list prices for this post.

## Show me the money

So what would it cost to get up and running with a state of the art
software as a service monitoring system? In order to do this we need to
choose our software. For this post that means I'm going to pick products
I've used (sometimes only a bit) and like. This isn't a comprehensive
study of all the alternatives I'm afraid - though feel free to write
your own alternative blog posts.

* [New Relic](http://newrelic.com/) provides a crazy amount of data about
the running of both your servers and your applications. This includes
application performance data, errors, low level metrics and even rolled
up method or database query performance. $149 per host per month for our
200 hosts gives us *$29,800* per month.

* [Librato Metrics](https://metrics.librato.com) provides a fantastic way
of storing arbitrary time series data. We're already storing lots of
data in New Relic but Metrics provides us with less opinionated software
so we can use it for anything, for instance number of logins or searches
or other business level metrics. We'll go for a plan with 200 data sources, 100 metrics each and at 10 second resolution for a cost of *$3,860* per month.

* [Pagerduty](http://www.pagerduty.com/) is all about the alerts side of
monitoring. Most of the other SaaS tools we've chosen integrate with it
so we can make sure we get actionable emails and SMS messages to the
right people at the right time. Our plan costs $18 per person per month, 
so lets say we have 30 people at a cost of *$540* per month.

* [Papertrail](https://papertrailapp.com/) is all about logs. Simple setup
your servers with syslog and Papertrail will collect, analyze and store
all your log messages. You get a browser based interface, search tools
and the ability to setup alerts. We like lots of logs so we'll have a
plan for 2 weeks of search, 1 year archive and 100GB month of log
traffic. That all costs *$575* per month.

* [Sentry](https://www.getsentry.com) is all about exceptions. We could be
simply logging these and sending them to Papertrail but Sentry provides
tools for tracking and rolling up occurences. We'll go for a plan with
90 days of history and 200 events per minute at a cost of *$199* a
month.

* [Pingdom](https://www.pingdom.com) used to provide a very simple
external check service, but now they have added more complex multistage
checks as well as real user monitoring to the basic ping. We'll choose
the plan with 250 checks, 20 Real User Monitoring sites and 500 SMS
alerts for *$107 a month*.

## How much!

In total that all comes to *$35,080 (£20,922)* per month, or
*$420,960 (£251,062)* per year.

Now the first reaction of lots of people will be _that's a lot of money_
and it is. But remember open source isn't free either. We need to pay
for:

* The servers we run our monitoring software on
* The people to operate those servers
* The people to install and configure our monitoring software
* The office space and other costs of employing people (like management
  and hiring)

I think people with the ability to build software tend to forget they
are expensive, whether as a contractor or as a full time member of
staff. And people without management experience tend to forget costs
like insurance, rent, management overhead, recruitment, etc.

And probably more important than these for some people we need to consider:

* The time taken to build a good open source monitoring system

The time needed to put together a good monitoring stack based on for
instance logstash, kibana, riemann, sensu, graphite and collectd isn't
small. And don't forget the number of other moving parts like redis,
rabbitmq and elasticsearch that need installing configuring and
maintaining. That probably means compromising in the short term or
shipping later. In a small team how core is building your monitoring
stack to what you do as a business?

## But I can't use SaaS

For some people, using a software as a service product just isn't going
to cut it. Here's a list of reasons I can think of:

* Regulation constrains where your data can be stored, for instance it's
  not allowed out of the country
* Sheer size of infrastructure, although you may be able to get a volume
  discount it might not be enough

I think everything else is a cost/benefit issue or personal preference
(or bias). Happy to add more to that list, but I don't think it's a very
long list.

## Conclusions

I've purposefully not talked about the quality of the tools here, just
the cost. I've also not mentioned that it's likely not an all or nothing
decision, lots of people will mix SaaS products and open source tools.

Whether taking a SaaS approach will be quicker, cheaper or better will
depend on your specific business context. But try and make that about
the organisation and not about the technology.

If you've never used the current crop of SaaS monitoring
tools (and not just the one's mentioned above) then I think you're missing
out. Even if you stick with a mainly open source monitoring stack you
might look at your tools a bit differently after you've experimented
with some of the commercial competition.
