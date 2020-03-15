require 'mkmf'
require 'rbconfig'

$RICE_PREFIX = File.join(File.dirname(File.expand_path(__FILE__)))

def create_makefile(target)
  cmakeliststxt = <<-"CMAKELISTSTXT"
cmake_minimum_required(VERSION 3.12)

set(TARGET #{target})

enable_language(CXX)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

project(${TARGET})

file(GLOB_RECURSE sources RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.cpp)
message("${sources}")

# Need before add_library
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
link_directories("#{RbConfig.expand(RbConfig::MAKEFILE_CONFIG['libdir'])}")
link_directories("#{$RICE_PREFIX}/lib")

add_library(${TARGET} SHARED ${sources})
set_target_properties(${TARGET} PROPERTIES OUTPUT_NAME "#{target}")
set_target_properties(${TARGET} PROPERTIES SUFFIX  ".so")

target_include_directories(${TARGET} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(${TARGET} PRIVATE "#{RbConfig.expand(RbConfig::MAKEFILE_CONFIG['rubyhdrdir'])}")
target_include_directories(${TARGET} PRIVATE "#{RbConfig.expand(RbConfig::MAKEFILE_CONFIG['rubyarchhdrdir'])}")
target_include_directories(${TARGET} PRIVATE "#{$RICE_PREFIX}/include")

target_link_libraries(${TARGET} PRIVATE #{RbConfig.expand(RbConfig::MAKEFILE_CONFIG['RUBY_SO_NAME'])})
target_link_libraries(${TARGET} PUBLIC rice)

install (TARGETS ${TARGET} DESTINATION #{RbConfig.expand(RbConfig::MAKEFILE_CONFIG['sitearchdir'])})
  CMAKELISTSTXT

  f = File.open("CMakeLists.txt", mode="w")
  f.write(cmakeliststxt)

  require 'fileutils'

  build_dir = 'ext'
  FileUtils.mkdir(build_dir)
  FileUtils.cd(build_dir) do
    system "cmake .. -G \"NMake Makefiles\" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=\"c:/Program Files/LLVM/bin/clang-cl.exe\" -DCMAKE_CXX_COMPILER=\"c:/Program Files/LLVM/bin/clang-cl.exe\""
  end
end

### Top Makefile ###

makefile = <<"MAKEFILE"
all:
	pushd ext & $(MAKE) /nologo /$(MAKEFLAGS) all & popd

clean:
	pushd ext & $(MAKE) /nologo /$(MAKEFLAGS) clean & popd

clean-build:
	-rd /S /Q ext
	-del /F CMakeLists.txt Makefile

install:
	pushd ext & $(MAKE) /nologo /$(MAKEFLAGS) install & popd

.PHONY: all clean clean-all install
MAKEFILE

f = File.open("Makefile", mode="w")
f.write(makefile)
