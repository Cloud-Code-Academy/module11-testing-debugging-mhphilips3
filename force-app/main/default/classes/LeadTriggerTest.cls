/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public with sharing class LeadTriggerTest {

        
    /**
     * Test Method: testHandleTitleNormalization
     * 
     * Purpose:
     * This test verifies that the handleTitleNormalization method properly normalizes job titles 
     * based on specific criteria provided. The goal is to ensure that titles containing certain keywords 
     * are standardized and others remain unchanged.
     * 
     * Test Scenarios:
     * 1. Positive Tests:
     *    - Titles containing the predefined terms should be normalized:
     *    - Assert that the title is changed correctly based on the keyword it contains.
     *
     * 2. Negative Test:
     *    - Titles that do not contain any of the specified terms should remain unchanged:
     *      - 'Consultant' should not be modified.
     *    - Assert that the title remains the same when no match is found.
     *
     * 3. Edge Case Test:
     *    - Test for case-insensitive matches (e.g., 'Vp', 'EXEC', etc.) to ensure normalization works regardless of capitalization.
     */
    @isTest
    static void testLeadTrigger_handleTitleNormalization() {
        //Get test data
        List<Lead> leadList = TestDataFactory.createLeadData();

        // Test Trigger Handler method (Before Insert & Before Update)
        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leadList);
        Test.stopTest();

        //check results
        for(Lead l : leadList){
            if(Integer.valueOf(l.LastName) <=2){
                Assert.areEqual('Vice President', l.Title, 'Normalization for Vice President titles is not working properly');
            } else if (Integer.valueOf(l.LastName) <= 4){
                Assert.areEqual('Manager', l.Title, 'Normalization for Manager titles is not working properly');
                
            } else if (Integer.valueOf(l.LastName) <= 6){
                Assert.areEqual('Executive', l.Title, 'Normalization for Executive titles is not working properly');
                
            }else if (Integer.valueOf(l.LastName) <= 8){
                Assert.areEqual('Assistant', l.Title, 'Normalization for Assistant titles is not working properly');
                
            } else {
                Assert.areEqual('Consultant', l.Title, 'Normalization process changed a title errantly');
            }            
        }
    }

        /**
     * Test Method: testHandleAutoLeadScoring
     * 
     * Purpose:
     * This test verifies that the handleAutoLeadScoring method correctly assigns scores to leads
     * based on specific criteria. The goal is to ensure that the lead score is calculated accurately,
     * with a maximum possible score of 18, and is stored in the Lead_Score__c field.
     * 
     * Test Scenarios:
     * 1. Positive Tests:
     *    - Leads that meet all criteria should have a score of 18:
     *      - Verify that the score is computed correctly when the lead has a website source, an email, a phone number, and belongs to the 'Technology' industry.
     *    - Leads that meet partial criteria should have the appropriate score:
     *      - Verify that the score is computed correctly when the lead meets only one or two of the conditions (e.g., only phone number or only industry).
     *
     * 2. Negative Tests:
     *    - Leads that do not meet any criteria should have a score of 0:
     *      - Verify that no points are assigned when the lead does not have a website source, no email, no phone, and does not belong to the 'Technology' industry.
    */
    @isTest
    static void testLeadTrigger_handleAutoLeadScoring(){
        //get data
        List<Lead> leadList = TestDataFactory.createLeadData();
        
        //run test
        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leadList);
        Test.stopTest();

        //verify results
        for(Lead l : leadList){
            if(Integer.valueOf(l.LastName) == 1){
                Assert.areEqual(18, l.Lead_Score__c, 'Lead Score is not calculating correctly');
            } else if (Integer.valueOf(l.LastName) == 2){
                Assert.areEqual(3, l.Lead_Score__c, 'Lead Score is not calculating correctly');
                
            } else if (Integer.valueOf(l.LastName) == 3){
                Assert.areEqual(5, l.Lead_Score__c, 'Lead Score is not calculating correctly');
                
            }else if (Integer.valueOf(l.LastName) == 4){
                Assert.areEqual(15, l.Lead_Score__c, 'Lead Score is not calculating correctly');
                
            } else {
                Assert.areEqual(0, l.Lead_Score__c, 'Lead Score is not calculating correctly');
            }
        }
    }
}

    /**
     * Test Method: testHandleLeadAutoConvert
     * 
     * Purpose:
     * This test verifies that the handleLeadAutoConvert method automatically converts Leads 
     * into Contacts when a matching Contact with the same email address is found. It also ensures 
     * that Leads are correctly merged with an existing Contact and unconverted if either zero or multiple 
     * Contacts with the same email are found.
     * 
     * Criteria for Lead Conversion:
     * - The method monitors the "Email" field on the Lead object for new Lead creation or updates.
     * - On Lead creation or email update, search the Contact object for matching records with the same email address.
     * - If a single matching Contact is identified:
     *   - Automatically convert the Lead.
     *   - Merge Lead data with the existing Contact, preserving critical Contact details.
     * - If multiple Contacts with the same email are found or no match is identified, leave the Lead unconverted.
     * 
     * Test Scenarios:
     * 1. Positive Tests:
     *    - A Lead with a unique matching Contact:
     *      - Verify that a Lead with an email that matches a single Contact's email is automatically converted.
     *      - Verify that Lead details are merged with the existing Contact without losing crucial Contact information.
     * 
     * 2. Negative Tests:
     *    - A Lead with no matching Contact:
     *      - Ensure that Leads with no matching Contact are not converted and remain as Leads.
     *    
     *    - A Lead with multiple matching Contacts:
     *      - Ensure that Leads with more than one matching Contact are not converted and remain as Leads.
     * 
     * 3. Edge Case Tests:
     *    - Case-insensitive email match:
     *      - Ensure that the method works regardless of capitalization in the email field (e.g., 'test@example.com' vs 'TEST@EXAMPLE.COM').
     * 
     *    - Leads with missing or null emails:
     *      - Verify that Leads with null or missing email fields are not processed for conversion and remain as Leads.
     * 
     *    - No Contacts in the system:
     *      - Verify that the method behaves correctly if no Contacts exist in the system when Leads are created or updated.
     * 
     *    - Lead creation and update scenarios:
     *      - Verify that the method triggers correctly on both Lead creation and Lead email updates, checking for the same email match behavior.
     *
     * 4. Integration Tests:
     *    - Use Salesforce’s "Converted Lead" report:
     *      - Verify that the conversion can be seen in the "Converted Lead" report, confirming that the Lead was converted to the correct Contact.
     */
