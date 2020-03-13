# extconf_mswin.rb

### Top Makefile

makefile = <<"MAKEFILE"
all:
	pushd ..\\ext & $(MAKE) /nologo /$(MAKEFLAGS) all & popd

clean:
	pushd ..\\ext & $(MAKE) /nologo /$(MAKEFLAGS) clean & popd

install:
	pushd ..\\ext & $(MAKE) /nologo /$(MAKEFLAGS) install & popd

.PHONY: all clean install
MAKEFILE

f = File.open("Makefile", mode="w")
f.write(makefile)

#-----------------------------------------
### CMakeLists.txt

cmakeliststxt = <<"CMAKELISTSTXT"
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "DO NOT BUILD in-tree.")
endif()

cmake_minimum_required (VERSION 3.12)

enable_language(CXX)
set(CMAKE_CXX_STANDARD 14)

project(rice)
add_subdirectory(rice)
CMAKELISTSTXT

f = File.open("../CMakeLists.txt", mode="w")
f.write(cmakeliststxt)

#-----------------------------------------
### rice/CMakeLists.txt

cmakeliststxt = <<"CMAKELISTSTXT"
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
AUX_SOURCE_DIRECTORY(${CMAKE_CURRENT_SOURCE_DIR} detail)

file(GLOB_RECURSE sources RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.cpp *.hpp *.ipp)
message("${sources}")

link_directories("#{RbConfig.expand(RbConfig::MAKEFILE_CONFIG['libdir'])}")

add_library(rice STATIC ${sources})
set_target_properties(rice PROPERTIES OUTPUT_NAME "rice")

target_include_directories(rice PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(rice PRIVATE "#{RbConfig.expand(RbConfig::MAKEFILE_CONFIG['rubyhdrdir'])}")
target_include_directories(rice PRIVATE "#{RbConfig.expand(RbConfig::MAKEFILE_CONFIG['rubyarchhdrdir'])}")
target_link_libraries(rice PRIVATE #{RbConfig::MAKEFILE_CONFIG['RUBY_SO_NAME']})

install (TARGETS rice DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../ruby/lib/lib)
install (DIRECTORY ../rice DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../ruby/lib/include
          PATTERN "*.hpp"
          PATTERN "*.ipp"
          PATTERN ".gitignore" EXCLUDE
          PATTERN "CMakeLists.txt" EXCLUDE
          PATTERN "code_gen" EXCLUDE   )
install (FILES ../mswin/ruby/lib/mkmf-rice.rb DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../ruby/lib )
install (FILES ../mswin/ruby/lib/mkmf-rice.rb DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../ruby/lib/lib/ruby/site_ruby/#{RbConfig::MAKEFILE_CONFIG['ruby_version']} )
CMAKELISTSTXT

f = File.open("../rice/CMakeLists.txt", mode="w")
f.write(cmakeliststxt)

#-----------------------------------------
### rice/config.hpp

confighpp =<<"CONFIGHPP"
/* rice/config.hpp.  Generated from config.hpp.in by configure.  */
/* rice/config.hpp.in.  Generated from configure.ac by autoheader.  */

/* define if the compiler supports basic C++11 syntax */
#define HAVE_CXX11 1

/* Define to 1 if you have the <env.h> header file. */
/* #undef HAVE_ENV_H */

/* Define to 1 if you have the <node.h> header file. */
/* #undef HAVE_NODE_H */

/* Define to 1 if you have the <ruby.h> header file. */
#define HAVE_RUBY_H 1

/* Define to 1 if you have the <ruby/node.h> header file. */
/* #undef HAVE_RUBY_NODE_H */

/* Define to 1 if you have the <version.h> header file. */
/* #undef HAVE_VERSION_H */

/* Name of package */
#define PACKAGE "rice"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT ""

/* Define to the full name of this package. */
#define PACKAGE_NAME "rice"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "rice 1.1"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "rice"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "1.1"

/* Define this macro to use ruby/node.h */
/* #undef REALLY_HAVE_RUBY_NODE_H */

/* Version number of package */
#define VERSION "1.1"
CONFIGHPP

f = File.open("../rice/config.hpp", mode="w")
f.write(confighpp)

#-----------------------------------------
### rice/detail/ruby_version_code.hpp

dot_in = "../rice/detail/ruby_version_code.hpp.in"
output =  dot_in.gsub(/\.in$/, "")

f = File.open(dot_in, mode="r")
$stdout = File.open(output, mode="w")

version_str = "#{RbConfig::MAKEFILE_CONFIG['MAJOR']}#{RbConfig::MAKEFILE_CONFIG['MINOR']}#{RbConfig::MAKEFILE_CONFIG['TEENY']}"

f.each do |line|
  line.gsub!(/@RUBY_VERSION_CODE@/, version_str)
  puts line
end
f.close
$stdout = STDOUT

#-----------------------------------------
require 'fileutils'

build_dir = '../ext'
FileUtils.mkdir(build_dir)
FileUtils.cd(build_dir) do
  system "cmake .. -G \"NMake Makefiles\" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=\"c:/Program Files/LLVM/bin/clang-cl.exe\" -DCMAKE_CXX_COMPILER=\"c:/Program Files/LLVM/bin/clang-cl.exe\""
end

# Don't return extconf.rb
exit
