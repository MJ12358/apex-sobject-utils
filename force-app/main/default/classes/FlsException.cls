/**
 * Created on Thu Mar 04 2021
 *
 * Copyright (c) 2021 MJ12358
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

public class FlsException extends DatabaseException {

  public FlsException(DatabaseOperation operation, SObject sObj, Schema.SObjectField field) {
    this(operation, sObj.getSObjectType(), field);
  }

  public FlsException(DatabaseOperation operation, SObject sObj, Schema.DescribeFieldResult fieldDesc) {
    this(operation, sObj.getSObjectType(), fieldDesc);
  }

  public FlsException(DatabaseOperation operation, Schema.SObjectType sObjectType, Schema.SObjectField field) {
    this(operation, sObjectType.getDescribe(), field.getDescribe());
  }

  public FlsException(DatabaseOperation operation, Schema.SObjectType sObjectType, Schema.DescribeFieldResult fieldDesc) {
    this(operation, sObjectType.getDescribe(), fieldDesc);
  }

  public FlsException(DatabaseOperation operation, Schema.DescribeSObjectResult sObjectDesc, Schema.SObjectField field) {
    this(operation, sObjectDesc, field.getDescribe());
  }

  public FlsException(DatabaseOperation operation, Schema.DescribeSObjectResult sObjectDesc, Schema.DescribeFieldResult fieldDesc) {
    String message = String.format(System.Label.SObjectFlsException,
      new List<String>{
        operation.name(),
        fieldDesc.getName(),
        sObjectDesc.getName()
      }
    );
    this.setMessage(message);
  }

}
