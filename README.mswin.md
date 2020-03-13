# Using Rice with Ruby mswin

If you want to use a library created in C++ using Visual Studio,  
you will use the Ruby mswin version.

Note: If you use RubyInstaller and RubyInstaller2, this document is not for you.

## Precondition

- Ruby mswin version
   - Perhaps, you need to compile Ruby from source file.
- Visual Studio 2017
- LLVM clang-cl
   - I installed and use LLVM-9.0.0-win64.exe which is from https://llvm.org/.

## Set the path

* setruby270mswin_llvm.bat
~~~ bat
set PATH=C:\rubymswin-2.7.0-1\usr\bin;C:\home\ruby_mswin\vcpkg\installed\x64-windows\bin;%PATH%;
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
set PATH=C:\Program Files\LLVM\bin;%PATH%
~~~

## Compile & Use

Use the Windows command prompt with the path set in the above batch file.

~~~ bat
  rake gem
  gem install pkg\rice-X.X.X.gem --local
~~~

## Run a sample

Use the Windows command prompt with the path set in the above batch file.

~~~ bat
  cd sample\inheritance
  ruby extconf.rb
  nmake
  nmake install
  ruby test.rb
~~~
