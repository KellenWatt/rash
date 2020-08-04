class Environment 
  def initialize
    @working_directory = Dir.home
    @aliases = Hash.new
  end

  def chdir(dir)
    Dir.chdir(dir)
    @working_directory = Dir.pwd
  end

  def method_missing(m, *args, &block) 
    if args.length == 0 
      self.define_singleton_method(m) do
        ENV[__method__.to_s]
      end
      self.send(m)
    else
      super
    end
  end

  attr_reader :aliases

  def make_alias(new_func, old_func)
    @aliases[new_func.to_sym] = old_func.to_sym
  end

  def clear_alias(func) 
    @aliases.delete(func.to_sym)
  end

  def resolve_alias(f)
    al = f.to_sym
    if @aliases.include?(al)
      @aliases[al]
    else
      al
    end
  end

end

$env = Environment.new

alias logout exit


# alias unalias remove_method



def cd(dir=nil, *junk)
  if dir.nil? 
    $env.chdir(Dir.home)
  else
    $env.chdir(dir)
  end
end

def run(filename)
  exe = filename.chomp
  if exe[0] != '/'
    exe = "./#{exe}"
  end
  `#{exe}`
end

def sourcesh(file) 
  
end

def self.method_missing(m, *args, &block) 
  puts m
  super if system("#{$env.resolve_alias(m)} #{args.join(" ")}").nil?
end

