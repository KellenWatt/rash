class Environment
  def jobs
    @active_jobs.keep_if {|pid| Process.kill(0, pid) rescue false}
  end

  def async(&block)
    pid = fork {
      block.call
      exit!(true)
    }
    @active_jobs << pid
    Process.detach(pid)
    pid
  end
end

def as_background(&block)
  $env.async(&block)
end
  

