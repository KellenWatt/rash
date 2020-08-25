class Environment
  
  DEFAULT_IO = {in: STDIN, out: STDOUT, err: STDERR}

  attr_reader :aliases
  attr_accessor :prompt

  def initialize
    @working_directory = Dir.home
    @aliases = Hash.new
    @default_permissions
    @prompt = {
      # Make this optionally a lambda or string
      # This works for affecting the string
      # :PROMPT_I => "%N(%m):%03n:%i %~> ".tap {|s| def s.dup; gsub('%~', Dir.pwd); end },
    }
    reset_io
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
    @aliases[new_func.to_sym] = old_func.to_sym
  end

  def clear_alias(func) 
    @aliases.delete(func.to_sym)
  end

  # recursive aliases not currently possible. In the works
  def resolve_alias(f)
    al = f.to_sym
    if @aliases.include?(al)
      @aliases[al]
    else
      f
    end
  end
  

  # IO operations

  def reset_io
    reset_stdout
    reset_stderr
    reset_stdin
  end
  
  def stdout=(file)
    $stdout.flush
    case file
    when String
      $stdout = @stdout = File.new(file, "w")
    when :out
      $stdout = @stdout = STDOUT
    when :err
      $stdout = @stdout = STDERR
    else
      raise ArgumentError.new("not an output stream - #{file}") unless file.is_a?(IO)
      $stdout = @stdout = file
    end
  end

  def reset_stdout
    $stdout.flush
    $stdout = @stdout = DEFAULT_IO[:out]
  end

  def stderr=(file)
    $stderr.flush
    case file
    when String
      $stderr = @stderr = File.new(file, "w")
    when :out
      $stderr = @stderr = STDOUT
    when :err
      $stderr = @stderr = STDERR
    else
      raise ArgumentError.new("not an output stream - #{file}") unless file.is_a?(IO)
      $stderr = @stderr = file
    end
  end
  
  def reset_stderr
    $stderr.flush
    $stderr = @stderr = DEFAULT_IO[:err]
  end

  def stdin=(file)
    case file
    when String
      $stdin = @stdin = File.new(file, "r")
    when :in
      $stdin = @stdin = STDIN
    else
      raise ArgumentError.new("not an input stream - #{file}") unless file.is_a?(IO)
    end
  end

  def reset_stdin
    $stdin = @stdin = DEFAULT_IO[:in]
  end

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

def run(filename)
  exe = filename.chomp
  if exe[0] != '/'
    exe = "./#{exe}"
  end
  `#{exe}`
end

# Defines `bash` psuedo-compatibility. Filesystem effects happen like normal 
# and environmentl changes are copied
def sourcesh(file) 
  bash_env = lambda do |cmd = nil|
    tmpenv = `#{cmd + ';' if cmd} printenv`
    tmpenv.split("\n").grep(/[a-zA-z0-9_]+=.*/).map {|l| l.split("=")}
  end
  bash_source = lambda do |f|
    Hash[bash_env.call("source #{File.realpath f}") - bash_env.()]
  end

  bash_source.call(file).each {|k,v| ENV[k] = v if k != "SHLVL" && k != "_"}
end

# Note that I defy convention and don't define `respond_to_missing?`. This
# is because doing so as-is would involve running the command itself, which 
# would be 1) probably very slow, and 2) potentially dangerous if the command 
# has side effects.
def self.method_missing(m, *args, &block) 
  puts m
  super if system("#{$env.resolve_alias(m)} #{args.join(" ")}").nil?
end


# If you want to append, you need to get the file object yourself.
# Check if not flushing immediately is a concern. If so, set $stdout.sync for files
def with_stdout_as(file = STDOUT)
  $env.stdout = file
  if block_given?
    begin
      yield
    ensure
      $env.reset_stdout
    end
  end
end

def with_stderr_as(file = STDERR)
  $env.stderr = file
  if block_given?
    begin
      yield
    ensure
      $env.reset_stderr
    end
  end 
end

def with_stdin_as(file = STDIN)
  $env.stdin = file
  if block_given?
    begin
      yield
    ensure
      $env.reset_stdin
    end
  end
end

def with_stdout_as_stderr
  $env.stdout = $stderr
  if block_given?
    begin
      yield
    ensure
      $env.reset_stdout
    end
  end
end

def with_stderr_as_stdout
  $env.stderr = $stdout
  if block_given?
    begin
      yield
    ensure
      $env.reset_stderr
    end
  end
end

def with_all_out_as(file)
  $env.stdout = file
  $env.stderr = $stdout
  if block_given?
    begin
      yield
    ensure
      $env.reset_stdout
      $env.reset_stderr
    end
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

