class Environment
  def make_alias(new_func, old_func)
    @aliases[new_func.to_sym] = old_func.to_s.split(" ")
  end

  def clear_alias(func) 
    @aliases.delete(func.to_sym)
  end

  # recursive aliases not currently possible. In the works
  def resolve_alias(f)
    result = [f.to_s]
    aliases = @aliases.dup
    found_alias = true
    while found_alias
      found_alias = false
      if aliases.has_key?(result[0].to_sym)
        found_alias = true
        match = result[0].to_sym
        result[0] = aliases[match]
        aliases.delete(match)
        result.flatten! 
      end
    end
    result
  end
 
  def alias?(f)
    @aliases.has_key?(f.to_sym)
  end

  def without_aliasing
    old_aliasing = @aliasing_disabled
    @aliasing_disabled = true
    if block_given?
      begin
        yield
      ensure
        @aliasing_disabled = old_aliasing
      end
    end
  end

  def with_aliasing
    old_aliasing = @aliasing_disabled
    @aliasing_disabled = false
    if block_given?
      begin
        yield
      ensure
        @aliasing_disabled = old_aliasing
      end
    end
  end
end
