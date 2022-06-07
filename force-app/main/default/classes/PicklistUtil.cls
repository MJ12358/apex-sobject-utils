/**
 * Created on Sat Jun 04 2022
 *
 * Copyright (c) 2022 Matt Jants
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

public inherited sharing class PicklistUtil {

  public static Boolean isCodesEnabled {
    get {
      if (isCodesEnabled == null) {
        isCodesEnabled = SObjectUtil.isValid(Lead.SObjectType, 'CountryCode');
      }
      return isCodesEnabled;
    }
    private set;
  }

/**
 *  Get picklist labels
 *  @param Schema.SObjectField
 *  @return List<String>
 */
  public static List<String> getLabels(Schema.SObjectField field) {
    Set<String> result = getValueByLabel(field).keySet();
    return new List<String>(result);
  }

/**
 *  Get picklist labels
 *  @param String The sObject name
 *  @param String The sObject field name
 *  @return List<String>
 */
  @AuraEnabled
  public static List<String> getLabels(String sObjectName, String fieldName) {
    return getLabels(SObjectUtil.getAllFields(sObjectName).get(fieldName));
  }

/**
 *  Get picklist values
 *  @param Schema.SObjectField
 *  @return List<String>
 */
  public static List<String> getValues(Schema.SObjectField field) {
    return getValueByLabel(field).values();
  }

/**
 *  Get picklist values
 *  @param String The sObject name
 *  @param String The sObject field name
 *  @return List<String>
 */
  @AuraEnabled
  public static List<String> getValues(String sObjectName, String fieldName) {
    return getValues(SObjectUtil.getAllFields(sObjectName).get(fieldName));
  }

/**
 *  Get map of picklist value by label
 *  @param Schema.SObjectField
 *  @return Map<String,String>
 */
  public static Map<String, String> getValueByLabel(Schema.SObjectField field) {
    Map<String, String> result = new Map<String, String>();
    if (field != null) {
      Schema.DescribeFieldResult fieldResult = field.getDescribe();
      if (fieldResult.getType() == Schema.DisplayType.PICKLIST || fieldResult.getType() == Schema.DisplayType.MULTIPICKLIST) {
        for (Schema.PicklistEntry ple : fieldResult.getPicklistValues()) {
          if (ple.isActive()) {
            result.put(ple.getLabel(), ple.getValue());
          }
        }
      }
    }
    return result;
  }

/**
 *  Get country picklist labels
 *  @return List<String>
 */
  @AuraEnabled
  public static List<String> getCountryLabels() {
    Set<String> result = getCountryValueByLabel().keySet();
    return new List<String>(result);
  }

/**
 *  Get country picklist values
 *  @return List<String>
 */
  @AuraEnabled
  public static List<String> getCountryValues() {
    return getCountryValueByLabel().values();
  }

/**
 *  Get country picklist value by label
 *  @return Map<String, String>
 */
  public static Map<String, String> getCountryValueByLabel() {
    Map<String, String> result = new Map<String, String>();
    if (!isCodesEnabled) {
      return result;
    }
    Schema.SObjectField field = SObjectUtil.getAllFields('User').get('CountryCode');
    for (Schema.PicklistEntry ple : field.getDescribe().getPicklistValues()) {
      if (ple.isActive()) {
        result.put(ple.getLabel(), ple.getValue());
      }
    }
    return result;
  }

/**
 *  Get state picklist labels
 *  @return List<String>
 */
  @AuraEnabled
  public static List<String> getStateLabels() {
    Set<String> result = getStateValueByLabel().keySet();
    return new List<String>(result);
  }

/**
 *  Get state picklist values
 *  @return List<String>
 */
  @AuraEnabled
  public static List<String> getStateValues() {
    return getStateValueByLabel().values();
  }

/**
 *  Get state picklist value by label
 *  @return Map<String, String>
 */
  public static Map<String, String> getStateValueByLabel() {
    Map<String, String> result = new Map<String, String>();
    if (!isCodesEnabled) {
      return result;
    }
    Schema.SObjectField field = SObjectUtil.getAllFields('User').get('StateCode');
    for (Schema.PicklistEntry ple : field.getDescribe().getPicklistValues()) {
      if (ple.isActive()) {
        result.put(ple.getLabel(), ple.getValue());
      }
    }
    return result;
  }

}