Gem::Specification.new do |s|
  s.name = "rash-command-shell"
  s.version = "0.4.0"
  s.date = "2020-08-29"
  s.summary = "Rash Ain't SH"
  s.description = "A Ruby-based command shell"
  s.homepage = "https://github.com/KellenWatt/rash"
  s.authors = ["Kellen Watt"]
  
  s.files = [
    "lib/rash.rb",
    "lib/rash/aliasing.rb",
    "lib/rash/jobcontrol.rb",
    "lib/rash/redirection.rb",
    "lib/rash/prompt/irb.rb",
    "lib/rash/ext/filesystem.rb",
    "lib/rash/pipeline.rb",
    "lib/rash/capturing.rb"
  ]
  s.add_runtime_dependency("irb", "~> 1.2")

  s.bindir = "bin"
  s.executables << "rash"

  s.license = "MIT"

  s.required_ruby_version = Gem::Requirement.new(">= 2.5") # Implied by irb
end
