/**
 * TestDataFactory
 * 
 * This utility class generates test data for use in the methods designed to thouroughly test the Lead Trigger.
 * It provides methods to create leads, contacts, accounts, and other relevant records,
 * ensuring consistent and reusable test data setup.
 * 
 * Each method is designed to produce data with specific characteristics or to
 * support different test scenarios.
 */
public with sharing class TestDataFactory {
    
    /**
     * Method: createLeadData
     * 
     * Creates a list of 9 Lead records with varying titles, industries, lead sources, 
     * and contact details. This method provides a diverse set of leads to test
     * different lead scenarios, including scoring and title normalization.
     * 
     * @return List<Lead> - A list of leads with various attributes for testing.
     */
    public static List<Lead> createLeadData(){
        List<Lead> leadList = new List<Lead>();
        List<String> titles = new List<String>{
            'Vp of Sales', 'V.P. Marketing', 
            'Mgr of Operations', 'Head of Department',  
            'EXEC dir', 'Chief Financial Officer', 
            'Jr Analyst', 'Deputy Advisor', 
            'Consultant'};        

        Integer i = 1;
        for(String title : titles){
            Lead l = new Lead(
                LastName = String.valueOf(i),
                Company = 'Test Account ' + i,
                Status = 'Open - Not Contacted',
                Title = title);
            if (i == 1){
                l.LeadSource = 'Website';
                l.Email = 'test1@example.com';
                l.Industry = 'Technology';
                l.Phone = '123-456-789';
                // All criteria met --> should get 18 points
            } else if (i == 2) {
                l.LeadSource = 'Website';
                l.Email = 'test2@example.com';
                // No phone or Technology industry --> should get 3 points
            } else if (i == 3) {                
                l.Phone = '123-456-789';
                // No email, Technology industry, leadsource --> should get 5 points    
            } else if (i == 4) {
                l.Industry = 'Technology';
                l.Phone = '123-456-789';
                //No email or Website source --> should get 15 points    
            }
                leadList.add(l);
                i++;
            }
        return leadList;
    }  
    
    /**
     * Method: createLeadDataInsert
     * 
     * Modifies the Lead list created in the `createLeadData` method for use in testing the `handleLeadAutoConvert`
     * process when triggered by inserting Leads.
     * 
     * @return List<Lead> - A list of leads for insert scenarios.
     */
    public static List<Lead> createLeadDataInsert(){
        List<Lead> leadList = createLeadData();
        leadList[2].Email = 'test3@example.com';
        return leadList;
    }

    /**
     * Method: createLeadDataUpdate
     * 
     * Modifies the Lead list created in the `createLeadData` method for use in testing the `handleLeadAutoConvert`
     * process when triggered by updating Leads.
     * 
     * @return List<Lead> - A list of leads for update scenarios.
     */    
    public static List<Lead> createLeadDataUpdate(){
        List<Lead> leadList = createLeadData();
        for(Integer i = 8; i>=0; i--){
            if(i > 2){
                leadList.remove(i);
            }
            else {
                leadList[i].Email = 'nomatch@example.com';
            }
        }
        return leadList;
    }

    /**
     * Creates and inserts a map of Contact records with unique or 
     * duplicate emails to test lead-to-contact matching.
     * 
     * @return Map<String, Contact> - A map of contacts keyed by LastName.
     */    
    public static Map<String, Contact> createContactData(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Map<String, Contact> contDataMap = new Map<String, Contact>();
        for(Integer i=1; i<4; i++){
            Contact con = new Contact(
                LastName = String.valueOf(i),
                AccountId = acc.id,
                Email = 'test' + i + '@example.com');
            if (i==3){
                con.Email = 'test2@example.com'; //create a duplicate contact email
            }
            contDataMap.put(con.LastName, con);
        }
        insert contDataMap.values();
        return contDataMap;
    }
}