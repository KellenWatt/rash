class Environment

  def pipelined?
    @in_pipeline
  end

  def synced_pipeline?
    @in_pipeline && @synchronous_pipeline
  end

  def make_pipeline(&block) 
    raise IOError.new("pipelining already enabled") if @in_pipeline
    start_pipeline
    begin
      block.call
    ensure
      end_pipeline
    end
    nil
  end

  def make_sync_pipeline(&block)
    raise IOError.new("pipelining already enabled") if @in_pipeline
    start_sync_pipeline
    begin
      block.call
    ensure
      end_sync_pipeline
    end
    nil
  end
  
  def as_pipe_command(&block)
    raise IOError.new("pipelining not enabled") unless @in_pipeline
    
    input = (@active_pipelines.empty? ? $stdin : @active_pipelines.last.reader)
    @active_pipelines << Pipeline.new
    output = @active_pipelines.last.writer
    error = ($stderr == $stdout ? output : $stderr)

    pid = fork do
      @in_pipeline = false
      $stdin = input
      $stdout = output
      $stderr = error
      block.call
      output.close
      exit!(true)
    end
    output.close

    @active_pipelines.last.link_process(pid)
    nil
  end

  private
  
  def start_pipeline
    @in_pipeline = true
  end

  def start_sync_pipeline
    @in_pipeline = true
    @synchronous_pipeline = true
    @first_sync_command = true
    @prev_pipe = Pipeline.new
    @next_pipe = Pipeline.new
  end

  def end_pipeline
    raise IOError.new("pipelining not enabled") unless @in_pipeline
    @in_pipeline = false
    if @active_pipelines.size > 0
      begin
        Process.wait(@active_pipelines.last.pid)
        @active_pipelines.last.writer.close # probably redundant, but leaving it for now
        IO.copy_stream(@active_pipelines.last.reader, $stdout)
        @active_pipelines.pop.close
        @active_pipelines.reverse_each {|pipe| pipe.terminate}
      ensure
        @active_pipelines.clear
      end
    end
  end

  def end_sync_pipeline
    raise IOError.new("pipelining not enabled") unless @in_pipeline
    raise IOError.new("pipeline is not synchronous") unless @synchronous_pipeline
    @next_pipe.close
    @prev_pipe.writer.close
    IO.copy_stream(@prev_pipe.reader, $stdout)
    @prev_pipe.close

    @next_pipe = @prev_pipe = @first_sync_command = nil
    @synchronous_pipeline = @in_pipeline = false
  end

  # special method to be referenced from Environment#dispatch. Do not use directly
  def add_pipeline(m, *args)
    raise IOError.new("pipelining not enabled") unless @in_pipeline
    return add_sync_pipeline if @synchronous_pipeline

    input = (@active_pipelines.empty? ? $stdin : @active_pipelines.last.reader)
    @active_pipelines << Pipeline.new
    output = @active_pipelines.last.writer
    error = ($stderr == $stdout ? output : $stderr)
    pid = fork do # might not be necessary, spawn might cover it. Not risking it before testing
      system_command(m, *args, out: output, input: input, err: error, except: true)
      output.close
      exit!(true)
    end
    output.close
    @active_pipelines.last.link_process(pid)
  end

  def add_sync_pipeline(m, *args)
    raise IOError.new("pipelining not enabled") unless @in_pipeline
    raise IOError.new("pipeline is not synchronous") unless @synchronous_pipeline

    # Ensure pipe is empty for writing
    @next_pipe.reader.read

    input = (@first_sync_command ? $stdin : @prev_pipe.reader)
    @first_sync_command = false
    error = ($stderr == $stdout ? @next_pipe.writer)
    system_command(m, *args, out: @next_pipe.writer, input: input, err: error, except: true)
    @prev_pipe, @next_pipe = @next_pipe, @prev_pipe
  end

  class Pipeline
    attr_reader :writer, :reader, :pid

    def initialize
      @reader, @writer = IO.pipe
    end

    def link_process(pid)
      @pid ||= pid
      self
    end

    def close
      @writer.close
      @reader.close
    end

    def terminate
      self.close
      Process.kill(:TERM, @pid)
      Process.wait(@pid)
    end

    def to_s
      @pid
    end
  end
end


def in_pipeline(async: true, &block)
  if async
    $env.make_pipeline(&block)
  else
    $env.make_sync_pipeline(&block)
  end
end
