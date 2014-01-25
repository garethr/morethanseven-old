---
layout: post
title: "Code coverage for Puppet modules"
date: 2014-01-25 17:23
comments: true
categories: puppet
---

One of my favourite topics for a while now has been *infrastructure as
code*. Part of that involves introducing well understood programming
techniques to infrastructure - from test driven design, to refactoring
and version control. One tool I'm fond of (even with it's potential to
be misused) is [code coverage](http://en.wikipedia.org/wiki/Code_coverage). I'd been meaning
to go code spelunking to see if this could be done for testing Puppet
modules. 

The functionality is now in [master for rspec-puppet](https://github.com/rodjek/rspec-puppet#producing-coverage-reports)
and so anyone feeling brave can use it now, or if you must wait for the
2.0.0 release. The actual implementation is inspired by the same functionality in
[ChefSpec](https://github.com/sethvargo/chefspec#reporting)
written by [Seth Vargo](https://sethvargo.com/). Lots of the how came
from here, and the usage is very similar.

## How to use it?

First add (or hopefully change) your Gemfile line item for rspec-puppet
to the following:

```ruby
gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
```

Then all you need to do is include the following line anywhere in a
spec.rb file in your spec directory.

```puppet
at_exit { RSpec::Puppet::Coverage.report! }
```

## What do I get?

Here's an [example module](https://github.com/garethr/garethr-nginx),
including a file called
[coverage_spec.rb](https://github.com/garethr/garethr-nginx/blob/master/spec/classes/coverage_spec.rb).
When running the test suite with `rake spec` you now get coverage
details like so:


    Total resources:   24
    Touched resources: 8
    Resource coverage: 33.33%

    Untouched resources:
      Class[Nginx]
      File[preferences.d]
      Anchor[apt::update]
      Class[Apt::Params]
      File[sources.list]
      Exec[Required packages: 'debian-keyring debian-archive-keyring' for nginx]
      Anchor[apt::source::nginx]
      Class[Apt::Update]
      File[configure-apt-proxy]
      Apt::Key[Add key: 7BD9BF62 from Apt::Source nginx]
      Anchor[apt::key/Add key: 7BD9BF62 from Apt::Source nginx]
      Anchor[apt::key 7BD9BF62 present]
      File[nginx.list]
      Exec[apt_update]
      File[sources.list.d]
      Exec[e407f76c6e349fc397947a4a49260a9320196cb1]


Here's the output on [Travis CI](https://travis-ci.org/garethr/garethr-nginx/jobs/17597307#L105) as
well for a recent build.

## Why is this useful?

I've already found coverage useful when writing tests for a few of my
puppet modules. The information about the total number of resouces is
interesting (and potentially an indicator of complexity) but the list of
untouched resources is the main useful part. These represent both
information about what your module is doing, and potential things you
might want to test.

I'm hoping to find some more time to make this even better, providing
more information about untouched resources, adding some configuration
options and hopefully to integrate with the [Coveralls API](https://coveralls.io/docs/api).
