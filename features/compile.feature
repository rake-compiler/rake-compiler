Feature: Compile C code into Ruby extensions.

  In order to automate compilation process.
  As a Gem developer.
  I want rake tasks compile source code for me.

  Scenario: Compile single extension
    Given a safe project directory
    And scaffold code for extension 'extension_one'
    And 'tmp' folder is deleted
    When rake task 'compile' is invoked
    And rake task 'compile' succeeded
    Then binary extension 'extension_one' do exist in 'lib'
    And 'tmp' folder is created

  Scenario: Not recompile unmodified extension
    Given a safe project directory
    And scaffold code for extension 'extension_one'
    And binary extension 'extension_one' do exist in 'lib'
    And intermediate files for extension 'extension_one' do exist in 'tmp'
    When rake task 'compile' is invoked
    And rake task 'compile' succeeded
    Then output of rake task 'compile' does not match /extension_one/

  Scenario: recompile extension when source is modified
    Given a safe project directory
    And scaffold code for extension 'extension_one'
    And binary extension 'extension_one' do exist in 'lib'
    And intermediate files for extension 'extension_one' do exist in 'tmp'
    When touching 'source.c' file of extension 'extension_one'
    And rake task 'compile' is invoked
    And rake task 'compile' succeeded
    Then output of rake task 'compile' does match /extension_one/

  Scenario: Compile multiple extensions
    Given a safe project directory
    And scaffold code for extension 'extension_one'
    And scaffold code for extension 'extension_two'
    And 'tmp' folder is deleted
    When rake task 'compile' is invoked
    And rake task 'compile' succeeded
    Then binary extension 'extension_one' do exist in 'lib'
    And binary extension 'extension_two' do exist in 'lib'
    And 'tmp' folder is created

  Scenario: Compile one extension instead of all present
    Given a safe project directory
    And scaffold code for extension 'extension_one'
    And scaffold code for extension 'extension_two'
    When rake task 'compile:extension_one' is invoked
    And rake task 'compile:extension_one' succeeded
    Then output of rake task 'compile:extension_one' does not match /extension_two/
    And binary extension 'extension_one' must exist in 'lib'
    And binary extension 'extension_two' must not exist in 'lib'
