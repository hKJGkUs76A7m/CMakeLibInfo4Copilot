# CMake Copilot Context Generator

This tool automatically captures dependencies from your CMake-based project and generates a detailed Markdown file. This file serves as a powerful, pre-configured prompt for GitHub Copilot, enabling it to provide more accurate, version-aware, and contextually relevant code suggestions and analysis.

## How It Works

The script cleverly hooks into the CMake configuration process by wrapping the `find_package` and `add_subdirectory` commands. When CMake configures your project, this script intercepts these calls to automatically discover your dependencies, detect their versions (using `git describe` for subprojects), and write this information directly to a Markdown file formatted as a prompt for GitHub Copilot.

## Getting Started

Follow these steps to integrate the dependency generator into your project.

### Usage Steps

1.  **Place the Script**

    Copy the `dep_info_gen.cmake` file into your project's root directory. For better organization, we recommend placing it inside a `cmake/` subdirectory.

    ```
    my_project/
    ├── cmake/
    │   └── dep_info_gen.cmake   <-- Place script here
    ├── src/
    └── CMakeLists.txt
    ```

2.  **Include the Script in `CMakeLists.txt`**

    In your root `CMakeLists.txt` file, add the following lines near the top (right after `cmake_minimum_required`). This adds a configurable `option` to turn the feature on or off.

    ```cmake
    include(cmake/dep_info_gen.cmake)

    # ... rest of your CMakeLists.txt ...
    project(MyProject)
    ```

3.  **Run CMake Configure**

    Execute the CMake configure command from your project's root directory.

4.  **Check the Result**

    The script will automatically generate the context file during configuration. You can find the result at:

    `.github/copilot-instructions.md`

    GitHub Copilot will now use this file to enhance its understanding of your project's architecture and dependencies.