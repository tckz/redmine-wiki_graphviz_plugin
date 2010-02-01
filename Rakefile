begin
	require 'rubygems'
rescue LoadError => e
end
require 'rake/packagetask'
require 'rake/testtask'
require 'pathname'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/*/*_test.rb"
  #t.warning = true
  t.verbose = true
end

Rake::PackageTask.new do |p|
  p.name = "wiki_graphviz_plugin"
  p.version = :noversion

	p.need_tar = true
	p.package_dir = 'pkg'
	p.package_files.include("**/*")
	p.package_files.exclude("pkg")
	p.define
end


# vim: set ts=2 sw=2 sts=2:
