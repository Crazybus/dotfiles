#!/usr/bin/env ruby
require 'rubygems'
require 'grok-pure'
require 'pp'

grok = Grok.new
grok.add_patterns_from_file("/usr/share/logstash/vendor/bundle/jruby/2.5.0/gems/logstash-patterns-core-4.1.2/patterns")
text = ARGV[0].dup
pattern = ARGV[1].dup
grok.compile(pattern)
pp grok.match(text).captures()
