class Environment

  RASH_LOCAL_FILE = ".rashrc.local"

  # Has to be a better way of adding extensions and dynamically loading them
  def initialize
    common_init
    @working_directory = Directory.root("/") 
    traverse_filetree("/", Dir.pwd)
  end

  def chdir(dir = nil)
    old = @working_directory
    traverse_filetree(Dir.pwd, (dir.nil? ? "~" : dir.to_s))
    ENV["OLDPWD"] = old.to_s
    ENV["PWD"] = Dir.pwd
    Dir.pwd
  end

  def local_def(name, locked: false, &block)
    @working_directory.add_local_method(name, &block)
    @working_directory.lock_method(name) if locked
    name.to_sym
  end

  def local_undef(name)
    @working_directory.clear_local_method(name)
  end

  def local_method?(name)
    @working_directory.local_method?(name)
  end

  def local_methods
    @working_directory.local_methods
  end

  def local_call(name, *args, &block)
    @working_directory.local_method(name).call(*args, &block)
  end

  def local_var(name, v = nil)
    if v.nil?
      @working_directory.local_variable(name)
    else
      @working_directory.set_local_variable(name, v)
    end
  end

  private

  # from and to are strings
  def traverse_filetree(from, to)
    abs_from = File.expand_path(from)
    abs_to = File.expand_path(to)
    raise SystemCallError.new(from, Errno::ENOENT::Errno) unless Dir.exists?(abs_from) 
    raise SystemCallError.new(to, Errno::ENOENT::Errno) unless Dir.exists?(abs_to)
    
    from_parts = (abs_from == "/" ? [""] : abs_from.split(File::SEPARATOR))
    to_parts = (abs_to == "/" ? [""] : abs_to.split(File::SEPARATOR))
    common_path = from_parts.filter.with_index {|p, i| p == to_parts[i]}
    
    from_parts = from_parts.drop(common_path.size)
    to_parts = to_parts.drop(common_path.size)

    from_parts.each do |p|
      @working_directory.add_parent(File.expand_path("..")) if @working_directory.root?
      @working_directory = @working_directory.parent
      Dir.chdir(@working_directory.to_s)
    end

    to_parts.each do |p|
      @working_directory = @working_directory.child(File.expand_path(p, @working_directory.to_s))
      Dir.chdir(@working_directory.to_s)
      # rashrc_local = @working_directory.to_s + File::SEPARATOR + RASH_LOCAL_FILE
      load RASH_LOCAL_FILE if File.exists?(RASH_LOCAL_FILE) && !File.directory?(RASH_LOCAL_FILE)
    end
  
    Dir.pwd
  end

  class Directory
    attr_reader :parent, :children

    def self.root(dir)
      Directory.new(nil, dir)
    end

    def initialize(parent, dir)
      @path = Dir.new(dir)
      @parent = parent
      @children = []
      @local_methods = parent&.unlocked_local_methods || {}
      @locked_methods = []
      @local_variables = parent&.unlocked_local_variables || {}
      @locked_varaibles = []
    end

    def local_method(name)
      @local_methods[name.to_sym]
    end

    def local_methods
      @local_methods.keys
    end

    def unlocked_local_methods
      @local_methods.filter{|k, v| !@locked_methods.include?(k)}
    end

    def lock_method(name)
      n = name.to_sym
      raise NameError.new("#{name} is not a local method", n) unless @local_methods.key?(n)
      @locked_methods << n unless @locked_methods.include?(n)
      n
    end

    def local_method?(name)
      @local_methods.key?(name.to_sym)
    end

    def local_variable(name)
      @local_variables[name]
    end

    def local_variables
      @local_variables.keys
    end

    def set_local_variable(name, value)
      @local_variables[name] = value
    end

    def unlocked_local_variables
      @local_variables.filter{|k, v| !@locked_variables.include?(k)}
    end

    def lock_variable(name)
      n = name.to_sym
      raise NameError.new("#{name} is not a local variable", n) unless @local_variables.key?(n)
      @locked_variables << n unless @locked_variables.include?(n)
      n
    end

    def local_variable?(name)
      @local_variables.include?(name)
    end

    def clear_local_varaible(name)
      @local_varaibles.delete(name.to_sym)
      name.to_sym
    end

    def root?
      parent.nil?
    end

    def add_parent(dir)
      @parent = Directory.root(dir)
      @parent.add_child(self.to_s)
      @parent
    end

    def child(path)
      ch = @children.find {|c| c.to_s == path}
      ch = add_child(path) unless ch
      ch
    end

    def add_child(path)
      dir = Directory.new(self, path)
      @children << dir
      dir
    end

    def add_local_method(name, &block)
      raise ArgumentError.new "no method body provided" unless block_given?
      @local_methods[name.to_sym] = block # if name already exists, its function is overriden
      name.to_sym
    end

    # might not be useful
    def clear_local_method(name)
      @local_methods.delete(name.to_sym)
      name.to_sym
    end

    def to_s
      @path.path
    end
  end
end

# still could absolutely be more cleaned up, but it works
def self.method_missing(m, *args, &block)
  exe = which(m.to_s)
  if $env.local_method?(m)
    $env.local_call(m, *args, &block)
  elsif exe || ($env.alias?(m) && !$env.aliasing_disabled)
    $env.dispatch(m, *args)
  else
    super
  end
end

$env = Environment.new
