class Environment 
  def initialize
    @working_directory = Dir.home
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
end

$env = Environment.new

def cd(dir=nil, *junk)
  if dir.nil? 
    $env.chdir(Dir.home)
  else
    $env.chdir(dir)
  end
end

def run(filename)
  exe = filename.chomp
  if filename[0] != '/'
    exe = "./#{exe}"
  end
  `#{exe}`
end

def sourcesh(file) 
  
end

def self.method_missing(m, *args, &block) 
  puts m
  super if system("#{m} #{args.join(" ")}").nil?
end
