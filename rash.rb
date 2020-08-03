

class Environment 
  def initialize
    @working_directory = Dir.home
    @user = ENV['USER']
  end

  attr_reader :user

  def pwd
    @working_directory
  end

  def chdir(dir)
    Dir.chdir(dir)
    @working_directory = Dir.pwd
  end

end

$RASH_ENVIRONMENT = Environment.new

