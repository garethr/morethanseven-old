---
layout: post
title: "Using OWASP ZAP from the command line"
date: 2014-06-23 08:24
comments: true
categories: security
---

I'm a big fan of [OWASP ZAP](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project) or
the Zed Attack Proxy. It's suprisingly user friendly and nicely pulls of
it's aim of being useful to developers as well as more hardcore penetration testers.

One of the features I'm particularly fond of is the aforementioned
proxy. Basically it can act as a transparent HTTP proxy, recording the
traffic, and then analyse that to conduct various active security tests;
looking for XSS issues or directory traversal vulnerabilities for
instance. The simplest way of seeding the ZAP with something to analyse is using
the simple inbuilt spider.

So far, so good. Unfortunately ZAP isn't designed to be used from the
command line. It's either a thick client, or it's a proxy with a simple
API. Enter [Zapr](https://github.com/garethr/zapr).

Zapr is a pretty simple wrapper around the ZAP API (using the
[owasp_zap](https://github.com/vpereira/owasp_zap) library under the
hood). All it does is:

* Launch the proxy in headless mode
* Trigger the spider
* Launch various attacks against the collected URLs
* Print out the results

This is fairly limited, in that a spider isn't going to work
particularly well for a mor interactive application, but it's a farily good
starting point. I may add different seed methods in the future (or would
happily accept pull requests). Usage wise it's as simple as:

```
zapr --summary http://localhost:3000/
```

That will print you out something like the following, assuming it finds
an issue.

```
+-----------------------------------+----------+----------------------------------------+
| Alert                             | Risk     | URL                                    |
+-----------------------------------+----------+----------------------------------------+
| Cross Site Scripting (Reflected)  | High     |http://localhost:3000/forgot_password   |
+-----------------------------------+----------+----------------------------------------+
```

The above alert is taken from a [simple example](https://github.com/garethr/zapr-example),
using the [RailsGoat](https://github.com/OWASP/railsgoat) vulnerable web
application as a scape goat. You can see the resulting output from
[Travis running the tests](https://travis-ci.org/garethr/zapr-example).

Zapr is a bit of a proof of concept so it's not particularly robust or
well tested. Depending on usage and interest I may tidy it up and extend
it, or I may leave it as a useful experiment and try and finally get ZAP
support into [Gauntlt](http://gauntlt.org), only time will tell.
