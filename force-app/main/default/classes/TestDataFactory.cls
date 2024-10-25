public with sharing class TestDataFactory {
    
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
}