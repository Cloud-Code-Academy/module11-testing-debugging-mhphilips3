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
     * This test verifies that the `handleTitleNormalization` method in the `LeadUtils` class 
     * properly normalizes job titles based on specific criteria. The goal is to ensure that 
     * titles containing certain keywords are standardized, while others remain unchanged, 
     * as triggered by the Lead Trigger.
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
        LeadUtils.handleTitleNormalization(leadList);
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
     * This test verifies that the `handleAutoLeadScoring` method in the `LeadUtils` classmethod correctly assigns scores to leads
     * based on specific criteria. The goal is to ensure that the lead score is calculated accurately,
     * with a maximum possible score of 18, and is stored in the Lead_Score__c field, as triggered by the Lead Trigger.
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
        LeadUtils.handleAutoLeadScoring(leadList);
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

    /**
    * Test Methods: testHandleLeadAutoConvert_onInsert & testHandleLeadAutoConvert_onUpdate
    * 
    * Purpose:
    * These tests verify that the `handleleadAutoConvert` method in the `LeadUtils` class automatically converts Leads 
    * into Contacts when a matching Contact with the same email address is found. It also ensures 
    * that Leads are correctly merged with an existing Contact and unconverted if either zero or multiple 
    * Contacts with the same email are found.  This process is associated with the Lead Trigger.
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
    * 3. Edge Case Test:
    *    - Leads with missing or null emails:
    *      - Verify that Leads with null or missing email fields are not processed for conversion and remain as Leads.
    * 
    */
    @isTest
    static void testLeadTrigger_handleLeadAutoConvert_onInsert() {
        //Get test data
        Map<String, Contact> contactMap = TestDataFactory.createContactData();
        List<Lead> leadList = TestDataFactory.createLeadDataInsert();

        Test.startTest();
        insert leadList;
        Test.stopTest();

        // verify results
        List<Lead> insertedLeadList = new List<Lead>([SELECT Id, LastName, isConverted, ConvertedContactId From Lead]);
        for (Lead l : insertedLeadList){
            if (l.LastName == '1'){
                //lead should convert with Contact with LastName '1'
                Assert.isTrue(l.isConverted, 'Lead was not converted as expected');
                Assert.areEqual(l.ConvertedContactId, contactMap.get('1').Id, 'Lead not converted to correct contact');

            } else if (l.LastName == '2'){
                //Lead's email matches email of multiple contacts, so shouldn't convert
                Assert.isFalse(l.IsConverted, 'Lead should not have been converted');

            } else if (l.LastName == '3'){
                //Lead's email matches no contacts, so shouldn't convert
                Assert.isFalse(l.IsConverted, 'Lead should not have been converted');

            } else {
                //Leads without emails shouldn't convert
                Assert.isFalse(l.isConverted, 'Leads without email addresses should not auto convert');
            }
        }       
    }

    @isTest
    static void testLeadTrigger_handleLeadAutoConvert_onUpdate(){
        // get test data
        Map<String, Contact> contactMap = TestDataFactory.createContactData();
        List<Lead> leadsToInsert = TestDataFactory.createLeadDataUpdate();
        insert leadsToInsert;

        //query for inserted leads
        List<Lead> leadsToUpdate = new List<Lead> ([SELECT Id, LastName, Email FROM Lead]);
        //Update email addresses
        for (Lead l : leadsToUpdate){
            if (l.LastName == '1') {
                l.Email = 'test1@example.com'; // should match and convert
            } else if (l.LastName == '2'){
                l.Email = 'test2@example.com'; // matches w/ 2 contacts, no conversion
            } else {
                l.Email = 'test3@example.com'; // no match should not convert
            }
        }

        //run test
        test.startTest();
        update leadsToUpdate;
        test.stopTest();

        // Query for Updated Leads
        List<Lead> leadsToVerify = [SELECT Id, LastName, isConverted, ConvertedContactId FROM Lead];
        
        // Verify results
        for(Lead l : leadsToVerify){
            if (l.LastName == '1') {
                // Lead email matches 1 contact --> should convert to proper contact
                Assert.isTrue(l.isConverted, 'Lead did not convert properly');
                Assert.areEqual(contactMap.get('1').Id, l.ConvertedContactId, 'Lead converted to wrong contact.');
            } else if (l.LastName == '2'){
                // Lead email matches 2 Contacts --> should not convert
                Assert.isFalse(l.IsConverted, 'Lead did not remain unconverted.');
            } else {
                // Lead email matches 0 contacts --> should not convert
                Assert.isFalse(l.IsConverted, 'Lead did not remain unconverted.');                
            }
        }
    }
}

