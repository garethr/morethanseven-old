---
layout: post
title: "Making the web secure, one unit test at a time"
date: 2013-12-29 14:28
comments: true
categories: security sysadvent
---

_Originally written as part of [Sysadvent 2013](http://sysadvent.blogspot.co.uk/2013/12/day-21-making-web-secure-one-unit-test.html)._

Writing automated tests for your code is one of those things that,
once you have gotten into it, you never want to see code without tests
ever again. Why write pages and pages of documentation about how
something should work when you can write tests to show exactly how something does work? Looking at the number and quality of testing tools and frameworks (like cucumber,
rspec, [Test Kitchen](https://github.com/test-kitchen/test-kitchen),
[Server Spec](http://serverspec.org/),
[Beaker](https://github.com/puppetlabs/beaker),
[Casper](http://casperjs.org/) and
[Jasmine](http://pivotal.github.io/jasmine/) to name a few) that have
popped up in the last year or so I'm obviously not the only person who
has a thing for testing utilities.

One of the other things I am interested in is web application
security, so this post is all about using the tools and techniques
from unit testing to avoid common web application security issues. I'm
using Ruby in the examples but you could quickly convert these to other languages if you desire.

## Any port in a storm

Lets start out with something simple. Accidentally exposing
applications on TCP ports can lead to data loss or introduce a vector
for attack. Maybe your main website is super secure, but you left the
port for your database open to the internet. It's the server configuration equivalent of forgetting to lock the back door.

Nmap is a tool lots of people will be familiar with for spanning for
open ports. As well as a command line interface Nmap also has good
library support in lots of languages so lets try and write a simple
tests suite around it.

    require "tempfile"
    require "nmap/program"
    require "nmap/xml"

    describe "the scanme.nmap.org website" do
      file = Tempfile.new("nmap.xml")
      before(:all) do
        Nmap::Program.scan do |nmap|
          nmap.xml = file.path
          nmap.targets = "scanme.nmap.org"
        end
      end

      @open_ports = []
      Nmap::XML.new("scan.xml") do |xml|
        xml.each_host do |host|
          host.each_port do |port|
            @open_ports << port.number if port.state == :open
          end
        end
      end
    end

With the above code in place we can then write tests like:

    it "should have two ports open" do
     @open_ports.should have(2).items
    end

    it "should have port 80 open" do
     @open_ports.should include(80)
    end

    it "should have port 22 closed" do
     @open_ports.should_not include(22)
    end

We can run these manually, but also potentially as part of a
continuous integration build or constantly as part of a monitoring
suite.

## Run the Guantlt

We had to do quite a bit of work wrapping Nmap before we could write
the tests above. Wouldn't it be nice if someone had already wrapped
lots of useful security minded tools for us? [Gauntlt](http://gauntlt.org/) is pretty much just that, it's a security testing framework based on cucumber which currently supports curl, nmap, sslyze, sqlmap, garmr and a bunch more tools in master. Lets do something more advanced than our port scanning test above by testing a URL for a SQL injection vulnerability.

    @slow
    Feature: Run sqlmap against a target
      Scenario: Identify SQL injection vulnerabilities
        Given "sqlmap" is installed
        And the following profile:
          | name       | value                                      |
          | target_url | http://localhost/sql-injection?number_id=1 |
        When I launch a "sqlmap" attack with:
          """
          python <sqlmap_path> -u <target_url> —dbms sqlite —batch -v 0 —tables
          """
        Then the output should contain:
          """
          sqlmap identified the following injection points
          """
        And the output should contain:
          """
          [2 tables]
          +-----------------+
          | numbers         |
          | sqlite_sequence |
          +-----------------+
          """


The Gauntlt team publish [lots of examples](https://github.com/gauntlt/gauntlt/tree/master/examples) like this one alongside the source code, so getting started is easy. Gauntlt is very powerful, but as you'll see from the example above you need to know quite a bit about the underlying tools it is using. In the case above you need to know the various arguments to sqlmap and also how to interpret the output.

## Enter Prodder

[Prodder](https://github.com/garethr/prodder) is a tool I put together
to automate a few specific types of security testing. In many ways
it's very similar to Gauntlt; it uses the cucumber testing framework
and uses some of the same tools (like nmap and sslyze) under the hood.
However rather than a general purpose security framework like Gauntlt,
Prodder is higher level and very opinionated. Here's an example:

    Feature: SSL
      In order to ensure secure connections
      I want to check the SSL configuration of my servers
      Background:
        Given "sslyze.py" is installed
        Scenario: Check SSLv2 is disabled
          When we test using the "sslv2" protocol
          Then the exit status should be 0
          And the output should contain "SSLv2 disabled"

        Scenario: Check certificate is trusted
          When we check the certificate
          Then the output should contain "Certificate is Trusted"
          And the output should match /OK — (Common|Subject
Alternative) Name Matches/
          And the output should not contain "Signature Algorithm: md5"
          And the output should not contain "Signature Algorithm: md2"
          And the output should contain "Key Size: 2048"

        Scenario: Check certificate renegotiations
          When we test certificate renegotiation
          Then the output should contain "Client-initiated
Renegotiations: Rejected"
          And the output should contain "Secure Renegotiation: Supported"

        Scenario: Check SSLv3 is not using weak ciphers
          When we test using the "sslv3" protocol
          Then the output should not contain "Anon"
          And the output should not contain "96bits"
          And the output should not contain "40bits"
          And the output should not contain " 0bits"

This is a little higher level than the Gauntlt example — it's not
exposing the workings of sslyze that is doing the actual testing. All
you need is an understanding of SSL certifcates. Even if you're not an
expert on SSL you can accept the aforementioned opinions of Prodder
about what good looks like. Prodder currently contains steps and
exampes for port scanning, SSL certificates and security minded HTTP
headers. If you already have a cucumber based test suite (including
one based on Gauntlt) you can reuse the step definitions in that too.

I'm hoping to build upon Prodder, adding more types of tests and
getting agreement on the included opinions from the wider systems
administration community. By having a default set of shared assertions
about the expected security of out system we can more easily move onto
new projects, safe in the knowledge that a test will fail if someone
messes up our once secure configuration.

## I'm convinced, what should I do next?

As well as trying out some of the above tools and techniques for
yourself I'd recommend encouraging more security conversations in your
development and operations teams. Here's a few  places to start with:

* [Ben Hughes from Etsy talking about security culture at Devopsdays London](http://www.slideshare.net/beehooze/devopsday-london-ben-hughes-security)
* [A presentation I gave at Velocity about using penetration testing tools for monitoring purposes](https://speakerdeck.com/garethr/security-monitoring-with-open-source-penetration-testing-tools)
* [A workshop, again from Velocity all about getting started with Gauntlt](http://www.slideshare.net/wickett/gauntlt-velocity-eu2013)
