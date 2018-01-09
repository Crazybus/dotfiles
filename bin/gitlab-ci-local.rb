#!/usr/bin/env ruby

require 'yaml'

ci = YAML.load_file('.gitlab-ci.yml')
image = ci['image']
variables = []
ci['variables'].each do |key, variable|
  variables << "-e #{key}=\'#{variable}\'"
end
ENV.each do |key, value|
  if (key[/^CLOUDSTACK/])
    variables << "-e #{key}=\'#{value}\'"
  end
end
variables = variables.join(' ')
puts Dir.pwd
cmd = "docker run --rm -ti #{variables} -v #{Dir.pwd}:/app -w /app #{image} bash"
puts cmd
before_scripts = ci.values.flatten.map{ |e| e['before_script'] }.flatten.uniq
File.write('before_scripts.sh', before_scripts.join("\n"))
system(cmd)
