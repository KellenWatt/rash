class Environment
  
  attr_reader :aliasing_disabled
  attr_reader :superuser_mode

  def initialize
    common_init
  end

  def chdir(dir = nil)
    old = @working_directory
    Dir.chdir(dir.nil? ? "~" : dir.to_s)
    @working_directory = Dir.pwd
    ENV["OLDPWD"] = old.to_s
    Dir.pwd
  end
  
  def add_path(path) 
    ENV["PATH"] += File::PATH_SEPARATOR + (path.respond_to?(:path) ? path.path : path.to_s)
  end

  def method_missing(m, *args, &block) 
    if args.length == 0 && !block_given?
      ENV[m.to_s.upcase]
    elsif m.to_s[-1] == "=" && args.length == 1  && !block_given?
      ENV[m.to_s.upcase.delete_suffix("=")] = args[0].to_s
    else
      super
    end
  end

  def as_superuser(&block)
    @superuser_mode = true
    begin
      block.call
    ensure
      @superuser_mode = false
    end
  end
  
  private

  def common_init
    @working_directory = Dir.pwd

    @aliases = {}
    @aliasing_disabled = false
    @active_jobs = []

    @prompt = {
      AUTO_INDENT: true,
      RETURN: ""
    }
    ENV["RASHDIR"] = File.dirname(__FILE__)
  end
end

require_relative "rash/redirection"
require_relative "rash/aliasing"
require_relative "rash/jobcontrol"

$env = Environment.new


# note for later documentation: any aliases of cd must be functions, not 
# environmental aliases. Limitation of implementation.
def cd(dir = nil)
  $env.chdir(dir)
end


def run(file, *args)
  filename = file.to_s
  exe = (filename.start_with?("/") ? filename : File.expand_path(filename.strip))
  unless File.executable?(exe)
    raise SystemCallError.new("No such executable file - #{exe}", Errno::ENOENT::Errno)
  end
  system(exe, *args.flatten.map{|a| a.to_s}, {out: $stdout, err: $stderr, in: $stdin})
end


# Defines `bash` psuedo-compatibility. Filesystem effects happen like normal 
# and environmental variable changes are copied
def sourcesh(file) 
  bash_env = lambda do |cmd = nil|
    tmpenv = `#{cmd + ';' if cmd} printenv`
    tmpenv.split("\n").grep(/[a-zA-Z0-9_]+=.*/).map {|l| l.split("=")}
  end
  bash_source = lambda do |f|
    Hash[bash_env.call("source #{File.realpath f}") - bash_env.()]
  end

  bash_source.call(file).each {|k,v| ENV[k] = v if k != "SHLVL" && k != "_"}
end


def which(command)
  cmd = File.expand_path(command)
  return cmd if File.executable?(cmd) && !File.directory?(cmd)
  
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |pt|
    path = File.expand_path(pt)
    exts.each do |ext|
      exe = File.join(path, "#{command}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end


# Note that I defy convention and don't define `respond_to_missing?`. This
# is because doing so screws with irb.
def self.method_missing(m, *args, &block) 
  exe = which(m.to_s)
  if exe || ($env.alias?(m) && !$env.aliasing_disabled)
    if $env.superuser_mode
      system("sudo", *$env.resolve_alias(m), *args.flatten.map{|a| a.to_s}, {out: $stdout, err: $stderr, in: $stdin}) 
    else
      system(*$env.resolve_alias(m), *args.flatten.map{|a| a.to_s}, {out: $stdout, err: $stderr, in: $stdin})
    end
  else
    super
  end
end


run_command_file = "#{$env.HOME}/.rashrc"
load run_command_file if File.file?(run_command_file)
