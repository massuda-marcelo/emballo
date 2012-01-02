CodeHook is a library that provide a way to hook into functions and methods by rewriting
the first bytes of the code to redirect the call.

DisAsm32 is used by CodeHook.

Both CodeHook and DisAsm32 on this folder (Emballo\Third\) are the original versions
that I got. But I did some customizations on both libraries, the changed versions
can be found under the Emballo\Src\ folder.

This is what I changed:

* DisAsm32
  What I did was only to make the lib compatible with unicode versions of Delphi. The same
  unit should work on pre-unicode Delphi editions. I simply changed all references to Char
  to AnsiChar, and PChar to PAnsiChar. The only exception thas TTblItem.N (Line 934) which
  I kept as a Char.

* CodeHook
  This lib need overflow checking to be turned off in order to work. I like to have it
  always on on my projects, so I added this line of code:
  {$OverflowChecks OFF}

  Before the unit declaration of the unit CodeHook.pas, so overflow checks can be turned on
  for the whole project, and off only for the CodeHook unit

All the changes were sent back to the authors of each lib.