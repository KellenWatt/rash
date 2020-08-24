# rash: Ruby Assimilated Shell
#### rash ain't sh

## FAQ

**Q.** *This isn't POSIX or `bash` compliant.*<br>
**A.**
1. That's not a question.
2. No, it isn't, and it's not supposed to be. Well it was supposed to be, but the idea of doing that 
simply was quickly shot to hell by the syntax of both languages. Solving that would have amounted 
to writing a parser for multiple langauges at once that could automatically distinguish between the 
two, but also treat them the same. Ruby's function-call syntax (one of the big reasons using it as 
a shell might be handy) made this less than reasonable. <del>However, I do have an idea for something 
that works via Haskell-style currying to approximate bash syntax.</del> *Explored this, won't work 
without way more than is necessary. Plus, ROI is really bad, and it would significanlty affect 
how Ruby works (i.e. some syntax rules are broken).*

**Q.** *So What is this exactly?*<br>
**A.**
It's a shell, but it's Ruby. Mostly the latter, with a few additions to make using it as a shell 
not awkward. It also introduces the concept of directory-local functions, which is extremely 
useful for a variety of applications.




<!--
TODO:
trap - Signal.trap
    - Maybe signals
umask - maintain default permissions
caller
command
mapfile
    - readarray
source - eval

### Complex
option parser - OptionParser.parse(args)
    - shift
declare
ulimit

job control
completion

-->

<!--
### Design decisions
explicitly ignoring directory stack (pushd, popd, dirs)

explicitly ignoring readonly, as it goes against Ruby variabel philosophy

complex aliases not an option.
alias - already built in
    - builtin


File system pseudo-emulation. Class for each directory, which can take custom
defined methods. 

-->
