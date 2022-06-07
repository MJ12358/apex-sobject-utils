/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Created on Mon Aug 19 2019
 *
 * Copyright (c) 2019 Matt Jants
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

public abstract inherited sharing class SObjectSelector {
  
  private Integer recordLimit;
  protected Boolean enforceCrud;
  protected Boolean enforceFls;
  
  public SObjectSelector() {
    this(true, true);
  }

  public SObjectSelector(Boolean enforceCrud) {
    this(enforceCrud, enforceCrud);
  }

  public SObjectSelector(Boolean enforceCrud, Boolean enforceFls) {
    this.enforceCrud = enforceCrud;
    this.enforceFls = enforceFls;
  }

  abstract Schema.SObjectType getSObjectType();
  
  public virtual List<Schema.SObjectField> getSObjectFieldList() {
    return getSObjectType().getDescribe().fields.getMap().values();
  }

  public StringBuilder.FieldListBuilder getFieldListBuilder() {
    return new StringBuilder.FieldListBuilder(getSObjectFieldList(), this.enforceFls);
  }

  public String getFieldListString() {
    return getFieldListBuilder().toString();
  }
  
  public String getRelatedFieldListString(String relation) {
    return getFieldListBuilder().toString(relation + '.');
  }

  public String getFieldSetString(Schema.FieldSet fieldSet) {
    if (fieldSet == null) {
      throw new SObjectSelectorException(System.Label.SObjectSelectorFieldSetNull);
    }
    if (fieldSet.getSObjectType() != getSObjectType()) {
      String message = String.format(System.Label.SObjectSelectorFieldSetInvalid,
        new List<String>{
          fieldSet.getName(),
          getSObjectName()
        }
      );
      throw new SObjectSelectorException(message);
    }
    return new StringBuilder.FieldListBuilder(fieldSet, this.enforceFls).toString();
  }
  
  public String getSObjectName() {
    assertIsAccessible();
    return getSObjectType().getDescribe().getName();
  }

  public virtual String getIsActive() {
    return 'IsDeleted = false';
  }
  
  public virtual String getOrderBy() {
    return 'CreatedDate DESC';
  }

  public virtual String getLimit() {
    if (this.recordLimit == null) {
      // visualforce can only retrieve 10K records (in a NON read-only mode)
      if (ApexPages.currentPage() != null) {
        this.recordLimit = 10000;
      } else {
        this.recordLimit = System.Limits.getLimitQueryRows() - System.Limits.getQueryRows();
      }
    }
    return String.valueOf(this.recordLimit);
  }

  public void setLimit(Integer limitx) {
    // you can get up to 50K records in a single query
    if (limitx == null || limitx < 0 || limitx > 50000) {
      throw new SObjectSelectorException(System.Label.SObjectSelectorLimitInvalid);
    }
    this.recordLimit = limitx;
  }

  public Integer selectCount(String fieldName, Id recordId) {
    String query = String.format('SELECT Count() FROM {0} WHERE {1} = :recordId',
      new List<String>{
        getSObjectName(),
        fieldName
      }
    );
    return Database.countQuery(query);
  }

  public Integer selectCount() {
    String query = String.format('SELECT Count() FROM {0}',
      new List<String>{
        getSObjectName()
      }
    );
    return Database.countQuery(query);
  }

  public Integer selectCountByIsActive() {
    String query = String.format('SELECT Count() FROM {0} WHERE {1}',
      new List<String>{
        getSObjectName(),
        getIsActive()
      }
    );
    return Database.countQuery(query);
  }

  public List<SObject> selectAll() {
    String query = String.format('SELECT {0} FROM {1} ORDER BY {2} LIMIT {3}',
      new List<String>{
        getFieldListString(),
        getSObjectName(),
        getOrderBy(),
        getLimit()
      }
    );
    return Database.query(query);
  }

  public List<SObject> selectByIsActive() {
    String query = String.format('SELECT {0} FROM {1} WHERE {2} ORDER BY {3} LIMIT {4}',
      new List<String>{
        getFieldListString(),
        getSObjectName(),
        getIsActive(),
        getOrderBy(),
        getLimit()
      }
    );
    return Database.query(query);
  }

  public SObject selectById(Id recordId) {
    return selectById(new Set<Id>{ recordId })[0];
  }

  public List<SObject> selectById(Set<Id> idSet) {
    String query = String.format('SELECT {0} FROM {1} WHERE Id IN :idSet ORDER BY {2} LIMIT {3}',
      new List<String>{
        getFieldListString(),
        getSObjectName(),
        getOrderBy(),
        getLimit()
      }
    );
    return Database.query(query);
  }

  public void assertIsAccessible() {
    if (this.enforceCrud && !getSObjectType().getDescribe().isAccessible()) {
      throw new CrudException(DatabaseOperation.READ, getSObjectType());
    }
  }

  //* Generic sObject selector

  public class Generic extends SObjectSelector {

    public Schema.SObjectType sObjectType;

    public override Schema.SObjectType getSObjectType() {
      return this.sObjectType;
    }
  
    public Generic(Schema.SObjectType sObjectType) {
      this(sObjectType, true);
    }
  
    public Generic(Schema.SObjectType sObjectType, Boolean enforceCrud) {
      this(sObjectType, enforceCrud, enforceCrud);
    }
  
    public Generic(Schema.SObjectType sObjectType, Boolean enforceCrud, Boolean enforceFls) {
      super(enforceCrud, enforceFls);
      this.sObjectType = sObjectType;
    }
  }

}