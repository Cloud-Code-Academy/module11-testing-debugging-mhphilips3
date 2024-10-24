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

    
    @TestSetup
    static void makeData(){
        
        List<String> titles = new List<String>{
            'Vp of Sales', 'V.P. Marketing', 'Vice President of Engineering', 
            'Mgr of Operations', 'Head of Department',  
            'EXEC dir', 'Chief Financial Officer', 
            'Assistant to the CEO', 'Jr Analyst', 'Deputy Advisor', 
            'Analyst', 'Software Engineer', 'Consultant'
        };
        
        List<Lead> leadList = new List<Lead>();
        Integer i = 1;
        for(String title : titles){
            Lead l = new Lead(
                LastName = String.valueOf(i),
                Company = 'Test Account ' + i,
                Status = 'Open - Not Contacted',
                Title = title);
                leadList.add(l);
                i++;
            }
            insert leadList;
        }
        
    /**
     * Test Method: testHandleTitleNormalization
     * 
     * Purpose:
     * This test verifies that the handleTitleNormalization method properly normalizes job titles 
     * based on specific criteria provided. The goal is to ensure that titles containing certain keywords 
     * are standardized and others remain unchanged.
     * 
     * Criteria for Normalization:
     * - If the title contains terms like 'vp', 'v.p.', or 'vice president', it should be changed to 'Vice President'.
     * - If the title contains terms like 'mgr', 'manage', or 'head of department', it should be changed to 'Manager'.
     * - If the title contains terms like 'exec', 'chief', or 'head', it should be changed to 'Executive'.
     * - If the title contains terms like 'assist', 'deputy', or 'jr', it should be changed to 'Assistant'.
     *
     * Test Scenarios:
     * 1. Positive Tests:
     *    - Titles containing the predefined terms should be normalized:
     *    - Assert that the title is changed correctly based on the keyword it contains.
     *
     * 2. Negative Tests:
     *    - Titles that do not contain any of the specified terms should remain unchanged:
     *      - 'Analyst', 'Consultant', 'Engineer', etc. should not be modified.
     *    - Assert that the title remains the same when no match is found.
     *
     * 3. Edge Case Tests:
     *    - Test for case-insensitive matches (e.g., 'Vp', 'EXEC', etc.) to ensure normalization works regardless of capitalization.
     */
    @isTest
    static void TestLeadTrigger_handleTitleNormalization() {
        // Data created and inserted in @TestSetup        
        //check results
        List<String> acceptableTitles = new List<String>{'Analyst', 'Software Engineer', 'Consultant'};
        List<Lead> insertedLeads = new List<Lead>([SELECT Id, LastName, Title FROM Lead]);
        for(Lead l : insertedLeads){
            if(Integer.valueOf(l.LastName) <=3){
                System.assertEquals('Vice President', l.Title, 'Normalization for Vice President titles is not working properly');
            } else if (Integer.valueOf(l.LastName) <= 5){
                System.assertEquals('Manager', l.Title, 'Normalization for Manager titles is not working properly');
                
            } else if (Integer.valueOf(l.LastName) <= 7){
                System.assertEquals('Executive', l.Title, 'Normalization for Executive titles is not working properly');
                
            }else if (Integer.valueOf(l.LastName) <= 10){
                System.assertEquals('Assistant', l.Title, 'Normalization for Assistant titles is not working properly');
                
            } else {
                Assert.isTrue(acceptableTitles.contains(l.Title), 'Normalization process changed a title errantly');
            }
            
        }
    }

    
}