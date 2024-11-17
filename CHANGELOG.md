# [Unreleased]

## 🚀 Features
- **Add keyboard actions**: Implemented keyboard interactions, including typing and key pressing.
- **Add drag and drop action**: Implemented drag and drop bewteen elements

## 🛠 Core Enhancements
- **Improve mouse movements**: Keep mouse position between interaction during browser session
- **Improve mouse movements**: Improving Bézier curve usage for more human like behavior

# Changelog v0.0.1.pre

## 🚀 Features
- **Add virtual mouse on macOS**: Introduced a virtual mouse controller for macOS. (commit `9cb095b`)
- **Abstract mouse control**: Unified mouse control across different operating systems with an abstraction layer. (commit `a7e0732`)
- **Add shadow interactor**: Added support for interacting with elements inside shadow DOM. (commit `6cdea5c`)

## 🛠 Core Enhancements
- **Add debug_url spec**: Introduced debug specifications for better error tracking. (commit `4c06c75`)
- **Add client specs**: Comprehensive tests for the core client functionality. (commits `1e17955`, `18f0bf1`)
- **Add config spec**: Added configuration testing specs. (commit `588407f`)
- **Add MPEG for recording**: Integrated MPEG support for screen recording (currently experimental). (commit `d149a14`)
- **Improve arguments priority**: Refined the argument handling mechanism for better control. (commit `9849d0f`)
- **Add Dockerfile for testing**: Included a Docker setup for running tests in isolated environments. (commit `57f334e`)
- **Use xdotool for Linux and add X screenshot**: Enhanced Linux support using `xdotool` for mouse control and added X screenshot capability. (commit `80ef37f`)
- **Improve wait for load**: Improved logic for waiting until the page is fully loaded before proceeding. (commit `28e9371`)
- **Improve DOM events**: Enhanced handling of DOM events for better interaction. (commit `36a425c`)
- **Improve nested elements handling**: Enhanced support for working with nested and complex elements. (commit `ad03ec3`)
- **Get element attributes**: Added method to retrieve element attributes as a hash. (commit `b71e1f7`)
- **Add WEBrick for testing server**: Added a simple WEBrick server for testing purposes. (commit `fc70006`)
- **Improve element interactions**: Various improvements in element manipulation methods. (commit `5430d8c`)
- **Start native mouse support**: Began implementation of native mouse interactions. (commit `fce1aef`)
- **Improve undetection mechanisms**: Enhanced techniques to bypass bot detection. (commit `7ff622a`)

## 🐛 Bug Fixes
- **Fix bad stop method**: Corrected an issue with the stopping method that caused unexpected behavior. (commit `4b45d6d`)
- **Fix Docker X size**: Resolved issues with the size of the X window in Docker environments. (commit `41edece`)

## 📝 Documentation
- **Update README**: Updated the README file with new instructions and examples. (commit `8118913`)
- **Add logo**: Added a logo to the project for better branding. (commit `2a5cbb9`)

## 🧪 CI/CD
- **Enable CI pipeline**: Added continuous integration (CI) setup for automated testing. (commit `4160aa1`)

## 🧹 Refactor
- **Rename mouse hardware**: Refactored the naming conventions for mouse-related classes. (commit `89d6ae1`)
- **Remove record notion (temporary)**: Temporarily removed the recording feature for further refinement. (commit `fdb3e0e`)

## 🛠 Infrastructure
- **Start adding Xvfb support**: Introduced Xvfb support for headless testing. (commit `678a8a5`)
- **Improve spec servers**: Made enhancements to the testing servers for more robust specs. (commit `51e64f4`)

## 🏁 Project Initialization
- **Initialize project**: Set up the initial project structure. (commit `3ec91f4`)
- **Start element development**: Began the implementation of the `Element` class. (commit `adadef0`)