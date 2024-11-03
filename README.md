Observations:
1. Creating the data individually for each test method is doable, but I tried to implement the @TestSetup process to create data for all the tests (just to get the practice with a new concept).  I ran into some difficulties (maybe all conceptual) with pulling that data into the test methods in a way that made sense to test individual methods rather than an "integration" test.  The testing worked, but I wasn't satisfied with that.  The difficulty arose because of testing Triggers.              
    a. I decided to switch, then, to how I think a "Data Factory" might work, which is a bit of a guess, but still gives me some reps in creating.
    b. Creating data this way may end up being a little more complicated, but it kept the Test Class a little cleaner and more readable.

Decisions:
1. I implemented a Trigger Framework (just for practice), so the solution will be found in the following files:
    LeadTrigger.trigger -- remains the trigger.
    TriggerHandler.cls -- this is the trigger framework we've used in past assignments
    LeadTriggerHandler.cls -- this extends the TriggerHandler framework to handle Lead trigger events.
    LeadUtils.cls -- this contains the helper methods that the LeadTriggerHandler class will use as a helper.
    LeadTriggerTest.cls -- this remains the test class file.
    TestDataFactory.cls -- this is a separate class that creates data for the test class methods to maintain a visually cleaner test class.
2. I recognize the instructions suggested we utilize the custom report to validate that converted Leads were converted to the correct Contact.  I looked into that, but ultimately chose to go in another direction (asserting that the Lead's ConvertedContactId matched the correct Contact Id), which I thought was a more straightforward solution that also didn't require allowing the test to "see all data," which I believe is to be used as sparingly as possible.




[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=16642985&assignment_repo_type=AssignmentRepo)
# Developer Kickstart: Testing and Debugging
This repository is an essential segment of the Developer Kickstart curriculum at Cloud Code Academy. Tailored specifically for up-and-coming Salesforce developers, this module plunges into the crucial aspects of testing and debugging, underscoring the necessity of robust test classes, effective debugging strategies, and the maintenance of high code coverage.

## Goals of the Practice
During this repository, you will deepen your grasp of:

- The imperative role of test classes in ensuring the reliability and stability of your Apex code within Salesforce.
- Crafting and deploying well-structured test methods to cover a multitude of scenarios, both positive and negative.
- The importance of achieving and maintaining a high code coverage percentage, ensuring every line of code is vetted for functionality.
- Mastering Salesforce's built-in debugging tools, such as the Developer Console, to identify, diagnose, and resolve issues efficiently.
- Incorporating systematic logging and exception handling to provide clarity on runtime behaviors and unexpected errors.

By excelling in these testing and debugging techniques, you'll bolster your capability to write resilient and fault-tolerant code. This strengthens your expertise in ensuring that Salesforce applications are not only functional but also reliable, emphasizing the best practices that underpin top-tier Salesforce development.

## Setup
[Setup Overview](https://learn.cloudcodeacademy.com/courses/salesforce-developer-kickstart-program/lectures/47601132)

## Getting Started Checklist
1. Create/Configure a trailhead playground or developer org to do your work throughout this program.
2. Install Visual Studio Code from [here](https://code.visualstudio.com/download).
3. Install Salesforce Extension Pack in Visual Studio Code. This can be done by searching 'Salesforce Extension Pack' in the Extensions view in VS Code and clicking Install.
4. Authorize your org in Visual Studio Code. Press `Ctrl + Shift + P` to open the command palette and type 'SFDX: Authorize an Org', then press Enter. Follow the steps in the browser to log in to your org, then return to VS Code.
5. Make sure to save and deploy your changes into Salesforce from your local machine. This can be done through the command pallet or right clicking the file you want to deploy and using the option `SFDX: Deploy this source to org`

## Running the Test Classes

To run the test classes:

1. Open the command palette with `Ctrl + Shift + P`.
2. Type 'SFDX: Invoke Apex Tests...', and press Enter.
3. In the 'Select Test Class' input, select the test class you want to run and press Enter.
4. The test results will appear in the Output panel at the bottom of the screen. You can switch to the 'Test' tab in this panel to see a summary of the test run.

## Resources

If you get stuck at any point, here are some resources that might help:

- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dev_guide.htm)
- [Salesforce Stack Exchange](https://salesforce.stackexchange.com/)
- [Visual Studio Code Documentation](https://code.visualstudio.com/docs)
- [Salesforce Extensions for Visual Studio Code](https://developer.salesforce.com/tools/vscode/)

And remember, programming is often about solving problems, so don't be afraid to use search engines to find answers to your questions.

Good luck with your learning journey in Salesforce development!