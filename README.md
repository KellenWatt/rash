# rash: Ruby Assimilated Shell
#### --OR-- Rash Ain't sh

## What is this?

It's pretty much in the titles. rash is a shell, but it's only distantly 
related to `sh` or any of its descendants. Instead it's designed to work within 
the existing framework that is the Ruby language, with all the power and 
expressiveness that provides.

## How does it work?
The first thing you need to know is that rash *is* Ruby. It's just a library 
that builds on top of the existing Ruby language. As such, you can expect it to 
behave like Ruby for most practical purposes. The one caveat to this is that
since it requires a bit of meta-programming to reach out and run arbitrary 
executables, as well as a few of the other feature, some things that you might 
expect to fail might not. That said, since Ruby is fundamental to running the 
shell itself, its core functionality and standard library are respected at all 
times. Therfore, almost any script you write in regular Ruby will work as 
expected with rash.


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

## FAQ

**Q.** *This isn't POSIX or `bash` compliant.*<br>
**A.** Two things:
1. That's not a question.
2. No, it isn't, and it's not supposed to be. Well, it was supposed to be, but the idea of doing that 
easily was quickly shot to hell by the syntax of both languages. Solving that cleanly would have 
amounted to writing a parser for multiple langauges at once that could automatically distinguish 
between the two, but also treat them the same. Ruby's function-call syntax (one of the big reasons 
using it as a shell might be handy) made this less than reasonable. <br><br>
I did have an idea for something that worked via Haskell-style currying to approximate bash syntax. 
I explored this briefly, but I couldn't find a way for that to work without way more effort than 
it's worth. Plus, it would significantly affect how Ruby works (i.e. most semantic expectations 
would be subverted, which is a terrible idea for any language<!--*cough* PHP *cough* Javascript *cough*-->). 
If anyone has any ideas of how to do this without affecting how Ruby works on a fundamental 
level, feel free to make a pull request.

**Q.** *So What is this exactly?*<br>
**A.**
It's a shell, but it's Ruby. Mostly the latter, based primarily on `irb` (though there's nothing 
significant stopping it from being used in a general script), with a few extra things going on 
under the hood to make using it as a shell not awkward. It also introduces the concept of 
directory-local functions, which is extremely useful for a variety of applications. Refer to the 
(*as-of-yet* non-existant) user manual for more information.




<!--
TODO:

### Complex
completion

As a later feature, some local functions may be marked as non-inherited, in which 
case the only place they will be available is where they are declared.



-->

<!--
### Design decisions
explicitly ignoring directory stack (pushd, popd, dirs). But maybe not

explicitly ignoring readonly, as it goes against Ruby variable philosophy
-->
