@IsTest
public class SObjectUnitOfWorkTest {

  // SObjects (in order of dependency) used by UnitOfWork in tests below  
  private static List<Schema.SObjectType> MY_SOBJECTS = 
    new List<Schema.SObjectType> { 
      Product2.SObjectType, 
      PricebookEntry.SObjectType, 
      Opportunity.SObjectType, 
      OpportunityLineItem.SObjectType
    };

  @IsTest
  static void testErrorRecordRegisteredNew() {
    Account acc = new Account();
    acc.Name = 'Testing';
    insert acc;
    Test.startTest();
    try {
      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
      uow.registerNew(acc);
      System.assert(false, 'Expected an exception');
    } catch (SObjectUnitOfWorkException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  @IsTest
  static void testErrorRecordRegisteredDirty() {
    Account acc = new Account();
    acc.Name = 'Testing';
    Test.startTest();
    try {
      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
      uow.registerDirty(acc);
      System.assert(false, 'Expected an exception');
    } catch (SObjectUnitOfWorkException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  @IsTest
  static void testErrorTypeNotSupported() {
    Account acc = new Account();
    acc.Name = 'Testing';
    Test.startTest();
    try {
      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
      uow.registerNew(acc);
      System.assert(false, 'Expected an exception');
    } catch (SObjectUnitOfWorkException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  @IsTest
  public static void testUnitOfWorkNewDirtyDelete() {
    Id pricebookId = Test.getStandardPricebookId();
    
    // Insert Opporunities with UnitOfWork
    {
      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);       
      for (Integer o = 0; o < 10; o++) {
        Opportunity opp = new Opportunity();
        opp.Name = 'UoW Test Name ' + o;
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
        uow.registerNew(opp);   
        for (Integer i = 0; i < o + 1; i++) {           
          Product2 product = new Product2();
          product.Name = opp.Name + ' : Product : ' + i;
          uow.registerNew(product);   
          PricebookEntry pbe = new PricebookEntry();
          pbe.UnitPrice = 10;
          pbe.IsActive = true;
          pbe.UseStandardPrice = false;
          pbe.Pricebook2Id = pricebookId;
          uow.registerNew(pbe, PricebookEntry.Product2Id, product);   
          OpportunityLineItem oppLineItem = new OpportunityLineItem();
          oppLineItem.Quantity = 1;
          oppLineItem.TotalPrice = 10;
          uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
          uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
        }
      }
      uow.commitWork();
    }
    
    // Assert Results 
    assertResults('UoW');
    /* Oddly a setSavePoint consumes a DML */
    System.assertEquals(5, Limits.getDmlStatements());

    // Records to update
    List<Opportunity> opps = [
      SELECT Id, Name, (Select Id FROM OpportunityLineItems) 
      FROM Opportunity 
      WHERE Name 
      LIKE 'UoW Test Name %' 
      ORDER BY Name
    ];
    
    // Update some records with UnitOfWork
    {
      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS); 
      Opportunity opp = opps[0];
      opp.Name = opp.Name + ' Changed'; 
      uow.registerDirty(opp);     
      Product2 product = new Product2();
      product.Name = opp.Name + ' : New Product';
      uow.registerNew(product);   
      PricebookEntry pbe = new PricebookEntry();
      pbe.UnitPrice = 10;
      pbe.IsActive = true;
      pbe.UseStandardPrice = false;
      pbe.Pricebook2Id = pricebookId;
      uow.registerNew(pbe, PricebookEntry.Product2Id, product);
      OpportunityLineItem newOppLineItem = new OpportunityLineItem();
      newOppLineItem.Quantity = 1;
      newOppLineItem.TotalPrice = 10;
      uow.registerRelationship(newOppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
      uow.registerNew(newOppLineItem, OpportunityLineItem.OpportunityId, opp);      
      OpportunityLineItem existingOppLine = opp.OpportunityLineItems[0];
      existingOppLine.Quantity = 2;
      uow.registerDirty(existingOppLine);
      uow.commitWork();
    }
    
    // Assert Results
    // System.assertEquals(12, Limits.getDmlStatements());        
    opps = [
      SELECT Id, Name, (Select Id, PricebookEntry.Product2.Name, Quantity 
        FROM OpportunityLineItems 
        ORDER BY PricebookEntry.Product2.Name) 
      FROM Opportunity 
      WHERE Name 
      LIKE 'UoW Test Name %' 
      ORDER BY Name
    ];
    System.assertEquals(10, opps.size());
    System.assertEquals('UoW Test Name 0 Changed', opps[0].Name);
    System.assertEquals(2, opps[0].OpportunityLineItems.size());
    System.assertEquals(2, opps[0].OpportunityLineItems[0].Quantity);   
    System.assertEquals('UoW Test Name 0 Changed : New Product', opps[0].OpportunityLineItems[1].PricebookEntry.Product2.Name);
    
    // Delete some records with the UnitOfWork
    {
      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS); 
      uow.registerDeleted(opps[0].OpportunityLineItems[1].PricebookEntry.Product2); // Delete PricebookEntry Product 
      uow.registerDeleted(opps[0].OpportunityLineItems[1].PricebookEntry); // Delete PricebookEntry
      uow.registerDeleted(opps[0].OpportunityLineItems[1]); // Delete OpportunityLine Item
      uow.commitWork();
    }   
    
    // Assert Results
    //System.assertEquals(16, Limits.getDmlStatements());   
    opps = [
      SELECT Id, Name, (Select Id, PricebookEntry.Product2.Name, Quantity 
        FROM OpportunityLineItems 
        ORDER BY PricebookEntry.Product2.Name) 
      FROM Opportunity 
      WHERE Name 
      LIKE 'UoW Test Name %' 
      ORDER BY Name
    ];
    List<Product2> prods = [SELECT Id FROM Product2 WHERE Name = 'UoW Test Name 0 Changed : New Product'];
    System.assertEquals(10, opps.size());
    System.assertEquals('UoW Test Name 0 Changed', opps[0].Name);
    System.assertEquals(1, opps[0].OpportunityLineItems.size()); // Should have deleted OpportunityLineItem added above
    System.assertEquals(0, prods.size()); // Should have deleted Product added above        
  }
    
  @IsTest
  public static void testUnitOfWorkUseCase1() {
    Id pricebookId = Test.getStandardPricebookId();
    
    // Insert Opporunities with UnitOfWork
    {
      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);       
      for (Integer o = 0; o < 10; o++) {
        Opportunity opp = new Opportunity();
        opp.Name = 'UoW Test Name ' + o;
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
                
        uow.registerNew(opp);   
        Product2 product = new Product2();
        product.Name = opp.Name + ' : Product : ' + o;
        uow.registerNew(product);   
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 10;
        pbe.IsActive = true;
        pbe.UseStandardPrice = false;
        pbe.Pricebook2Id = pricebookId;
        uow.registerNew(pbe, PricebookEntry.Product2Id, product);   
        for (Integer i = 0; i < o + 1; i++) {           
          OpportunityLineItem oppLineItem = new OpportunityLineItem();
          oppLineItem.Quantity = 1;
          oppLineItem.TotalPrice = 10;
          uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
          uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
        }
      }   
      uow.commitWork();
    }

    // Query Opportunity    
    List<Opportunity> opportunities = 
      [SELECT Id, Name, Amount, 
        (SELECT Id, PricebookEntry.Id, PricebookEntry.Product2.Id, PricebookEntry.Product2.Name, UnitPrice, Quantity FROM OpportunityLineItems ORDER BY PricebookEntry.Product2.Id) 
       FROM Opportunity 
       WHERE Name 
       LIKE 'UoW Test Name %' 
       ORDER BY Name];
    System.assertEquals(10, opportunities.size());
    System.assertEquals(100, opportunities[9].Amount);    
    System.assertEquals(10, opportunities[9].OpportunityLineItems.size()); // Should have deleted OpportunityLineItem added above      
       
    {
      // Consolidate Products on the Opportunities
      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
      for (Opportunity opportunity : opportunities) {     
        // Group the lines by Product
        Map<Id, List<OpportunityLineItem>> linesByGroup = new Map<Id, List<OpportunityLineItem>>();       
        for (OpportunityLineItem opportunityLineItem : opportunity.OpportunityLineItems) {
          Id productId = opportunityLineItem.PricebookEntry.Product2.Id;
          List<OpportunityLineItem> linesForThisProduct = linesByGroup.get(productId);
          if (linesForThisProduct == null) {
            linesByGroup.put(productId, (linesForThisProduct = new List<OpportunityLineItem>()));
          }
          linesForThisProduct.add(opportunityLineItem);
        }
        // For groups with more than one 1 line, delete those lines and create a new consolidated one
        for (List<OpportunityLineItem> linesForGroup : linesByGroup.values()) {
          // More than one line with this product?
          if (linesForGroup.size() > 1) {
            // Delete the duplicate product lines and caculate new quantity total
            Decimal consolidatedQuantity = 0;
            for (OpportunityLineItem lineForProduct : linesForGroup) {
              consolidatedQuantity += lineForProduct.Quantity;
              uow.registerDeleted(lineForProduct);
            }
            // Create new consolidated line
            OpportunityLineItem consolidatedLine = new OpportunityLineItem();
            consolidatedLine.Quantity = consolidatedQuantity;
            consolidatedLine.UnitPrice = linesForGroup[0].UnitPrice;
            consolidatedLine.PricebookEntryId = linesForGroup[0].PricebookEntry.Id;
            uow.registerNew(consolidatedLine, OpportunityLineItem.OpportunityId, opportunity);            
            // Note the last consolidation date
            opportunity.Description = 'Consolidated on ' + System.today();
            uow.registerDirty(opportunity);
          }         
        }       
      }
      uow.commitWork();
    }
    
    // Query Opportunity    
    opportunities = 
      [SELECT Id, Name, Amount,
        (SELECT Id, PricebookEntry.Id, PricebookEntry.Product2.Id, PricebookEntry.Product2.Name, UnitPrice, Quantity FROM OpportunityLineItems ORDER BY PricebookEntry.Product2.Id) 
       FROM Opportunity 
       WHERE Name 
       LIKE 'UoW Test Name %' 
       ORDER BY Name];
    System.assertEquals(10, opportunities.size());
    System.assertEquals(100, opportunities[9].Amount);
    System.assertEquals(1, opportunities[9].OpportunityLineItems.size()); // Should have deleted OpportunityLineItem added above          
  }
    
  @IsTest
  public static void testUnitOfWorkOverhead() {
    Id pricebookId = Test.getStandardPricebookId(); 
    
    // Insert Opporunities with UnitOfWork
    {
      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);       
      for (Integer o = 0; o < 10; o++) {
        Opportunity opp = new Opportunity();
        opp.Name = 'UoW Test Name ' + o;
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
        uow.registerNew(opp);   
        for (Integer i = 0; i < o + 1; i++) {           
          Product2 product = new Product2();
          product.Name = opp.Name + ' : Product : ' + i;
          uow.registerNew(product);   
          PricebookEntry pbe = new PricebookEntry();
          pbe.UnitPrice = 10;
          pbe.IsActive = true;
          pbe.UseStandardPrice = false;
          pbe.Pricebook2Id = pricebookId;
          uow.registerNew(pbe, PricebookEntry.Product2Id, product);   
          OpportunityLineItem oppLineItem = new OpportunityLineItem();
          oppLineItem.Quantity = 1;
          oppLineItem.TotalPrice = 10;
          uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
          uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
        }
      }   
      uow.commitWork();
    }
    
    // Assert Results from using UnitOfWork
    Integer costToCommitUoW = Limits.getCpuTime();
    System.assertEquals(5, Limits.getDmlStatements());
    assertResults('UoW');
        
    // Insert Opportunities "without" UnitOfWork
    {
      List<Opportunity> opps = new List<Opportunity>();
      List<List<Product2>> productsByOpp = new List<List<Product2>>();    
      List<List<PricebookEntry>> pricebookEntriesByOpp = new List<List<PricebookEntry>>();    
      List<List<OpportunityLineItem>> oppLinesByOpp = new List<List<OpportunityLineItem>>();    
      for (Integer o = 0; o < 10; o++) {
        Opportunity opp = new Opportunity();
        opp.Name = 'NoUoW Test Name ' + o;
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
        opps.add(opp);
        List<Product2> products = new List<Product2>();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        for (Integer i = 0; i < o + 1; i++) {           
          Product2 product = new Product2();
          product.Name = opp.Name + ' : Product : ' + i;
          products.add(product);
          PricebookEntry pbe = new PricebookEntry();
          pbe.UnitPrice = 10;
          pbe.IsActive = true;
          pbe.UseStandardPrice = false;
          pbe.Pricebook2Id = pricebookId;
          pricebookEntries.add(pbe);
          OpportunityLineItem oppLineItem = new OpportunityLineItem();
          oppLineItem.Quantity = 1;
          oppLineItem.TotalPrice = 10;
          oppLineItems.add(oppLineItem);
        }
        productsByOpp.add(products);
        pricebookEntriesByOpp.add(pricebookEntries);
        oppLinesByOpp.add(oppLineItems);        
      }
      // Insert Opportunities
      insert opps;
      // Insert Products
      List<Product2> allProducts = new List<Product2>(); 
      for (List<Product2> products : productsByOpp) {
        allProducts.addAll(products);     
      }
      insert allProducts;
      // Insert Pricebooks
      Integer oppIdx = 0;     
      List<PricebookEntry> allPricebookEntries = new List<PricebookEntry>();        
      for (List<PricebookEntry> pricebookEntries : pricebookEntriesByOpp) {
        List<Product2> products = productsByOpp[oppIdx++];
        Integer lineIdx = 0;
        for (PricebookEntry pricebookEntry : pricebookEntries) {
          pricebookEntry.Product2Id = products[lineIdx++].Id;
        }
        allPricebookEntries.addAll(pricebookEntries);
      }     
      insert allPricebookEntries;
      // Insert Opportunity Lines
      oppIdx = 0;           
      List<OpportunityLineItem> allOppLineItems = new List<OpportunityLineItem>();      
      for (List<OpportunityLineItem> oppLines : oppLinesByOpp) {
        List<PricebookEntry> pricebookEntries = pricebookEntriesByOpp[oppIdx];
        Integer lineIdx = 0;
        for (OpportunityLineItem oppLine : oppLines) {
          oppLine.OpportunityId = opps[oppIdx].Id;
          oppLine.PricebookEntryId = pricebookEntries[lineIdx++].Id;
        }
        allOppLineItems.addAll(oppLines);
        oppIdx++;
      }     
      insert allOppLineItems;
    }
    
    // Assert Results from not using UnitOfWork
    Integer costToCommitNoUoW = Limits.getCpuTime() - costToCommitUoW;
    assertResults('NoUoW');
    
    // Assert an acceptable statement % cost for using the UnitOfWork approach
    System.assert((costToCommitUoW - costToCommitNoUoW) <= 3000, 'Overhead of using UnitOfWork has grown above 3000 statements.');            
  }

  @IsTest
  static void testUnitOfWorkNewWithReflectiveLookups() {
    Account accountTop = new Account(Name = 'Top Account');
    Account accountMiddle = new Account(Name = 'Middle Account');
    Account accountBottom = new Account(Name = 'Bottom Account');
    Test.startTest();
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{ Account.SObjectType }
    );
    uow.registerNew(accountTop);
    uow.registerNew(accountMiddle, Account.ParentId, accountTop);
    uow.registerNew(accountBottom, Account.ParentId, accountMiddle);
    uow.commitWork();
    Test.stopTest();
    accountTop = [SELECT Id, ParentId FROM Account WHERE Id = :accountTop.Id];
    accountMiddle = [SELECT Id, ParentId FROM Account WHERE Id = :accountMiddle.Id];
    accountBottom = [SELECT Id, ParentId FROM Account WHERE Id = :accountBottom.Id];
    System.assertEquals(null, accountTop.ParentId, 'The top account should not be related to a parent account');
    System.assertEquals(accountTop.Id, accountMiddle.ParentId, 'The middle account should be related to the top account');
    System.assertEquals(accountMiddle.Id, accountBottom.ParentId, 'The bottom account should be related to the middle account');
  }
  
  @IsTest
  static void testUnitOfWorkSameDirtyRecord() {
    Account acc = new Account();
    acc.Name = 'Test Account';
    insert acc;
    Test.startTest();
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{ Account.SObjectType },
      true
    );
    acc.Name = 'Test Account Updated';
    uow.registerDirty(acc);
    acc.Description = 'Description';
    uow.registerDirty(acc);
    uow.commitWork();
    Test.stopTest();
    Account result = [SELECT Name, Description FROM Account LIMIT 1];
    System.assertEquals('Test Account Updated', result.Name);
    System.assertEquals('Description', result.Description);
  }

  @IsTest
  static void testUnitOfWorkUpsert() {
    List<Account> accounts = new List<Account>();
    Account acc1 = new Account();
    acc1.Name = 'Test Account 1';
    insert acc1;
    acc1.Description = 'Description';
    Account acc2 = new Account();
    acc2.Name = 'Test Account 2';
    acc2.Description = 'Description';
    accounts.add(acc1);
    accounts.add(acc2);
    Test.startTest();
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{ Account.SObjectType }
    );
    uow.registerUpsert(accounts);
    uow.commitWork();
    Test.stopTest();
    System.assertEquals(2, [SELECT Count() FROM Account]);
    for (Account acc : [SELECT Description FROM Account]) {
      System.assertEquals('Description', acc.Description);
    }
  }

  @IsTest
  static void testUnitOfWorkUpsertSecure() {
    List<Account> accounts = new List<Account>();
    Account acc1 = new Account();
    acc1.Name = 'Test Account 1';
    insert acc1;
    acc1.Description = 'Description';
    Account acc2 = new Account();
    acc2.Name = 'Test Account 2';
    acc2.Description = 'Description';
    accounts.add(acc1);
    accounts.add(acc2);
    Test.startTest();
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{ Account.SObjectType },
      true
    );
    uow.registerUpsert(accounts);
    uow.commitWork();
    Test.stopTest();
    System.assertEquals(2, [SELECT Count() FROM Account]);
    for (Account acc : [SELECT Description FROM Account]) {
      System.assertEquals('Description', acc.Description);
    }
  }

  @IsTest
  static void testUnitOfWorkMultipleNew() {
    List<Account> accounts = new List<Account>();
    Account acc1 = new Account();
    acc1.Name = 'Test Account 1';
    Account acc2 = new Account();
    acc2.Name = 'Test Account 2';
    accounts.add(acc1);
    accounts.add(acc2);
    Test.startTest();
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{ Account.SObjectType },
      true
    );
    uow.registerNew(accounts);
    uow.commitWork();
    Test.stopTest();
    System.assertEquals(2, [SELECT Count() FROM Account]);
  }

  @IsTest
  static void testUnitOfWorkMultipleDirty() {
    List<Account> accounts = new List<Account>();
    Account acc1 = new Account();
    acc1.Name = 'Test Account 1';
    Account acc2 = new Account();
    acc2.Name = 'Test Account 2';
    accounts.add(acc1);
    accounts.add(acc2);
    insert accounts;
    Test.startTest();
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{ Account.SObjectType },
      true
    );
    List<Account> results = [SELECT Description FROM Account];
    for (Account acc : results) {
      acc.Description = 'Description';
    }
    uow.registerDirty(results);
    uow.commitWork();
    uow.getRecords();
    Test.stopTest();
    System.assertEquals(2, [SELECT Count() FROM Account]);
    for (Account acc : [SELECT Description FROM Account]) {
      System.assertEquals('Description', acc.Description);
    }
  }

  @IsTest
  static void testWithSelector() {
    Contact cont = new Contact();
    cont.FirstName = 'Testing';
    cont.LastName = 'Test';
    insert cont;
    Test.startTest();
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{ Contact.SObjectType },
      true
    );
    cont.FirstName = 'Testing1';
    uow.registerDirty(cont);
    uow.commitWork();
    Test.stopTest();
    System.assertEquals(1, [SELECT Count() FROM Contact]);
    System.assertEquals('Testing1', [SELECT FirstName FROM Contact LIMIT 1].FirstName);
  }

  @IsTest
  static void testDmlException() {
    Test.startTest();
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{ Account.SObjectType }
    );
    Account acc = new Account();
    try {
      uow.registerNew(acc);
      uow.commitWork();
      System.assert(false, 'Expected an exception');
    } catch (System.DmlException e) {
      System.assert(true, 'Exception caught');
    } catch (Exception e) {
      System.assert(false, 'Expected a DmlException');
    }
    Test.stopTest();
  }

  // TODO: make a restricted user
  // @IsTest
  // static void testCrudException() {
  //  Test.startTest();
  //  User usr = [SELECT Id FROM User WHERE Username LIKE '%restricted%' LIMIT 1];
  //  SObjectUnitOfWork uow = new SObjectUnitOfWork(
  //    new List<Schema.SObjectType>{ Account.SObjectType },
  //    true
  //  );
  //  Account acc = new Account();
  //  acc.Name = 'Testing';
  //  try {
  //    System.runAs(usr) {
  //      uow.registerNew(acc);
  //      uow.commitWork();
  //    }
  //    System.assert(false, 'Expected an exception');
  //  } catch (CrudException e) {
  //    System.assert(true, 'Exception caught');
  //  } catch (Exception e) {
  //    System.assert(false, 'Expected a CrudException');
  //  }
  //  Test.stopTest();
  // }
  
  private static void assertResults(String prefix) {
    // Standard Assertions on tests data inserted by tests
    String filter = prefix + ' Test Name %';
    List<Opportunity> opps = [SELECT Id, Name, (SELECT Id FROM OpportunityLineItems) FROM Opportunity WHERE Name LIKE :filter ORDER BY Name];
    System.assertEquals(10, opps.size());
    System.assertEquals(1, opps[0].OpportunityLineItems.size());    
    System.assertEquals(2, opps[1].OpportunityLineItems.size());    
    System.assertEquals(3, opps[2].OpportunityLineItems.size());    
    System.assertEquals(4, opps[3].OpportunityLineItems.size());    
    System.assertEquals(5, opps[4].OpportunityLineItems.size());    
    System.assertEquals(6, opps[5].OpportunityLineItems.size());    
    System.assertEquals(7, opps[6].OpportunityLineItems.size());    
    System.assertEquals(8, opps[7].OpportunityLineItems.size());    
    System.assertEquals(9, opps[8].OpportunityLineItems.size());    
    System.assertEquals(10, opps[9].OpportunityLineItems.size());   
  }

}