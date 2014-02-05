---
layout: post
title: "A template for Puppet modules"
date: 2014-02-05 15:20
comments: true
categories: puppet 
---

A little while ago I published a [template writing your own puppet modules](https://github.com/garethr/puppet-module-skeleton). It's
very opinionated but comes out of the box with lots of the tools you
eventually find and add to your tool box. I'm posting this as it came
up at the recent [Configuration Management Camp](http://cfgmgmtcamp.eu)
and after discussing it I realised I hadn't actually wrote anything
about it anywhere.

## What do you get?

* A simple install, config, service class pattern
* Unit tests with [rspec-puppet](https://github.com/rodjek/rspec-puppet)
* Rake tasks for [linting](https://github.com/rodjek/puppet-lint) and [syntax checking](https://github.com/gds-operations/puppet-syntax)
* Integration tests using [Beaker](https://github.com/puppetlabs/beaker)
* A Modulefile to provide Forge metadata
* Command line tools to upload to the Forge with [blacksmith](https://github.com/maestrodev/puppet-blacksmith)
* A README based on the Puppetlabs documentation standards
* [Travis CI](https://travis-ci.org) configuration based on the official
  Puppetlabs support matrix
* A Guardfile which can run all the tests when you change manifests

Obviously you can choose not to use parts of this, or even delete
aspects, but I find that approach much quicker than starting from scratch
or copying files from previous modules and changing names.

## How can I use it?

Simple. The following will install the module skeleton to
`~/.puppet/var/puppet-module/skeleton`. This turns out to be picked up
by the Puppet module tool.

```bash
git clone https://github.com/garethr/puppet-module-skeleton 
cd puppet-module-skeleton
find skeleton -type f | git checkout-index --stdin --force --prefix="$HOME/.puppet/var/puppet-module/" --
```

With that in place you can then just run the following to create a new
module, where puppet-ntp is the name of our new module.

```bash
puppet module generate puppet-ntp
```

We use `puppet module` like this rather than just copying the files
because otherwise you would have to rename everything from class names
to test assertions. The skeleton actually contains erb templates in
places, and running `puppet module generate` results in the module name
being available to those templates.

## Now what?

Assuming you have run the above commands you should have a folder called
`puppet-ntp` in your current directory. `cd` into that and then install
the dependencies:

```bash
bundle install
```

[Bundler ](http://bundler.io/)is a dependency manager for Ruby. If you
don't already have it installed you should be able to do so with the
following:

```bash
gem install bundler
```

Now you have the dependencies why not run the full test suite? This
checks syntax, lints the Puppet code and runs the unit tests.

```bash
bundle exec rake test
```

Unit tests give fast feedback and help make sure the code you write is
going to do what you intend, but they aren't actually applying the
manifests to a real machine. For that you want an integration test.
You'll need [Vagrant](http://vagrantup.com) installed for this next
step. Lets run those as well with:

```bash
bundle exec rspec spec/acceptance
```

This will take a while, especially the first time. This uses Beaker to
download a virtual machine from Puppetlabs (if you don't already have
it) and then brings up a new machine, applies a simple manifest, runs
the acceptance tests and then destroys the machine.

The `CONTRIBUTING.md` file has more information for running the test
suite.

## What's new?

I've recently added a [Guardfile](https://github.com/guard/guard) to
help with testing. You can run this with:

```bash
bundle exec guard
```

Now in a separate tab or pane make a change to any of the manifests. The
tests should run automatically in the tab or pane where guard is
running.

## Can you add this new tool?

Probably. Although I started the repo a few other people have
contributed code or made improvements already. Just sent a pull request
or open an issue.

