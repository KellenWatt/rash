# rash: Ruby Assimilated Shell
#### rash ain't sh

## FAQ

**Q.** *This isn't POSIX or `bash` compliant.*<br>
**A.**
1. That's not a question.
2. No, it isn't, and it's not supposed to be. Well it was supposed to be, but the idea of doing that 
simply was quickly shot to hell by the syntax of both languages. Solving that cleanly would have 
amounted to writing a parser for multiple langauges at once that could automatically distinguish 
between the two, but also treat them the same. Ruby's function-call syntax (one of the big reasons 
using it as a shell might be handy) made this less than reasonable. 

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
user manual for more information.




<!--
TODO:
caller
command
mapfile
    - readarray
source - eval

### Complex
option parser - OptionParser.parse(args)
    - shift
ulimit

job control
completion

File system pseudo-emulation. Class for each directory, which can take custom
defined methods. 
-->

<!--
### Design decisions
explicitly ignoring directory stack (pushd, popd, dirs). But maybe not

explicitly ignoring readonly, as it goes against Ruby variable philosophy



-->
