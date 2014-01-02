---
layout: post
title: "Testing Packer created images with serverspec"
date: 2014-01-01 15:24
comments: true
categories: packer serverspec wercker
---

[Packer](http://www.packer.io/) provides a great way of describing the steps for creating a virtual machine image. But it doesn't have a built-in way of verifying those images.

[Serverspec](http://serverspec.org/) provides a nice framework for writing tests against infrastructure, asserting the operation of services or the installation of packages.

I'm interested at the moment in building continous delivery pipelines for infrastructure components and have a simple working example of [testing Packer with Serverspec](https://github.com/garethr/packer-serverspec-example) on
Github. The example uses the AWS builder and the Puppet provisioner but the approach should work with other combinations.

This doesn't represent a complete infrastructure pipeline, but it does demonstrate an approach to automating one particular component - building base images.

## Testing

In our example I'm using the [Puppetlabs NTP](https://github.com/puppetlabs/puppetlabs-ntp) module to install and configure NTP. Once the Puppet provisioner has run, but before we build the AMI (or other virtal machine image) we run a test suite. For our example the tests are pretty simple:

    describe package('ntp') do
      it { should be_installed }
    end

    describe service('ntp') do
      it { should be_enabled   }
      it { should be_running   }
    end

If the tests fail, Packer will stop and the AMI won't be built. The combination of storing the code (Packer template) alongside a test suite (Serverspec) and building a new AMI whenever you change the code, makes this setup perfect for continuous integration. 

## Wercker builds

As an example of a continuous integration setup the repository contains a [wercker.yml](https://github.com/garethr/packer-serverspec-example/blob/master/wercker.yml) configuration file for the excellent [Wercker](http://devcenter.wercker.com/) service. Wercker makes setting up multi-step built pipelines easy and nicely configurable via a simple text file in your repository.

The Wercker [build for this project is public](https://app.wercker.com/#applications/52c450e489daaf145f001ad8). Currently the build involves downloading Packer, running `packer validate` to check the template and eventually running `packer build` to boot an instance and run our serverspec tests. 
