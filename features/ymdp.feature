Feature: Configuration

  Background:
    Given I load config.yml

  Scenario: Load the config file
    Then my "username" setting should be "username"
    And my "password" setting should be "password"

  Scenario: Build the application
    Given I compile the application with the message "this is my commit message"
    Then I should see "this is my commit message" in "servers/production/views/page"
    Then I should see "this is my commit message" in "servers/development/views/page"
    And I should see "Apple" in "servers/production/views/page"
    And I should see "Apple" in "servers/development/views/page"
    And I should see "mysite.com" in "servers/production/views/page"
    And I should see "mysite.com" in "servers/development/views/page"

  @wip
  Scenario: Build application with invalid HTML
    Given the view "invalid" exists with "%span\n  #invalid_div This won't validate"
    And I compile the application with the message "this shouldn't validate"
    Then an exception should have been raised with the message "HTML Validation Errors"
    And I remove the view "invalid"

  Scenario: Deploy the application
    Given I deploy the application
    