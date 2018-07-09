require 'gviz'
require 'yaml'
require 'fileutils'

class String
  def camelize
    self.split(/[.-]/).map(&:capitalize).join
  end
end

if ARGV.empty?
  puts "Please set path to your playbook"
  puts "EXAMPLE: ruby graph.rb sample.yml"
  exit
end

gv = Gviz.new
roles = YAML.load_file(ARGV[0])

gv.graph do
  global layout:'dot',  rankdir: "TB"
  nodes shape:'box'

  roles.each do |role|
    name = role["name"] || role["playbook"]
    camelName = name.camelize
    dependencies = role["dependencies"]
    dependencies.map!(&:camelize) if dependencies

    node camelName.intern, label: name, shape:'box'
    dependencies.to_a.each do |dependency|
      edge "#{dependency}_#{camelName}".intern
    end
  end
end
outputFile = "images/#{ARGV[0].gsub(/\.\w+$/, '')}"
outputDir = outputFile.split("/")[0..-2].join("/")
FileUtils.mkdir_p(outputDir)
gv.save(outputFile.intern, :svg)
