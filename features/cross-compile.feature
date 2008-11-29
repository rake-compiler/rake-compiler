Feature: Cross-compile C extensions

  In order to avoid bitching from Windows users
  As a Ruby developer on Linux
  I want some rake tasks that take away the pain of compilation

  Scenario: compile single extension
    Given that all my source files are in place
    And I'm running a POSIX operating system
    And I've installed cross compile toolchain
    When rake task 'cross compile' is invoked
    Then rake task 'cross compile' succeeded
    And binaries for platform 'i386-mingw32' get generated
