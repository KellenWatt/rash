# rash: Ruby Assimilated Shell
#### rash ain't sh

## FAQ

**Q.** *This isn't POSIX or `sh` compliant.*
**A.**
1. That's not a question
2. No, it isn't, and it's not supposed to be. Well it was supposed to be, but the idea of doing that 
simply was quickly shot to hell by the syntax of both languages. Solving that would have amounted 
to writing a parser for multiple langauges at once that could automatically distinguish between the 
two. Ruby's function-call syntax (one of the big reasons using it as a shell might be handy) made this 
less than reasonable. However, I do have an idea for something that works via Haskell-style currying 
to approximate bash syntax.


<!--
TODO:
cd - maintain cwd
trap - Signal.trap
    - Maybe signals
eval - builtin, kind of
exec - Kernel#exec
exit - exit
    - logout - exit
pwd - print cwd
readonly - variable array type
times 
    - prints times
umask - maintain default permissions
alias - already built in
    - builtin
    - unalias - remove_method
caller
command
echo - puts
enable
help
mapfile
    - readarray
printf - printf
read 
source - eval
type

### Complex
option parser - OptionParser.parse(args)
    - shift
hash
`test` options
declare
ulimit
set
    - unset
accept '-' and double dash

job control
history
completion

-->

<!--
### Design decisions
explicitly ignoring directory stack (pushd, popd, dirs)

-->
