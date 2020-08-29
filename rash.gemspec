Gem::Specification.new do |s|
  s.name = "rash"
  s.version = "0.1.0"
  s.date = "2020-08-29"
  s.summary = "Rash Aint SH"
  s.description = "A Ruby-based shell"
  s.homepate = "https://github.com/KellenWatt/rash"
  s.authors = ["Kellen Watt"]
  s.files = [
    "lib/rash.rb",
    "lib/rash/prompt/irb.rb",
    "lib/rash/ext/filesystem"
  ]

  s.bindir = "bin"
  s.executables = ["rash"]

  s.license = "MIT"

  # s.required_ruby_version = Gem::Requirement.new(">= 2.7")
end
