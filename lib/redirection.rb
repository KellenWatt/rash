class Environment

  DEFAULT_IO = {in: STDIN, out: STDOUT, err: STDERR}

  def reset_io
    reset_stdout
    reset_stderr
    reset_stdin
  end

  def stdout=(file)
    $stdout.flush
    old_stdout = $stdout
    case file
    when String
      $stdout = File.new(file, "w")
    when :out
      $stdout = STDOUT
    when :err
      $stdout = STDERR
    else
      raise ArgumentError.new("not an output stream - #{file}") unless file.is_a?(IO)
      $stdout = file
    end
    old_stdout.close unless standard_stream?(old_stdout)
  end

  def reset_stdout
    $stdout.flush
    $stdout.close unless standard_stream?($stdout)
    $stdout = DEFAULT_IO[:out]
  end

  def stderr=(file)
    $stderr.flush
    old_stderr = $stderr
    case file
    when String
      $stderr = File.new(file, "w")
    when :out
      $stderr = STDOUT
    when :err
      $stderr = STDERR
    else
      raise ArgumentError.new("not an output stream - #{file}") unless file.is_a?(IO)
      $stderr = file
    end
    old_stderr.close unless standard_stream?(old_stderr)
  end
  
  def reset_stderr
    $stderr.flush
    $stderr.close unless standard_stream?($stderr)
    $stderr = DEFAULT_IO[:err]
  end

  def stdin=(file)
    old_stdin = $stdin
    case file
    when String
      $stdin = File.new(file, "r")
    when :in
      $stdin = STDIN
    else
      raise ArgumentError.new("not an input stream - #{file}") unless file.is_a?(IO)
      $stdin = file
    end
    old_stdin.close unless standard_stream?(old_stdin)
  end

  def reset_stdin
    $stdin.close unless standard_stream>($stdin)
    $stdin = DEFAULT_IO[:in]
  end

  private
  
  def standard_stream?(f)
    DEFAULT_IO.values.include?(f)
  end
end

# If you want to append, you need to get the file object yourself.
# Check if not flushing immediately is a concern. If so, set $stdout.sync for files
def with_stdout_as(file = STDOUT)
  $env.stdout = file
  if block_given?
    begin
      yield $stdout
    ensure
      $env.reset_stdout
    end
  end
end

def with_stderr_as(file = STDERR)
  $env.stderr = file
  if block_given?
    begin
      yield $stderr
    ensure
      $env.reset_stderr
    end
  end 
end

def with_stdin_as(file = STDIN)
  $env.stdin = file
  if block_given?
    begin
      yield $stdin
    ensure
      $env.reset_stdin
    end
  end
end

def with_stdout_as_stderr
  $env.stdout = $stderr
  if block_given?
    begin
      yield $stdout
    ensure
      $env.reset_stdout
    end
  end
end

def with_stderr_as_stdout
  $env.stderr = $stdout
  if block_given?
    begin
      yield $stderr
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
      yield $stdout
    ensure
      $env.reset_stdout
      $env.reset_stderr
    end
  end
end
