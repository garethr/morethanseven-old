---
layout: post
title: "Testing Vagrant runs with Cucumber"
date: 2014-03-15 20:42
comments: true
categories: vagrant cucumber testing
---

I've been a big fan of [Vagrant](http://www.vagrantup.com/) since it's
initial release and still find myself using it for various tasks.

Recently I've been using it to test collections of Puppet modules. For a
single host
[vagrant-serverspec](https://github.com/jvoorhis/vagrant-serverspec) is
excellent. Simply install the plugin, add a provisioner and write your
[serverspec](http://serverspec.org/) tests. The serverspec provisioner
looks like the following:

```ruby
config.vm.provision :serverspec do |spec|
  spec.pattern = '*_spec.rb'
end
```

But I also found myself wanting to test behaviour from the host
(serverspec tests are run on the guest), and also wanted to write tests
that checked the behaviour of a multi-box setup. I started by simply
writing some [Cucumber](http://cukes.info/) tests which I ran locally,
but I decided I wanted this integrated with vagrant. Enter
[vagrant-cucumber-host](https://github.com/garethr/vagrant-cucumber-host).
This implements a new vagrant provisioner which runs a set of cucumber
features locally.

```ruby
config.vm.provision :cucumber do |cucumber|
  cucumber.features = []
end
```

Just drop your features in the features folder and run `vagrant
provision`. If you just want to run the cucumber features, without any
of the other provisioners running you can use:

```bash
vagrant provision --provision-with cucumber
```

Another advantage of writing this as a vagrant plugin is that it uses
the Ruby bundled with vagrant, meaning you just install the plugin
rather than faff about with a local Ruby install. 

A couple of other vagrant plugins that I've used to make the testing
setup easier are [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
and [vagrant-hosts](https://github.com/adrienthebo/vagrant-hosts). Both
help with managing hosts files, which makes writing tests without
knowing the IP addresses easier.
