---
layout: post
title: "Platform as a Service and the network gap"
date: 2013-08-11 14:00
comments: true
categories: 
---

_Originally published on [Medium](https://medium.com/p/817849715f0a)._

I'm a big fan of the Platform as a Service (PaaS) model of operating web
application infrastructure. But I'm a much bigger user and exponent of
Infrastructure as a Service (IaaS) products within my current role
working for the UK Government. This post describes why that is, and
hopefully helps anyone else inside other large enterprise organisations
reason about the advantages and disadvantages, and helps PaaS vendors
and developers understand what I personally thing is a barrier to
adoption in that type of organisation.

A quick word of caution, I don’t know every product inside out. It’s
very possible a PaaS product exists that deals with the problems I will
describe. If you know of such a product do let me know.

## A simple use case

PaaS products make for the very best demos. Have a working application?
Deployment is probably as simple as:

    git push azure master 

Your app has started to run slowly because visitors are flooding in?
Just scale out with something like:

    heroku ps:scale web+2

The amount of complexity being hidden is astounding and the ability to
move incredibly quickly is obvious for anyone with experience of doing
this in a more traditional organisation.

## A not so simple use case

Even small systems are often being built out of many small services
these days. Many large organisations have been up to this for a while
under the banner of Service Orientated Architecture. I'm a big fan of
this approach, in my view it moves operational and organisational
complexity back into the development team where its impact can often be
minimised by automation. But that’s a topic for another post.

In a PaaS world having many services is fine. We just have more
applications running on the Platform which can be independently scaled
out to meet our needs. But services need to communicate with each other
somehow, and this is where our problems start. We’ll keep things simple
here by assuming communication is over HTTPS (which should be pretty
typical) but I don’t think other protocols make the problem I have go
away. The same problem applies if you’re using a SaaS database for
example.

## It’s the network, stupid

Over what network does my HTTPS internal service call travel? The
internet? The internal PaaS vendor’s network? If the latter, is my
traffic travelling over the same network as other clients on the
platform? Maybe I'm running my own PaaS in-house. But do I trust
everyone else in my very large organisation and want my traffic on the
same network as other things I don’t even know about? Even if it’s just
me do I want internal service traffic mixing with requests coming from
the internet? And are all my services created equally with regards what
they can and cannot access?

Throw in questions like: is the PaaS supplier running on infrastructure
provided by a public IaaS suppliers who you don’t have a relationship
with and you start to question the suitability of the current public
PaaS products for building secure service based systems.

## A journey into Enterprise Architectures

You might be thinking, pah, what’s the worst that can happen? If you
work for a small company or a shiny startup that might be completely
valid. If on the other hand you’re working in a regulated environment
(say PCI) or dealing with large volumes of highly sensitive information
you’re very likely to have to build systems that provide layers of
trust, and to be doing inspection, filtering and integrity checking as
requests flow between those layers.

Imagine that I have a service dealing with some sensitive data. If I
control the infrastructure (virtualised or not, IaaS provided or not)
I’ll make sure that service endpoint isn’t available to anything that
doesn’t need access to it via my network configuration. If I’m being
more thorough I’ll filter traffic through some sort of proxy that does
checking of the content; It should be JSON (or XML), it should meet this
schema, It shouldn’t exceed this rate, it shouldn’t exceed this payload
size or response size, etc. That is before anything even reaches the
services application. And that’s on top of SSL and maybe client
certificates.

If I don’t control the infrastructure, for example when running on a
PaaS, I lose some of the ability to have the network protect me. I can
probably get some of this back by running my own PaaS on my own
infrastructure, but without awareness and a nice interface to that
functionality at the PaaS layer I’m going to lose lots of the benefits
of running the PaaS in the first place. It’s nice that I can scale my
application out, but if new instances can’t connect to the required
backend services without some additional network configuration that’s
invisible to the PaaS what use is that?

The question becomes; how to implement security layers within existing
PaaS products (without changing them). And my answer is “I don’t know”.
Yet.

## Why isn’t SSL enough?

SSL doesn’t help as much as you’d like to think here because if I’m an
attacker what I’m probably going to attack is your buggy code rather
than the transport mechanism. SSL doesn’t protect you from SQL injection
or unpatched software or zero-day exploits. If the only thing that my
backend service will talk to is my frontend application, an attacker has
to compromise two things rather than just ignore the frontend and go
after the data. Throw in a filter as described above and it’s really
three things that need to be overcome.

## The PaaS/IaaS interface

I think part of the solution lies in exposing some of the underlying
infrastructure via the PaaS interface. IaaS is often characterised as
compute, storage and network. In my experience everyone forgets the
network part. In a PaaS world I don’t want to be exposed to storage
details (I just want it to appear infinite and pay for what I use) or
virtual machines (I just care about computing power, say RAM, not the
number of machines I’m running on) but I think I do, sometimes, want to
be exposed to the (virtual) network configuration.

Hopefully someone working on OpenShift or CloudFoundry or Azure or
Heroku or DotCloud or insert PaaS here is already working on this. If
not maybe this post will prompt someone to do so.
