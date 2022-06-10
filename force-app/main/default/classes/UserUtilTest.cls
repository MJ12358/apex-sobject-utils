@IsTest
public class UserUtilTest {

  @IsTest
  static void testIsAdmin() {
    Test.startTest();
    System.assertEquals(true, UserUtil.isAdmin());
    Test.stopTest();
  }

  @IsTest
  static void testIsGuest() {
    Test.startTest();
    System.assertEquals(false, UserUtil.isGuest());
    Test.stopTest();
  }

  @IsTest
  static void testIsPortalUser() {
    Test.startTest();
    System.assertEquals(false, UserUtil.isPortalUser());
    Test.stopTest();
  }

}
