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

public inherited sharing class RecordTypeUtil {

/**
 *  Get record types
 *  @param Schema.SObjectType
 *  @return Map<Id, String>
 */
  public static Map<Id, String> get(Schema.SObjectType sObjectType) {
    Map<Id, String> result = new Map<Id, String>();
    if (sObjectType != null) {
      for (Schema.RecordTypeInfo info : sObjectType.getDescribe().getRecordTypeInfos()) {
        // active, available and not master
        if (info.isActive() && info.isAvailable() && !info.isMaster()) {
          result.put(info.getRecordTypeId(), info.getName());
        }
      }
    }
    return result;
  }

/**
 *  Get record types
 *  @param String sObjectName
 *  @return Map<Id, String>
 */
  public static Map<Id, String> get(String sObjectName) {
    return get(SObjectUtil.convertNameToType(sObjectName));
  }

/**
 *  Get record type id
 *  @param Schema.DescribeSObjectResult The sObjectDescribe
 *  @param String The record type name
 *  @return Id The record type ID
 */
  public static Id getId(Schema.DescribeSObjectResult sObjectDesc, String recTypeName) {
    if (sObjectDesc != null && String.isNotBlank(recTypeName)) {
      Map<String, Schema.RecordTypeInfo> recordTypeMap = sObjectDesc.getRecordTypeInfosByName();
      if (recordTypeMap.get(recTypeName) != null) {
        return recordTypeMap.get(recTypeName).getRecordTypeId();
      }
    }
    return null;
  }

/**
 *  Get record type id
 *  @param Schema.SObjectType The sObjectType
 *  @param String The record type name
 *  @return Id The record type ID
 */
  public static Id getId(Schema.SObjectType sObjectType, String recTypeName) {
    if (sObjectType != null) {
      return getId(sObjectType.getDescribe(), recTypeName);
    }
    return null;
  }

/**
 *  Get record type id
 *  @param SObject The sObject
 *  @param String The record type name
 *  @return Id The record type Id
 */
  public static Id getId(SObject sObj, String recTypeName) {
    if (sObj != null) {
      return getId(sObj.getSObjectType(), recTypeName);
    }
    return null;
  }

/**
 *  Get record type id
 *  @param String The sObject name
 *  @param String The record type name
 *  @return Id The record type ID
 */
  public static Id getId(String sObjectName, String recTypeName) {
    Schema.SObjectType sObjectType = SObjectUtil.convertNameToType(sObjectName);
    return getId(sObjectType, recTypeName);
  }

/**
 *  Get record type label
 *  @param Schema.DescribeSObjectResult The sObjectDescribe
 *  @param Id The record type id
 *  @return String The record type label
 */
  public static String getLabel(Schema.DescribeSObjectResult sObjectDesc, Id recTypeId) {
    if (sObjectDesc != null && String.isNotBlank(recTypeId)) {
      Map<Id, Schema.RecordTypeInfo> recordTypeMap = sObjectDesc.getRecordTypeInfosById();
      if (recordTypeMap.get(recTypeId) != null) {
        return recordTypeMap.get(recTypeId).getName();
      }
    }
    return null;
  }

/**
 *  Get record type label
 *  @param Schema.SObjectType The sObjectType
 *  @param Id The record type id
 *  @return String The record type label
 */
  public static String getLabel(Schema.SObjectType sObjectType, Id recTypeId) {
    return getLabel(sObjectType?.getDescribe(), recTypeId);
  }

/**
 *  Get record type label
 *  @param SObject The sObject
 *  @param Id The record type id
 *  @return String The record type label
 */
  public static String getLabel(SObject sObj, Id recTypeId) {
    return getLabel(sObj?.getSObjectType(), recTypeId);
  }

/**
 *  Get record type label
 *  @param String The sObject name
 *  @param Id The record type id
 *  @return String The record type label
 */
  public static String getLabel(String sObjectName, Id recTypeId) {
    Schema.SObjectType sObjectType = SObjectUtil.convertNameToType(sObjectName);
    return getLabel(sObjectType, recTypeId);
  }

/**
 *  Get record type name
 *  @param Schema.DescribeSObjectResult The sObjectDescribe
 *  @param Id The record type id
 *  @return String The record type name
 */
  public static String getName(Schema.DescribeSObjectResult sObjectDesc, Id recTypeId) {
    if (sObjectDesc != null && String.isNotBlank(recTypeId)) {
      Map<Id, Schema.RecordTypeInfo> recordTypeMap = sObjectDesc.getRecordTypeInfosById();
      if (recordTypeMap.get(recTypeId) != null) {
        return recordTypeMap.get(recTypeId).getDeveloperName();
      }
    }
    return null;
  }

/**
 *  Get record type name
 *  @param Schema.SObjectType The sObjectType
 *  @param Id The record type id
 *  @return String The record type name
 */
  public static String getName(Schema.SObjectType sObjectType, Id recTypeId) {
    return getName(sObjectType?.getDescribe(), recTypeId);
  }

/**
 *  Get record type name
 *  @param SObject The sObject
 *  @param Id The record type id
 *  @return String The record type name
 */
  public static String getName(SObject sObj, Id recTypeId) {
    return getName(sObj?.getSObjectType(), recTypeId);
  }

/**
 *  Get record type name
 *  @param String The sObject name
 *  @param Id The record type id
 *  @return String The record type name
 */
  public static String getName(String sObjectName, Id recTypeId) {
    Schema.SObjectType sObjectType = SObjectUtil.convertNameToType(sObjectName);
    return getName(sObjectType, recTypeId);
  }
}
