class Environment
  
  attr_reader :aliasing_disabled
  attr_reader :umask

  def initialize
    common_init
  end

  def chdir(dir = nil)
    old = @working_directory
    Dir.chdir(dir.nil? ? "~" : dir.to_s)
    @working_directory = Dir.pwd
    ENV["OLDPWD"] = old.to_s
    ENV["PWD"] = Dir.pwd
    Dir.pwd
  end

  # Note that this works regardless of which version of chdir is used.
  def push_dir(dir = nil)
    @directory_stack.push(Dir.pwd)
    self.chdir(dir)
  end

  def pop_dir
    self.chdir(@directory_stack.pop) if @directory_stack.size > 0
  end

  def dirs
    @directory_stack
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
  
  def umask=(mask)
    File.umask(mask)
    @umask = mask
  end

  def as_superuser(&block)
    @superuser_mode = true
    begin
      block.call
    ensure
      @superuser_mode = false
    end
  end

  def with_limits(limits, &block)
    if block_given?
      pid = fork do
        limits.each {|resource, limit| Process.setrlimit(resource, *limit)}
        block.call
        exit!(true)
      end
      Process.wait(pid)
    else
      limits.each {|resource, limit| Process.setrlimit(resource, *limit)}
    end
  end
  
  def dispatch(m, *args)
    if @in_pipeline
      add_pipeline(m, *args)
    else
      system_command(m, *args)
    end
  end

  def name?(v)
    v.kind_of?(String) || v.kind_of?(Symbol)
  end

  private

  def common_init
    @working_directory = Dir.pwd
    @umask = File.umask

    @aliases = {}
    @aliasing_disabled = false
    @active_jobs = []

    @active_pipelines = []

    @directory_stack = []

    @prompt = {
      AUTO_INDENT: true,
      RETURN: ""
    }
  end

  def resolve_command(m, *args, literal: false) 
    (literal ? [m.to_s] : resolve_alias(m)) + args.flatten.map{|a| a.to_s} 
  end
  
  def system_command(m, *args, except: false, literal: false, out: nil, input: nil, err: nil)
    command = resolve_command(m, *args, literal: literal)
    command.unshift("sudo") if @superuser_mode
    opts = {out: out || $stdout, 
            err: err || $stderr, 
            in: input || $stdin, 
            exception: except || @superuser_mode,
            umask: @umask}

    system(*command, opts)
  end

end

require_relative "rash/redirection"
require_relative "rash/aliasing"
require_relative "rash/jobcontrol"
require_relative "rash/pipeline"
require_relative "rash/capturing"

$env = Environment.new


# note for later documentation: any aliases of cd must be functions, not 
# environmental aliases. Limitation of implementation.
def cd(dir = nil)
  d = dir
  case d
  when File, Dir
    d = d.path if File.directory?(d.path)
  end
  $env.chdir(d)
end

def pushd(dir = nil)
  case dir
  when File, Dir
    dir = dir.path if File.directory(dir.path)
  end
  $env.push_dir(dir)
end

def popd
  $env.pop_dir
end

def run(file, *args)
  filename = file.to_s
  exe = (filename.start_with?("/") ? filename : File.expand_path(filename.strip))
  unless File.executable?(exe)
    raise SystemCallError.new("No such executable file - #{exe}", Errno::ENOENT::Errno)
  end
  $env.dispatch(exe, *args, literal: true)
end

alias cmd __send__

# Defines `bash` psuedo-compatibility. Filesystem effects happen like normal 
# and environmental variable changes are copied
#
# This is an artifact of an old design and is deprecated until further notice.
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
  cmd = File.expand_path(command.to_s)
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

# This breaks some default IRB functionality
# def self.respond_to_missing?(m, *args)
#   
#   which(m.to_s) || ($env.alias?(m) && !$env.aliasing_disabled) || $env.local_method?(m) || super
# end

# Note that I defy convention and don't define `respond_to_missing?`. This
# is because doing so screws with irb.
def self.method_missing(m, *args, &block) 
  exe = which(m.to_s)
  if exe || ($env.alias?(m) && !$env.aliasing_disabled)
    $env.dispatch(m, *args)
  else
    super
  end
end

Process.setproctitle("rash")
run_command_file = "#{$env.HOME}/.rashrc"
load run_command_file if File.file?(run_command_file)
