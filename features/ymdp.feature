Feature: Configuration

  Background:
    Given I load config.yml

  Scenario: Load the config file
    Then my "username" setting should be "username"
    And my "password" setting should be "password"
    
  
  Scenario: Ensure the commit message is in the view
    Given I compile the application with the message "this is my commit message"
    Then I should see "this is my commit message" in "servers/production/views/page"
    Then I should see "this is my commit message" in "servers/development/views/page"
    And I should see "Apple" in "servers/production/views/page"
    And I should see "Apple" in "servers/development/views/page"
    And I should see "mysite.com" in "servers/production/views/page"
    And I should see "mysite.com" in "servers/development/views/page"
    And I should see "font-family:Arial,Helvetica,sans-serif;" in "servers/production/views/page"
    And I should see "font-family:Arial,Helvetica,sans-serif;" in "servers/development/views/page"
    And I should see "var Application" in "servers/production/views/page"
    And I should see "var Application" in "servers/development/views/page"
    And no exceptions should have been raised
    

  Scenario: Build application with invalid HTML
    Given the file "app/views/invalid.html.haml" exists with "%span\n  #invalid_div This won't validate"
    And I compile the application with the message "this shouldn't validate"
    Then an exception should have been raised with the message "HTML Validation Errors"
    
    
  Scenario: Render nil on nonexistent scripts
    Given the file "app/views/valid.html.haml" exists with "%p Hello\n= render :javascript => 'nonexistent'\n%p Goodbye"
    And I compile the application with the message "this should have no javascript"
    Then I should see "<p>Hello</p>\n      \n      <p>Goodbye</p>" in "servers/production/views/valid"
    And no exceptions should have been raised
    
    
  Scenario: Render nil on nonexistent stylesheets
    Given the file "app/views/valid.html.haml" exists with "%p Hello\n= render :stylesheet => 'nonexistent'\n%p Goodbye"
    And I compile the application with the message "this should have no stylesheet"
    Then I should see "<p>Hello</p>\n      \n      <p>Goodbye</p>" in "servers/production/views/valid"
    And no exceptions should have been raised


  Scenario: Build application with valid JavaScript
    Given the file "app/views/valid.html.haml" exists with "= render :javascript => 'valid'"
    And the file "app/javascripts/valid.js" exists with "var a = 'hello'; alert(a);"
    And I compile the application with the message "this should validate"
    Then no exceptions should have been raised
    

  Scenario: Build application with invalid JavaScript
    Given the file "app/javascripts/invalid.js" exists with "A = function() { alert('hello'); }"
    And the file "app/views/invalid.html.haml" exists with "= render :javascript => 'invalid'"
    And I compile the application with the message "this shouldn't validate"
    Then an exception should have been raised with the message "JavaScript Errors embedded in /tmp/invalid.js"
    
    
    
    