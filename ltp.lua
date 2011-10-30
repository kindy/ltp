#!/usr/bin/env lua
--
-- Copyright 2007-2008 Savarese Software Research Corporation.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.savarese.com/software/ApacheLicense-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

package.path = "@LTP_LIB_DIR@/?.lua;" .. package.path
-- We want ltp to be a global variable so it will be available for use
-- by templates and environment files.
ltp = require('ltp.template')

local function usage(program_name)
  io.stderr:write("usage: ", program_name,
                  " [options] template_file [env_file1 env_file2 ...]\n")
  io.stderr:write([[

Options:
  -c
            Compiles template to Lua code.
  -C
            Compiles template to Lua code, omitting the function wrapper.
  -e code
            Executes Lua code within the template execution environment
            immediately before executing the template.
  -g
            Merges global environment into rendering environment.
  -h,--help
            Prints this help message.
  -I directory
            Adds a directory to the search path for require directives.
  -n #
            Performs successive expansions of template output, treating
            the output as a new template, for a total of # passes.  This
            allows the use of embedded expressions.  By default, only a
            single pass (# = 1) is made (i.e., only the original template
            is evaluated).  A value of 0 may be specified to cause as many
            passes to be performed as necessary so that no embedded expressions
            remain in the output.
  -t start_lua_token end_lua_token
            Specifies the start and end tokens that demarcate embedded
            Lua code.  The defaults are '<?lua' and '?>'.
  -v,--version
            Prints version information.
  --lib-dir
            Prints the directory name containing the ltp library modules.
  --install-dir
            Prints the directory name used as the ltp installation prefix.
]])
end

local function version()
  io.stdout:write(
[[

ltp
  version: @VERSION@
  build: @BUILD@

Copyright 2007-2008 Savarese Software Research Corporation.
All Rights Reserved.

]])
end

local function main(arg)
  local CompileFlags = { None = { }, WithWrapper = { }, WithoutWrapper = { } }
  local i = 1
  local merge_global = false
  local compile_flags = CompileFlags.None;
  local start_lua, end_lua = "<?lua", "?>"
  local num_passes = 1
  local env_code = { }

  while i <= #arg do
    if arg[i] == "-h" or arg[i] == "--help" then
      usage(arg[0])
      os.exit(1)
    elseif arg[i] == "-v" or arg[i] == "--version" then
      version()
      os.exit(1)
    elseif arg[i] == "-g" then
      merge_global = true
      i = i + 1
    elseif arg[i] == "-c" then
      compile_flags = CompileFlags.WithWrapper
      i = i + 1
    elseif arg[i] == "-C" then
      compile_flags = CompileFlags.WithoutWrapper
      i = i + 1
    elseif arg[i] == "-n" then
      num_passes = tonumber(arg[i + 1])
      i = i + 2
    elseif arg[i] == "-t" then
      start_lua, end_lua = arg[i+1], arg[i+2]
      i = i + 3
      if not start_lua or not end_lua then
        break
      end
    elseif arg[i] == "-I" then
      local dir = arg[i+1]
      i = i + 2
      if not dir then
        break
      else
        package.path = dir .. "/?.lua;" .. package.path
      end
    elseif arg[i] == "-e" then
      local code = arg[i+1]
      i = i + 2
      if not code then
        break
      else
        table.insert(env_code, code)
      end
    elseif arg[i] == "--lib-dir" then
      io.stdout:write("@LTP_LIB_DIR@\n")
      os.exit(0)
    elseif arg[i] == "--install-dir" then
      io.stdout:write("@LTP_INST_DIR@\n")
      os.exit(0)
    else
      break
    end
  end

  if(not num_passes or num_passes < 0) then
    io.stderr:write("-n arg must be >= 1.\n")
    os.exit(1);
  end

  if #arg - i < 0 then
    io.stderr:write("Insufficient arguments.\n");
    usage(arg[0])
    os.exit(1)
  end

  local template_file, env_files = arg[i], ltp.slice(arg, i+1)
  if compile_flags == CompileFlags.None then
    ltp.render(io.stdout, num_passes, template_file, merge_global,
               env_files, start_lua, end_lua, env_code)
  elseif compile_flags == CompileFlags.WithWrapper then
    ltp.compile_as_function(io.stdout, template_file, start_lua, end_lua)
  elseif compile_flags == CompileFlags.WithoutWrapper then
    ltp.compile(io.stdout, template_file, start_lua, end_lua)  
  end
end

main(arg)
