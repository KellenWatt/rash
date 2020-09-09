class Environment

  def pipelined?
    @in_pipeline
  end

  def start_pipeline
    @in_pipeline = true
  end

  def end_pipeline
    @in_pipeline = false
    if @active_pipelines.size > 0
      Process.wait(@active_pipelines.last.pid)
      @active_pipelines.last.writer.close # probably redundant, but leaving it for now
      IO.copy_stream(@active_pipelines.last.reader, $stdout)
      @active_pipelines.pop.close
      @active_pipelines.reverse_each {|pipe| pipe.terminate}
      @active_pipelines.clear
    end
  end

  def add_pipeline(m, *args)
    input = (@active_pipelines.empty? ? $stdin : @active_pipelines.last.reader)
    @active_pipelines << Pipeline.new
    output = @active_pipelines.last.writer
    error = ($stderr == $stdout ? output : $stderr)
    pid = fork do # might not be necessary, spawn might cover it. Not risking it before testing
      system(*$env.resolve_alias(m), *args.flatten.map{|a| a.to_s}, {out: output, in: input, err: error, exception: true, umask: @umask})
      output.close
      exit!(true)
    end
    output.close
    @active_pipelines.last.link_process(pid)
  end

  def as_pipe(&block)
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
  end

  private

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
      Process.kill(:PIPE, @pid)
      Process.wait(@pid)
    end

    def to_s
      @pid
    end
  end
end


def in_pipeline(&block) 
  raise IOError.new("pipelining already enabled") if $env.pipelined?
  $env.start_pipeline
  begin
    block.call
  ensure
    $env.end_pipeline
  end
end
