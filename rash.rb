class Environment
  
  DEFAULT_IO = {in: STDIN, out: STDOUT, err: STDERR}

  attr_accessor :prompt
  attr_reader :aliasing_enabled

  def initialize
    @working_directory = Dir.home
    @aliases = Hash.new
    @aliasing_enabled = true
    @prompt = {
      # Make this optionally a lambda or string
      # This works for affecting the string
      # :PROMPT_I => "%N(%m):%03n:%i %~> ".tap {|s| def s.dup; gsub('%~', Dir.pwd); end },
    }
  end

  def chdir(dir)
    Dir.chdir(dir)
    @working_directory = Dir.pwd
  end

  def method_missing(m, *args, &block) 
    if args.length == 0 
      self.define_singleton_method(m) do
        ENV[__method__.to_s.upcase]
      end
      self.send(m)
    else
      super
    end
  end

  def make_alias(new_func, old_func)
    @aliases[new_func.to_sym] = old_func.to_s.split(" ")
  end

  def clear_alias(func) 
    @aliases.delete(func.to_sym)
  end

  # recursive aliases not currently possible. In the works
  def resolve_alias(f)
    return [f.to_s] unless @aliasing_enabled

    result = [f]
    aliases = @aliases.dup
    aliased = true
    while aliased
      aliased = false
      if aliases.has_key?(result[0].to_sym)
        aliased = true
        match = result[0].to_sym
        result[0] = aliases[match]
        aliases.delete(match)
        result.flatten! 
      end
    end
    result
  end
 
  def alias?(f)
    @aliases.has_key?(f.to_sym)
  end

  def without_aliasing
    old_aliasing = @aliasing_enabled
    @aliasing_enabled = false
    if block_given?
      begin
        yield
      ensure
        @aliasing_enabled = old_aliasing
      end
    end
  end

  def with_aliasing
    old_aliasing = @aliasing_enabled
    @aliasing_enabled = true
    if block_given?
      begin
        yield
      ensure
        @aliasing_enabled = old_aliasing
      end
    end
  end


  # IO operations

  private

  class Directory
    def initialize(path)
      @path = path
    end

    def add_local_method(name, &block)
      self.define_method(name, &block)
    end

    def to_s
      @path
    end
  end


end
require_relative "lib/redirection"


$env = Environment.new

# note for later documentation: any aliases of cd must be functions, not 
# environmental aliases. Limitation of implementation.
def cd(dir=nil, *_junk)
  old = Dir.pwd
  if dir.nil? 
    $env.chdir(Dir.home)
  else
    $env.chdir(dir)
  end
  ENV["OLDPWD"] = old
  Dir.pwd
end

def run(filename, *args)
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
  if exe || ($env.alias?(m) && $env.aliasing_enabled)
    system(*$env.resolve_alias(m), *args.flatten.map{|a| a.to_s}, {out: $stdout, err: $stderr, in: $stdin})
  else
    super
  end
end



# IRB.conf[:PROMPT][:RASH] = {
#   :PROMPT_I => "rash   ",
#   :PROMPT_N => "rash-n ",
#   :PROMPT_S => "rash-s ",
#   :PROMPT_C => "rash-c ",
#   :RETURN => "%s\n" # used to printf
# }
# IRB.conf[:PROMPT_MODE] = :RASH
# IRB.conf[:SAVE_HISTORY] = 1000
# IRB.conf[:AP_NAME] = "rash"

run_command_file = "#{$env.HOME}/.rashrc"
require_relative run_command_file if File.file?(run_command_file)

