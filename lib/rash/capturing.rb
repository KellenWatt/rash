class Environment
  def capture_block(&block)
    raise ArgumentError.new("no block provided") unless block_given?
    result = nil
    old_pipeline = @in_pipeline
    begin
      reader, writer = IO.pipe
      self.stdout = writer
      @in_pipeline = false
      block.call
    ensure
      @in_pipeline = old_pipeline
      reset_stdout
      writer.close
      result = reader.read
      reader.close
    end
    result
  end

  def capture_command(m, *args)
    raise NameError.new("no such command", m) unless which(m) || ($env.alias?(m) && !$env.aliasing_disabled)
    result = nil
    begin 
      reader, writer = IO.pipe
      system_command(m, *args, out: writer)
    ensure
      writer.close
      result = reader.read
      reader.close
    end
    result
  end
end

# This explicitly doesn't support pipelining, as the output is ripped out of sequence.
def capture(*cmd, &block)
  if block_given?
    $env.capture_block(&block)
  elsif cmd.size > 0 && (which(cmd[0]) || ($env.alias?(m) && !$env.aliasing_disabled))
    $env.capture_command(cmd[0].to_s, *cmd[1..])
  else
    raise ArgumentError.new("nothing to capture from")
  end
end
