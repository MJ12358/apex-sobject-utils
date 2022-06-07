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

public inherited sharing class FieldSetUtil {

/**
 *	Get Fieldset fields
 *	@param Schema.FieldSet
 *	@return List<String>
 */
  public static List<String> getFields(Schema.FieldSet fieldSet) {
    List<String> result = new List<String>();
    if (fieldSet == null) {
      return result;
    }
    for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
      result.add(fsm.getFieldPath());
    }
    return result;
  }

/**
 *	Get Fieldset fields
 *	@param Schema.SObjectType
 *	@param String The field set name
 *	@return List<String>
 */
  public static List<String> getFields(Schema.SObjectType sObjectType, String fieldSetName) {
    Schema.FieldSet fieldSet = sObjectType?.getDescribe().fieldSets.getMap().get(fieldSetName);
    return getFields(fieldSet);
  }

/**
 *	Get Fieldset fields
 *	@param String The sObject name
 *	@param String The field set name
 *	@return List<String>
 */
  @AuraEnabled
  public static List<String> getFields(String sObjectName, String fieldSetName) {
    Schema.SObjectType sObjectType = SObjectUtil.convertNameToType(sObjectName);
    return getFields(sObjectType, fieldSetName);
  }

/**
 *	Get Fieldset fields described
 *	@param Schema.SObjectType
 *	@param Schema.FieldSet
 *	@return List<Schema.DescribeFieldResult>
 */
  public static List<Schema.DescribeFieldResult> getDescribed(Schema.SObjectType sObjectType, Schema.FieldSet fieldSet) {
    List<Schema.DescribeFieldResult> result = new List<Schema.DescribeFieldResult>();
    if (sObjectType == null || fieldSet == null) {
      return result;
    }
    Map<String, Schema.SObjectField> sObjMap = SObjectUtil.getFieldMap(sObjectType);
    for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
      List<String> split = fsm.getFieldPath().split('\\.');
      String fieldPath;
      if (split.size() > 1) {
        fieldPath = split[split.size() - 2].replace('__r', '__c');
      } else {
        fieldPath = fsm.getFieldPath();
      }
      if (sObjMap.get(fieldPath) != null) {
        result.add(sObjMap.get(fieldPath).getDescribe());
      }
    }
    return result;
  }

/**
 *	Get Fieldset fields described
 *	@param Schema.SObjectType
 *	@param String The field set name
 *	@return List<Schema.DescribeFieldResult>
 */
  public static List<Schema.DescribeFieldResult> getDescribed(Schema.SObjectType sObjectType, String fieldSetName) {
    Schema.FieldSet fieldSet = sObjectType?.getDescribe().fieldSets.getMap().get(fieldSetName);
    return getDescribed(sObjectType, fieldSet);
  }

/**
 *	Get Fieldset fields described
 *	@param String The sObject name
 *	@param String The field set name
 *	@return List<Schema.DescribeFieldResult>
 */
  public static List<Schema.DescribeFieldResult> getDescribed(String sObjectName, String fieldSetName) {
    Schema.SObjectType sObjectType = SObjectUtil.convertNameToType(sObjectName);
    return getDescribed(sObjectType, fieldSetName);
  }

/**
 *	Get Fieldset fields described
 *	@param String The sObject name
 *	@param String The field set name
 *	@return String
 */
  @AuraEnabled
  public static String getDescribedForAura(String sObjectName, String fieldSetName) {
    return System.JSON.serialize(getDescribed(sObjectName, fieldSetName));
  }
}
