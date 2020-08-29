class Environment
  attr_reader :prompt
  def standard_prompt=(prompt)
    @prompt[:prompt_i] = case prompt
                         when Proc
                           prompt
                         else
                           err_msg = "expecting stringable type or method that resolves to string"
                           raise ArgumentError.new(err_msg) unless prompt.respond_to?(:to_s)
                           lambda {prompt.to_s}
                         end
    @prompt[:PROMPT_I] = "".tap {|s| def s.dup; $env.prompt[:prompt_i].call; end}
  end

  def indent_prompt=(prompt)
    @prompt[:prompt_n] = case prompt
                         when Proc
                           prompt
                         else
                           err_msg = "expecting stringable type or method that resolves to string"
                           raise ArgumentError.new(err_msg) unless prompt.respond_to?(:to_s)
                           lambda {prompt.to_s}
                         end

    @prompt[:PROMPT_N] = "".tap {|s| def s.dup; $env.prompt[:prompt_n].call; end}
  end

  def string_prompt=(prompt)
    @prompt[:prompt_s] = case prompt
                         when Proc
                           prompt
                         else
                           err_msg = "expecting stringable type or method that resolves to string"
                           raise ArgumentError.new(err_msg) unless prompt.respond_to?(:to_s)
                           lambda {prompt.to_s}
                         end

    @prompt[:PROMPT_S] = "".tap {|s| def s.dup; $env.prompt[:prompt_s].call; end}
  end

  def continued_prompt=(prompt)
    @prompt[:prompt_c] = case prompt
                         when Proc
                           prompt
                         else
                           err_msg = "expecting stringable type or method that resolves to string"
                           raise ArgumentError.new(err_msg) unless prompt.respond_to?(:to_s)
                           lambda {prompt.to_s}
                         end

    @prompt[:PROMPT_C] = "".tap {|s| def s.dup; $env.prompt[:prompt_c].call; end}
  end

  # This method can only be run from .rashrc. Anywhere else and it will simply do nothing
  def return_value_header=(prompt)
    @prompt[:RETURN] = prompt
  end

  def use_irb_prompt
    if $0 == "irb"
      IRB.conf[:PROMPT][:RASH] = @prompt
      IRB.conf[:PROMPT_MODE] = :RASH
    end
  end
end

if $0 == "irb"
  IRB.conf[:PROMPT][:RASH] = {
    :PROMPT_I => "rash $",
    :PROMPT_N => "rash ",
    :PROMPT_S => "rash%l>",
    :PROMPT_C => "rash >",
    :RETURN => "%s\n" # used to printf
  }
  IRB.conf[:PROMPT_MODE] = :RASH
  IRB.conf[:SAVE_HISTORY] = 1000
  IRB.conf[:AP_NAME] = "rash"
end

