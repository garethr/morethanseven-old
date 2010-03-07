#!/usr/bin/ruby

require 'rubygems'
require 'tumblr'
require 'fileutils'

def calc_path(title)
  path = "content/" + Time.now.strftime("%Y/") 
  
  filename = Time.now.strftime("%m_%d_") + title.gsub(' ', '-').downcase + ".textile"
  # remove special characters
  filename.gsub!(/[:\/\\!\"\']/, '')
  [path, filename, path + filename]
end

def create_item(title, body)
  path, filename, full_path = calc_path(title)

  if File.exists?(full_path)
    $stderr.puts "\t[error] Exists #{full_path}"
    exit 1
  end

  clean_title = title.gsub('-', ' ')

  @now = Time.now

  template = <<TEMPLATE
---
created_at: #{@now.strftime("%Y/%m/%d")}
kind: article
publish: true
tags: [tumblr]
title: "#{clean_title}"
---

#{body}
TEMPLATE

  FileUtils.mkdir_p(path) if !File.exists?(path)
  File.open(full_path, 'w') { |f| f.write(template) }
  $stdout.puts "\t[ok] Edit #{full_path}"
end

Tumblr::API.read("morethanseven.tumblr.com") do |pager|
  data = pager.page(0)
  data.posts.each do |post|
    if post.title 
      puts post.title
      create_item(post.title, post.body)
    end
  end
end
