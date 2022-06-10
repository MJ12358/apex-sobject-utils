/**
 * Created on Feb 7 2021
 *
 * Copyright (c) 2021 Matt Jants
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *    are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 * - Neither the name of the company, software or the names of its contributors 
 *    may be used to endorse or promote products derived from this software without 
 *    specific prior written permission.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 *  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, TORT (INCLUDING NEGLIGENCE) OR OTHERWISE, 
 *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE USE OF THIS SOFTWARE OR OTHER DEALINGS IN THE SOFTWARE, 
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

public class UserUtil {

/**
 *  Get a users portal account Id
 *  @param Id
 *  @return Id
 */
  public static Id getPortalAccountId(Id userId) {
    User result = [
      SELECT Id, Contact.AccountId 
      FROM User 
      WHERE Id = :userId
    ];
    return result.Contact?.AccountId;
  }

/**
 *  Check if the user is an administrator
 *  @param Id
 *  @return Boolean
 */
  public static Boolean isAdmin(Id userId) {
    List<User> users = [
      SELECT Id 
      FROM User 
      WHERE Id = :userId 
        AND Profile.Name = 'System Administrator'
    ];
    return !users.isEmpty();
  }

/**
 *  Check if the user is an administrator
 *  @return Boolean
 */
  public static Boolean isAdmin() {
    return isAdmin(System.UserInfo.getUserId());
  }

/**
 *  Check if the user is a guest
 *  @param Id
 *  @return Boolean
 */
  public static Boolean isGuest(Id userId) {
    List<User> users = [
      SELECT Id 
      FROM User 
      WHERE Id = :userId 
        AND Profile.UserLicense.LicenseDefinitionKey = 'PID_Guest_User'
    ];
    return !users.isEmpty();
  }

/**
 *  Check if the user is a guest
 *  @return Boolean
 */
  public static Boolean isGuest() {
    return isGuest(System.UserInfo.getUserId());
  }

/**
 *  Check if the user is a portal user
 *  @param Id
 *  @return Boolean
 */
  public static Boolean isPortalUser(Id userId) {
    return getPortalAccountId(userId) != null;
  }

/**
 *  Check if the user is portal user
 *  @return Boolean
 */
  public static Boolean isPortalUser() {
    return isPortalUser(System.UserInfo.getUserId());
  }

}
