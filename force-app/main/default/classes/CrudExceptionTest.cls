@IsTest
public class CrudExceptionTest {

  private static Schema.SObjectType sObjectType = Account.SObjectType;

  @IsTest
  static void testRead() {
    String expectedOutput = String.format(System.Label.SObjectCrudException,
      new List<Object>{
        'READ',
        sObjectType
      }
    );
    Test.startTest();
    try {
      throw new CrudException(DatabaseOperation.READ, sObjectType);
    } catch (CrudException e) {
      System.assertEquals(expectedOutput, e.getMessage());
    } catch (Exception e) {
      System.assert(false, 'Expected a CrudException');
    }
    Test.stopTest();
  }

  @IsTest
  static void testInsert() {
    String expectedOutput = String.format(System.Label.SObjectCrudException,
      new List<Object>{
        'INSERTX',
        sObjectType
      }
    );
    Test.startTest();
    try {
      throw new CrudException(DatabaseOperation.INSERTX, sObjectType);
    } catch (CrudException e) {
      System.assertEquals(expectedOutput, e.getMessage());
    } catch (Exception e) {
      System.assert(false, 'Expected a CrudException');
    }
    Test.stopTest();
  }

  @IsTest
  static void testUpdate() {
    String expectedOutput = String.format(System.Label.SObjectCrudException,
      new List<Object>{
        'UPDATEX',
        sObjectType
      }
    );
    Test.startTest();
    try {
      throw new CrudException(DatabaseOperation.UPDATEX, sObjectType);
    } catch (CrudException e) {
      System.assertEquals(expectedOutput, e.getMessage());
    } catch (Exception e) {
      System.assert(false, 'Expected a CrudException');
    }
    Test.stopTest();
  }

  @IsTest
  static void testUpsert() {
    String expectedOutput = String.format(System.Label.SObjectCrudException,
      new List<Object>{
        'UPSERTX',
        sObjectType
      }
    );
    Test.startTest();
    try {
      throw new CrudException(DatabaseOperation.UPSERTX, sObjectType);
    } catch (CrudException e) {
      System.assertEquals(expectedOutput, e.getMessage());
    } catch (Exception e) {
      System.assert(false, 'Expected a CrudException');
    }
    Test.stopTest();
  }

  @IsTest
  static void testDelete() {
    String expectedOutput = String.format(System.Label.SObjectCrudException,
      new List<Object>{
        'DELETEX',
        sObjectType
      }
    );
    Test.startTest();
    try {
      throw new CrudException(DatabaseOperation.DELETEX, sObjectType);
    } catch (CrudException e) {
      System.assertEquals(expectedOutput, e.getMessage());
    } catch (Exception e) {
      System.assert(false, 'Expected a CrudException');
    }
    Test.stopTest();
  }

  @IsTest
  static void testUnknown() {
    String expectedOutput = String.format(System.Label.SObjectCrudException,
      new List<Object>{
        'UNKNOWN',
        sObjectType
      }
    );
    Test.startTest();
    try {
      throw new CrudException(DatabaseOperation.UNKNOWN, sObjectType);
    } catch (CrudException e) {
      System.assertEquals(expectedOutput, e.getMessage());
    } catch (Exception e) {
      System.assert(false, 'Expected a CrudException');
    }
    Test.stopTest();
  }

  @IsTest
  static void testDatabaseException() {
    String expectedOutput = String.format(System.Label.SObjectCrudException,
      new List<Object>{
        'READ',
        sObjectType
      }
    );
    Test.startTest();
    try {
      throw new CrudException(DatabaseOperation.READ, sObjectType);
    } catch (DatabaseException e) {
      System.assertEquals(expectedOutput, e.getMessage());
    } catch (Exception e) {
      System.assert(false, 'Expected a DatabaseException');
    }
    Test.stopTest();
  }

}
