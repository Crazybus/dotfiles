#!/usr/bin/env ruby
require 'rubygems'
require 'grok-pure'
require 'pp'

grok = Grok.new
grok.add_patterns_from_file("/opt/logstash/patterns/grok-patterns")
text = ARGV[0].dup
pattern = ARGV[1].dup
grok.compile(pattern)
pp grok.match(text).captures()
