# Rash: Ruby-Assimilated Shell
### *or* Rash Ain't sh

## What is Rash?

It's pretty much in the titles. Rash is a command shell, but it's only distantly 
related to sh or any of its descendants. Instead it's designed to work within 
the existing framework that is the Ruby language, with all the power and 
expressiveness that provides.

The most important thing you need to know is that Rash *is* Ruby. Its core is 
just a library that builds on top of the existing Ruby language, without 
fundamentally altering it. As such, you can expect it to behave like Ruby for 
most practical purposes. Since Ruby is fundamental to running the shell itself, 
its core functionality and standard library are respected at all times. Therefore, 
almost any script you write in regular Ruby will work as expected with Rash.

## Installation
You can install Rash just like any other Ruby gem, either as a part of your project
or as a standalone.

To get the library and standalone executable run this:
```bash
$ gem install rash-command-shell
```

For an application using bundle, add this line to your Gemfile:
```ruby
gem "rash-command-shell"
```
then run `bundle` to update your project.

## Requirements
- Ruby, obviously. This has been tested with 2.7.1, but it should work as intended 
for earlier versions of Ruby that aren't too old.

- `irb (~> 1.2)` - not actually used directly in core Rash but it ensures the user has 
IRB installed. This is only required for interactive mode, which uses IRB by default.

## Usage 

Like most shell programs it can be run in execution and interactive modes. For 
details on how to use Rash's features, see the [wiki](https://github.com/KellenWatt/rash/wiki/Rash).

### Interactive mode
This is just calling `rash` from whatever your current shell is. This will run a new
instance of Rash, and you can do whatever you like from there.

This mode works a lot like IRB because, well, it is IRB. You can treat it as such 
without worrying too much.

### Execution mode
This mode is when you pass a script file and possibly some arguments to the command.

To run a file, you provide whatever file you want to run, then provide any arguments 
after that.

This can also be done by directly executing a script file, with this shebang
line at the top:
```ruby
#!/usr/bin/env rash
```
You can, of course, use the actual path of Rash, but this version is more portable, 
and much easier to read.

The recommended extension for Rash script files is `.rh`, to distinguish it from a 
pure Ruby script, but `.rb` is perfectly acceptable. If you use `.rb` for a Rash 
script, you may want to write a note that distinguishes it from a normal Ruby 
script, if applicable.

## Contributing
Bug reports and pull requests are welcome on [GitHub](https://github.com/KellenWatt/rash).

## Licensing
This code is licensed under the MIT License.

<!--
## Miscellany

### POSIX compliance
This isn't POSIX or Bash compliant, and it's not supposed to be. Well, it was 
supposed to be while it was still in concept, but the idea of doing that within 
reason was quickly shot to hell by the syntax of both languages. Solving that 
cleanly would have amounted to writing an interpreter for both langauges at once 
that could automatically distinguish between the two, but also know to treat them 
the same. Ruby and Bashe's function-call syntax made this less than reasonable.

Once upon a time, I did have an idea for something that worked via Haskell-style 
currying to approximate Bash syntax. I explored that briefly, but I couldn't find 
a way to accomplish that without significantly affecting how Ruby worked on a 
fundamental, semantic level. 

If a design arises at some point that is both Bash and Ruby compliant, I'll consider 
moving towards that, but until then, that's a dead idea.



### Naming

When a name is resolved at global level, it has the following precedence
1. Ruby-defined names. This includes Ruby keywords, and any functions defined 
on `Kernel` and `Object`.
2. Locally-defined functions
3. Environment-defined aliases (as opposed to Ruby-defined aliases)
4. Executable files in `$PATH`

For example, OSX platforms have the `say` executable, which outputs the given text 
through the speaker. If I typed `say` in the shell, it would first check if there 
was a globally-defined function called `say`. Failing that, it would check for a 
local function. If neither of those exist, it checks if it is an Environment-defined 
alias. Once it is determined that it's none of those, we search for a `say` 
executable in `$PATH`. The shell finds this, and executes it with the given arguments.

If I were to define a local function called `say`, then, in the scope that function 
is valid, it would be preferred over the executable file.

Note that this has no effect on methods declared on objects or classes that aren't 
`Object`, `Kernel`, or the irb `"main"` object.
-->





<!--
TODO:

### Complex
completion

-->

<!--
### Design decisions
explicitly ignoring directory stack (pushd, popd, dirs). But maybe not

explicitly ignoring readonly, as it goes against Ruby variable philosophy
-->
