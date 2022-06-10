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

public inherited sharing class IconUtil {

/**
 *  Get the sObject lightning icon
 *  @param String The sObject name
 *  @return String The icon name formatted for slds
 */
  public static String getLightningIcon(String sObjectName) {
    if (String.isBlank(sObjectName)) {
      return 'standard:default';
    }
    String result = '';
    switch on sObjectName.toLowerCase() {
      when 'contractlineitem' {
        result = 'contract_line_item';
      }
      when 'order' {
        result = 'orders';
      }
      when 'orderitem' {
        result = 'order_item';
      }
      when 'pricebook2' {
        result = 'pricebook';
      }
      when 'productconsumed' {
        result = 'product_consumed';
      }
      when 'productitemtransaction' {
        result = 'product_item_transaction';
      }
      when 'productitem' {
        result = 'product_item';
      }
      when 'productrequestlineitem' {
        result = 'product_request_line_item';
      }
      when 'productrequest' {
        result = 'product_request';
      }
      when 'productrequired' {
        result = 'product_required';
      }
      when 'producttransfer' {
        result = 'product_transfer';
      }
      when 'product2' {
        result = 'product';
      }
      when 'quote' {
        result = 'quotes';
      }
      when 'resourceabsence' {
        result = 'resource_absence';
      }
      when 'resourcecapacity' {
        result = 'resource_capacity';
      }
      when 'resourcepreference' {
        result = 'resource_preference';
      }
      when 'returnorderlineitem' {
        result = 'return_order_line_item';
      }
      when 'returnorder' {
        result = 'return_order';
      }
      when 'serviceappointment' {
        result = 'service_appointment';
      }
      when 'servicecontract' {
        result = 'service_contract';
      }
      when 'servicecrewmember' {
        result = 'service_crew_member';
      }
      when 'servicecrew' {
        result = 'service_crew';
      }
      when 'servicereport' {
        result = 'service_report';
      }
      when 'serviceresource' {
        result = 'service_resource';
      }
      when 'serviceterritorylocation' {
        result = 'service_territory_location';
      }
      when 'serviceterritorymember' {
        result = 'service_territory_member';
      }
      when 'serviceterritory' {
        result = 'service_territory';
      }
      when 'skill' {
        result = 'resource_skill';
      }
      when 'timesheetentry' {
        result = 'timesheet_entry';
      }
      when 'workcapacitylimit' {
        result = 'work_capacity_limit';
      }
      when 'workcapacityusage' {
        result = 'work_capacity_usage';
      }
      when 'workorderlineitem' {
        result = 'work_order_item';
      }
      when 'workorder' {
        result = 'work_order';
      }
      when 'workqueue' {
        result = 'work_queue';
      }
      when 'worktypegroup' {
        result = 'work_type_group';
      }
      when 'worktype' {
        result = 'work_type';
      }
      when else {
        result = sObjectName.toLowerCase();
      }
    }
    return 'standard:' + result;
  }

/**
 *  Get the sObject lightning icon
 *  @param Schema.SObjectType The sObject type
 *  @return String
 */
  public static String getLightningIcon(Schema.SObjectType sObjectType) {
    return getLightningIcon(sObjectType?.getDescribe().getName());
  }

/**
 *  Get the sObject lightning icon
 *  @param SObject The sObject
 *  @return String
 */
  public static String getLightningIcon(SObject sObj) {
    return getLightningIcon(sObj?.getSObjectType());
  }
}
