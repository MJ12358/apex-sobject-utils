@IsTest
public class FlsExceptionTest {

	private static Schema.SObjectType sObjectType = Account.SObjectType;
	private static Schema.SObjectField sObjectField = Account.Name;

	@IsTest
	static void testRead() {
		String expectedOutput = String.format(System.Label.SObjectFlsException,
			new List<Object>{
				'READ',
				sObjectField,
				sObjectType
			}
		);
		Test.startTest();
		try {
			throw new FlsException(DatabaseOperation.READ, sObjectType, sObjectField);
		} catch (FlsException e) {
			System.assertEquals(expectedOutput, e.getMessage());
		} catch (Exception e) {
			System.assert(false, 'Expected a FlsException');
		}
		Test.stopTest();
	}

	@IsTest
	static void testInsert() {
		String expectedOutput = String.format(System.Label.SObjectFlsException,
			new List<Object>{
				'INSERTX',
				sObjectField,
				sObjectType
			}
		);
		Test.startTest();
		try {
			throw new FlsException(DatabaseOperation.INSERTX, sObjectType, sObjectField);
		} catch (FlsException e) {
			System.assertEquals(expectedOutput, e.getMessage());
		} catch (Exception e) {
			System.assert(false, 'Expected a FlsException');
		}
		Test.stopTest();
	}

	@IsTest
	static void testUpdate() {
		String expectedOutput = String.format(System.Label.SObjectFlsException,
			new List<Object>{
				'UPDATEX',
				sObjectField,
				sObjectType
			}
		);
		Test.startTest();
		try {
			throw new FlsException(DatabaseOperation.UPDATEX, sObjectType, sObjectField);
		} catch (FlsException e) {
			System.assertEquals(expectedOutput, e.getMessage());
		} catch (Exception e) {
			System.assert(false, 'Expected a FlsException');
		}
		Test.stopTest();
	}

	@IsTest
	static void testUnknown() {
		String expectedOutput = String.format(System.Label.SObjectFlsException,
		new List<Object>{
			'UNKNOWN',
			sObjectField,
			sObjectType
		}
	);
		Test.startTest();
		try {
			throw new FlsException(DatabaseOperation.UNKNOWN, sObjectType, sObjectField);
		} catch (DatabaseException e) {
			System.assertEquals(expectedOutput, e.getMessage());
		} catch (Exception e) {
			System.assert(false, 'Expected a FlsException');
		}
		Test.stopTest();
	}

	@IsTest
	static void testDatabaseException() {
		String expectedOutput = String.format(System.Label.SObjectFlsException,
			new List<Object>{
				'READ',
				sObjectField,
				sObjectType
			}
		);
		Test.startTest();
		try {
			throw new FlsException(DatabaseOperation.READ, sObjectType, sObjectField);
		} catch (DatabaseException e) {
			System.assertEquals(expectedOutput, e.getMessage());
		} catch (Exception e) {
			System.assert(false, 'Expected a DatabaseException');
		}
		Test.stopTest();
	}

}
