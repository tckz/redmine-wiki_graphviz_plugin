begin
	require 'rubygems'
rescue LoadError => e
end
require 'rake/packagetask'
require 'pathname'

# task :package
Rake::PackageTask.new do |p|
	pn = Pathname.new(Dir.pwd)
	p.name = pn.basename

	File.open("init.rb") { |io|
		io.read =~ /version\s+'(.*)'/
		v = $1
		p.version = v
	}

	p.need_tar = true
	p.package_dir = 'pkg'
	p.package_files.include("**/*")
	p.package_files.exclude("pkg")
	p.define
end

# vim: set ts=2 sw=2 sts=2:
