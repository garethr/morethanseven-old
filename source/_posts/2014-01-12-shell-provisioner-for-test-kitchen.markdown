---
layout: post
title: "Shell provisioner for Test Kitchen"
date: 2014-01-12 19:24
comments: true
categories: testing
---

As of a few weeks ago [Test Kitchen](http://kitchen.ci/) has a [shell provisioner](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/provisioner/shell.rb) as well as the original Chef provisioners. This opens up all sorts of interesting testing potential.

If you've not already seen Test Kitchen, probably because you're not using Chef, it's a tool for integration testing infrastructure code. Configured by a simple YAML file it will setup a matrix of virtual machines, using Virtualbox, AWS, OpenStack and more, run some setup code (normally applying Chef recipes) and then run a test suite (with support for Bats, ShUnit2, Rspec and Serverspec). It's all very pluggable. With the addition of the shell provisioner it's useful to just about anyone. To try and prove that here's a hello world style example.

## Dependencies

First we need to install Test Kitchen. We'll use vagrant and virtualbox for our example too so we need a few extra dependencies. I'm going to assume you have bundler installed, if not you may be able to do so with `gem install bundler` but as the number of ways of setting a ruby environment up is greater than the number of people on the planet I'll have to defer to instructions elsewhere for getting that far.

First create a file called `Gemfile` with the following contents:

```ruby
source "https://rubygems.org"

gem "test-kitchen", :git => "https://github.com/test-kitchen/test-kitchen.git"
gem "kitchen-vagrant"
gem "vagrant-wrapper"
```

Then run:

    bundle install

This should install the above software. Note that the shell provisioner is not yet in an official release so where installing direct from GitHub for the moment.

## Configuration

Next we'll tell Test Kitchen what we want to do. As much for demonstration purposes I'm going to grab one of the Puppetlabs boxes. This is just plain [Vagrant](http://vagrantup.com) so feel free to substitude the `box` and `box_url` for alternatives you already have installed locally. Otherwise the first run will take a little longer as it downloads a large file.

Pull all of the following in a file called `.kitchen.yml'.

```yaml
---
driver:
  name: vagrant

provisioner:
  name: shell

platforms:
  - name: puppet-precise64
    driver_config:
      box: puppet-precise64
      box_url: http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210.box

suites:
  - name: default
```

The shell provisioner is going to look for a file called `bootstrap.sh` by default. You can overide this but we'll leave it for the moment. Our bootstrap script is going to do something very simple, install the ntp package. But the important part is it could do anything; run Salt, run Ansible, run Puppet, execute any arbitrary code we choose. In this case our script is completely self contained but if it needed some additional files we could put them in a directory called `data` and they would be copied to the newly created virtual machine under `/tmp/kitchen`.

```bash
#!/bin/bash

apt-get install ntp -y
```

## Tests

The last step is to write a test. I'm suddently finding lots of excuses to use [Serverspec](http://serverspec.org/) so we'll use that, but if you prefer you can use pretty much anything. The following file should be saved as  `test/integration/default/serverspec/ntp_spec.rb`. Note the `default` in the path which matches our suite above in the `.kitchen.yml` file. Test Kitchen allows for multiple suites all with separate tests based on a strong set of file path conventions.

```ruby
require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe package('ntp') do
  it { should be_installed }
end

describe service('ntp') do
  it { should be_enabled }
  it { should be_running }
end
```

## Running the tests

With all of that in place we're ready to run our tests.

    bundle exec kitchen test

This should:

* download the virtual machine image if you don't already have it locally
* create a new virtual machine based on the image
* run the bootstrap.sh script
* run our serverspec test suite

The real power comes from doing this iteratively as you work on code, probably code more complex than a simple one-line bash script. You can also test across multiple virtual machines at a time, for instance different operating systems or different machine roles. The `kitchen` command line tool provides lots of help too, with the ability to login to machines, verify that specific combinations of platform and suite are working and print lots of diagnotic information to aid development.

Hopefully this will make it into a release soon, and we'll see more involved examples using higher level tools and more documentation. But even now I'd be looking at Test Kitchen for any infrastructure testing you might be doing.

