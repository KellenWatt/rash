Gem::Specification.new do |s|
  s.name = "rash-command-shell"
  s.version = "0.1.0"
  s.date = "2020-08-29"
  s.summary = "Rash Ain't SH"
  s.description = "A Ruby-based shell"
  s.homepage = "https://github.com/KellenWatt/rash"
  s.authors = ["Kellen Watt"]
  
  s.files = [
    "lib/rash.rb",
    "lib/rash/aliasing.rb",
    "lib/rash/jobcontrol.rb",
    "lib/rash/redirection.rb",
    "lib/rash/prompt/irb.rb",
    "lib/rash/ext/filesystem.rb"
  ]
  s.add_runtime_dependency("irb", "~> 1.2", ">= 1.2.0")

  s.bindir = "bin"
  s.executables << "rash"

  s.license = "MIT"

  # s.required_ruby_version = Gem::Requirement.new(">= 2.7")
end
