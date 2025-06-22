set(COPILOT_INS_FILE "${CMAKE_SOURCE_DIR}/.github//copilot-instructions.md")
get_filename_component(OUTPUT_DIR ${COPILOT_INS_FILE} DIRECTORY)
file(MAKE_DIRECTORY ${OUTPUT_DIR})

set(COPILOT_PROMPT_HEADER
  "
  # Project Tech Stack & Core Dependencies

  **Instructions:** This is key context for GitHub Copilot. When understanding and answering my questions, please prioritize referencing and utilizing the following information:

  * **API Usage & Code Generation:** When I ask you to write or modify code, ensure the generated code is compatible with the specific versions of the libraries listed below. For example, do not suggest Qt6 APIs for a project that declares its use of Qt5.
  * **Debugging & Analysis:** When I ask about errors, performance, or compatibility issues, use this version information as an important diagnostic basis.
  * **Maintain Consistency:** Keep your answers and suggestions consistent with this technology stack.

  ---

  **Dependencies are as follows:**

  ")

file(WRITE ${COPILOT_INS_FILE} "${COPILOT_PROMPT_HEADER}")
message(STATUS "Package Info Generator is activated, the logs will be write to: ${COPILOT_INS_FILE}")

# -------------------------------------------------------------------
# hook find_package
# -------------------------------------------------------------------
macro(find_package package_name)
  _find_package(${package_name} ${ARGN})

  if(${package_name}_FOUND)
    set(_version "N/A")
    if(DEFINED ${package_name}_VERSION)
      set(_version ${${package_name}_VERSION})
    endif()

    file(APPEND ${COPILOT_INS_FILE} "* **${package_name}** (via find_package)\n    Version: \`${_version}\`\n    * Arguments: \`${ARGN}\`\n")
    message(STATUS "Captured package info: ${package_name} ${_version}")
  endif()
endmacro()

# -------------------------------------------------------------------
# hook add_subdirectory
# -------------------------------------------------------------------

macro(add_subdirectory source_dir)
  _add_subdirectory(${source_dir} ${ARGN})

  get_filename_component(subproject_name ${source_dir} NAME)
  set(project_info "N/A")

  # check if project() defined the version
  # example: `project(ProjectName VERSION X.Y.Z)`
  if(DEFINED ${subproject_name}_VERSION)
    set(project_info "Project Version: ${${subproject_name}_VERSION}")
  else()
    # check if the subdirectory is a git repository
    set(sub_full_path "${CMAKE_CURRENT_SOURCE_DIR}/${source_dir}")
    if(IS_DIRECTORY "${sub_full_path}/.git" OR EXISTS "${sub_full_path}/.git")

      # `git describe`
      # --tags: use all tags, not just annotated ones.
      # --always: make sure it returns a value even if no tags are found.
      execute_process(
              COMMAND git describe --tags --always
              WORKING_DIRECTORY "${sub_full_path}"
              OUTPUT_VARIABLE git_describe_output
              OUTPUT_STRIP_TRAILING_WHITESPACE
              ERROR_QUIET
              RESULT_VARIABLE git_describe_result
      )
      
      if(git_describe_result EQUAL 0 AND git_describe_output)
        set(project_info "Git: ${git_describe_output}")
      endif()
      
    endif()
  endif()

  file(APPEND ${COPILOT_INS_FILE} "* **${subproject_name}** (via add_subdirectory)\n    * Project Info: \`${project_info}\`\n")
  message(STATUS "SubProject Captured: ${subproject_name}")
endmacro()