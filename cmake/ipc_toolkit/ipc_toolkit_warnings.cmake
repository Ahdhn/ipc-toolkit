################################################################################
# See comments and discussions here:
# http://stackoverflow.com/questions/5088460/flags-to-enable-thorough-and-verbose-g-warnings
################################################################################
set(REQUIRED_CMAKE_VERSION "3.8.0")

if(TARGET ipc::toolkit::warnings)
  return()
endif()

set(IPC_TOOLKIT_FLAGS
    -Wall
    -Wextra
    -pedantic

    # -Wconversion
    #-Wunsafe-loop-optimizations # broken with C++11 loops
    -Wunused

    -Wno-long-long
    -Wpointer-arith
    -Wformat=2
    -Wuninitialized
    -Wcast-qual
    # -Wmissing-noreturn
    -Wmissing-format-attribute
    # -Wredundant-decls

    -Werror=implicit
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=nonnull>    
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=init-self>
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=main>    
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=missing-braces>
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=sequence-point>    
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=return-type>    
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=trigraphs>
    -Warray-bounds    
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=write-strings>    
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=address>    
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=int-to-pointer-cast>
    -Werror=pointer-to-int-cast

    -Wno-unused-variable
    -Wunused-but-set-variable
    -Wno-unused-parameter

    #-Weffc++
    -Wno-old-style-cast
    # -Wno-sign-conversion
    #-Wsign-conversion

    # -Wshadow

    -Wstrict-null-sentinel
    -Woverloaded-virtual
    -Wsign-promo
    -Wstack-protector
    -Wstrict-aliasing
    -Wstrict-aliasing=2

    # Warn whenever a switch statement has an index of enumerated type and
    # lacks a case for one or more of the named codes of that enumeration.
    -Wswitch
    # This is annoying if all cases are already covered.
    # -Wswitch-default
    # This is annoying if there is a default that covers the rest.
    # -Wswitch-enum
    -Wswitch-unreachable
    # -Wcovered-switch-default # Annoying warnings from nlohmann::json

    -Wcast-align
    -Wdisabled-optimization
    #-Winline # produces warning on default implicit destructor
    -Winvalid-pch
    # -Wmissing-include-dirs
    -Wpacked
    -Wno-padded
    -Wstrict-overflow
    -Wstrict-overflow=2

    # -Wctor-dtor-privacy
    -Wlogical-op
    # -Wnoexcept
    -Woverloaded-virtual
    # -Wundef

    -Wnon-virtual-dtor    
    -Wdelete-non-virtual-dtor    
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=non-virtual-dtor>    
    $<IF:$<COMPILE_LANGUAGE:CUDA>,,-Werror=delete-non-virtual-dtor>

    -Wno-sign-compare

    ###########
    # GCC 6.1 #
    ###########

    -Wnull-dereference
    -fdelete-null-pointer-checks
    -Wduplicated-cond
    -Wmisleading-indentation

    #-Weverything

    ###########################
    # Enabled by -Weverything #
    ###########################

    #-Wdocumentation
    #-Wdocumentation-unknown-command
    #-Wfloat-equal

    #-Wglobal-constructors
    #-Wexit-time-destructors
    #-Wmissing-variable-declarations
    #-Wextra-semi
    #-Wweak-vtables
    #-Wno-source-uses-openmp
    #-Wdeprecated
    #-Wnewline-eof
    #-Wmissing-prototypes

    #-Wno-c++98-compat
    #-Wno-c++98-compat-pedantic

    ################################################
    # Need to check if those are still valid today #
    ################################################

    #-Wimplicit-atomic-properties
    #-Wmissing-declarations
    #-Wmissing-prototypes
    #-Wstrict-selector-match
    #-Wundeclared-selector
    #-Wunreachable-code

    # Not a warning, but enable link-time-optimization
    # TODO: Check out modern CMake version of setting this flag
    # https://cmake.org/cmake/help/latest/module/CheckIPOSupported.html
    #-flto

    # Gives meaningful stack traces
    -fno-omit-frame-pointer
    -fno-optimize-sibling-calls

    -Wno-pedantic

    -Wno-redundant-decls
)

# Flags above don't make sense for MSVC
if(MSVC)
  set(IPC_TOOLKIT_FLAGS)
endif()

include(CheckCXXCompilerFlag)

add_library(ipc_toolkit_warnings INTERFACE)
add_library(ipc::toolkit::warnings ALIAS ipc_toolkit_warnings)

foreach(FLAG IN ITEMS ${IPC_TOOLKIT_FLAGS})
  string(REPLACE "=" "-" FLAG_VAR "${FLAG}")
  if(NOT DEFINED IS_SUPPORTED_${FLAG_VAR})
    check_cxx_compiler_flag("${FLAG}" IS_SUPPORTED_${FLAG_VAR})
  endif()
  if(IS_SUPPORTED_${FLAG_VAR})
    target_compile_options(ipc_toolkit_warnings INTERFACE ${FLAG})
  endif()
endforeach()
