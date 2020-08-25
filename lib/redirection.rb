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
