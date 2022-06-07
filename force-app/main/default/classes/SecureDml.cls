/**
 * Created on Thu Mar 04 2021
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

// TODO: this needs work

public inherited sharing class SecureDml implements IDml {

  private Boolean enforceFls;

  public SecureDml() {
    this(true);
  }

  public SecureDml(Boolean enforceFls) {
    this.enforceFls = enforceFls;
  }

  public void onInsert(List<SObject> records) {
    if (records == null || records.isEmpty()) {
      return;
    }
    DatabaseOperation operation = DatabaseOperation.INSERTX;
    Schema.DescribeSObjectResult sObjectDesc = records[0].getSObjectType().getDescribe();
    if (!sObjectDesc.isCreateable()) {
      throw new CrudException(operation, sObjectDesc);
    }
    if (this.enforceFls) {
      // checkFLS(operation, sObjectDesc, records);
      // System.SObjectAccessDecision decision = System.Security.stripInaccessible(AccessType.CREATABLE, records);
      // checkRemovedFields(operation, sObjectDesc, decision);
      // records = decision.getRecords(); //! this breaks the reference to the original passed in records
    }
    insert records;
  }

  public void onUpdate(List<SObject> records) {
    if (records == null || records.isEmpty()) {
      return;
    }
    DatabaseOperation operation = DatabaseOperation.UPDATEX;
    Schema.DescribeSObjectResult sObjectDesc = records[0].getSObjectType().getDescribe();
    if (!sObjectDesc.isUpdateable()) {
      throw new CrudException(operation, sObjectDesc);
    }
    if (this.enforceFls) {
      // checkFLS(operation, sObjectDesc, records);
      // System.SObjectAccessDecision decision = System.Security.stripInaccessible(AccessType.UPDATABLE, records);
      // checkRemovedFields(operation, sObjectDesc, decision);
      // records = decision.getRecords();
    }
    update records;
  }

  public void onUpsert(List<SObject> records, Schema.SObjectField externalId) {
    if (records == null || records.isEmpty()) {
      return;
    }
    DatabaseOperation operation = DatabaseOperation.UPSERTX;
    Schema.DescribeSObjectResult sObjectDesc = records[0].getSObjectType().getDescribe();
    if (!sObjectDesc.isCreateable() || !sObjectDesc.isUpdateable()) {
      throw new CrudException(operation, sObjectDesc);
    }
    if (this.enforceFls) {
      // checkFLS(operation, sObjectDesc, records);
      // System.SObjectAccessDecision decision = System.Security.stripInaccessible(AccessType.UPSERTABLE, records);
      // checkRemovedFields(operation, sObjectDesc, decision);
      // records = decision.getRecords();
    }
    if (externalId != null) {
      Database.upsert(records, externalId);
    } else {
      Database.upsert(records);
    }
  }

  public void onDelete(List<SObject> records) {
    if (records == null || records.isEmpty()) {
      return;
    }
    DatabaseOperation operation = DatabaseOperation.DELETEX;
    Schema.DescribeSObjectResult sObjectDesc = records[0].getSObjectType().getDescribe();
    if (!sObjectDesc.isDeletable()) {
      throw new CrudException(operation, sObjectDesc);
    }
    delete records;
  }

  //! StripInaccessable will remove fields that are not updateable (ie. Formula fields, System fields (createdDatetime, modifiedDatetime...))
  //!    and using a selector these fields would be queried, resulting in an FlsException on those fields, even tho the user has access to them
  private void checkRemovedFields(DatabaseOperation operation, Schema.DescribeSObjectResult sObjectDesc, System.SObjectAccessDecision decision) {
    Map<String, Set<String>> removedFields = decision.getRemovedFields();
    if (!removedFields.isEmpty()) {
      System.debug(removedFields);
      Map<String, Schema.SObjectField> fieldMap = SObjectUtil.getFieldMap(sObjectDesc);
      Set<String> fields = removedFields.get(sObjectDesc.getName());
      System.debug(fields);
      Schema.SObjectField field = fieldMap.get(new List<String>(fields)[0]);
      System.debug(field);
      System.debug(field.getDescribe());
      throw new FlsException(operation, sObjectDesc, field);
    }
  }

  private void checkFLS(DatabaseOperation operation, Schema.DescribeSObjectResult sObjectDesc, List<SObject> records) {
    Map<String, Schema.SObjectField> fieldMap = SObjectUtil.getFieldMap(sObjectDesc);
    for (SObject record : records) {
      Map<String, Object> popFields = record.getPopulatedFieldsAsMap();
      for (String fieldName : popFields.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult dfr = field.getDescribe();
        // technically this should already be done by the selector
        if (!dfr.isAccessible()) {
          throw new FlsException(operation, sObjectDesc, field);
        }
        if (!dfr.isAutoNumber() && !dfr.isCalculated() && !dfr.isCascadeDelete()
          //! hold on... these should be adjusted...
          && (dfr.isCustom() || dfr.getName() == 'Id' || dfr.isNameField())) {
          switch on operation {
            when INSERTX {
              if (!dfr.isAccessible()) {
                // hmm... just throw earlier to avoid unnecessary overhead
              }
            }
            when UPDATEX {
              if (!dfr.isUpdateable()) {
                throw new FlsException(operation, sObjectDesc, field);
              }
            }
            when UPSERTX {
              if (!dfr.isCreateable() || !dfr.isUpdateable()) {
                throw new FlsException(operation, sObjectDesc, field);
              }
            }
          }
        }
      }
    }
  }

}