// extend jquery selector contains function to case insensitive
$.extend($.expr[':'], {
  'containsi': function(elem, i, match, array)
  {
    return (elem.textContent || elem.innerText || '').toLowerCase()
    .indexOf((match[3] || "").toLowerCase()) >= 0;
  }
});

function toggleModalErrorText(className) {
  $('#popup-error-setting-form .error-payment').hide();
  var popup_classname = '#popup-error-setting-form ' + className;
  $(popup_classname).show();
  $('#popup-error-setting-form').modal('show');
}

function disableSubmitFormBtn(value) {
  $('#setting-form-submit').attr('disabled',value);
  if(value) {
    $('#setting-form-submit .save').hide();
    $('#setting-form-submit .process').show();
  }else {
    $('#setting-form-submit .save').show();
    $('#setting-form-submit .process').hide();
  }
}

function getPaymentTypeId(type) {
  var typeSelector = '#payment-method-type-select-wrapper select option:containsi("'+ type +'")';
  var $thisType = $(typeSelector).first();
  if($thisType.text().toLowerCase() === type.toLowerCase()){
    return $thisType.val();
  }else{
    return false;
  }
}

function checkForPaymentType(mode, idData, override) {
  var disablePaymentType;

  // mode = 2 for submit in new mode
  if (mode == 2) {
    var checkTypeArr = payment_method.filter(function(arr){
      return arr.payment_type_name.match(/cash/i) || arr.payment_type_name.match(/tunai/i)
    });
    disablePaymentType = checkTypeArr < 1;
  }

  // mode = 3 for submit in edit mode
  if (mode == 3) {
    checkArrEdit = edit_payment_method.filter(function(arr){
      return arr.payment_type_name.match(/cash/i) || arr.payment_type_name.match(/tunai/i)
    });
    checkArrNew = payment_method.filter(function(arr){
      return arr.payment_type_name.match(/cash/i) || arr.payment_type_name.match(/tunai/i)
    });
    disablePaymentType = checkArrEdit.length < 1 && checkArrNew.length < 1;
  }

  if( override != undefined ) disablePaymentType = override;

  return !disablePaymentType;
}

function checkForPaymentTypeDouble(type_id, temp_id, id, temp_id_count) {
  try {
    check_payment_type_id_double = payment_method.findIndex(function(arr){
      return arr.payment_type_id == type_id && arr.temp_id != temp_id;
    });

    check_edit_payment_type_id_double = edit_payment_method.findIndex(function(arr){
      return arr.payment_type_id == type_id && arr.id != id;
    });

    // kalau ada yang double, cancel create new, count temp_id ny dikurang 1
    if(check_payment_type_id_double != -1 || check_edit_payment_type_id_double != -1) {
      if(temp_id_count != undefined) temp_id_count--;
      return true;
    }
  }catch(err) {
    check_payment_type_id_double = payment_method.findIndex(function(arr){
      return arr.payment_type_id == type_id && arr.temp_id != temp_id;
    });

    if(check_payment_type_id_double != -1) {
      if(temp_id_count != undefined) temp_id_count--;
      return true;
    }
  }
}

function initDevicesTableIndex() {
  $('#table-see-devices tbody tr').each(function(index){
    $(this).find('.index').text(index+1);
  });
}

function resetFormPaymentMethod() {
  $('#payment-method-type-select-wrapper select').val($('#payment-method-type-select-wrapper select option:first-child').val()).trigger('change');
  $('#payment-method-account-select-wrapper select').val($('#payment-method-account-select-wrapper select option:first-child').val()).trigger('change');
  $('#payment-method-fee-account-select-wrapper select').val($('#payment-method-fee-account-select-wrapper select option:first-child').val()).trigger('change');
  $('#payment_method_id').val('');
  $('#payment_method_temp_id').val('');
  $('#payment-method-form').trigger('reset');
}

function addNewRow(data) {
  var payment_method_name = data.payment_type_name;
  var payment_method_id = data.temp_id;
  var newRow = '<tr>\
                <td class="payment-method-name col-xs-10 padding-cell">' + payment_method_name + '</td>\
                <td class="edit-payment-method col-xs-1 link link-blue" data-id="'+ payment_method_id +'">'+ edit_text + '</td>\
                <td class="delete-payment-method col-xs-1 link link-red" data-id="'+ payment_method_id +'">'+ delete_text + ' </td>\
                </tr>';
  $('#table-payment-method tbody').append(newRow);
}

function updateRow(data, id) {
  var this_id = '[data-id="' + id + '"]';
  var $row = $(this_id).parent('tr');
  $row.find('.payment-method-name').text(data.payment_type_name);
}

function injectFormModal(data) {
  $('#payment_method_payment_type_id').val(data.payment_type_id).trigger('change');
  $('#payment_method_payment_account_id').val(data.payment_account_id).trigger('change');
  $('#payment_method_payment_fee_percentage').val(data.payment_fee_percentage);
  $('#payment_method_payment_fee_fixed').val(data.payment_fee_fixed);
  $('#payment_method_payment_fee_account_id').val(data.payment_fee_account_id).trigger('change');

  $('#payment_method_temp_id').val(data.temp_id);
  if (data.id != undefined) $('#payment_method_id').val(data.id);

  $('#popup-add-pay-method').modal('show');
}

function sanitizeArray(temp_arr, mode) {
  var arr_length = temp_arr.length;
  if(arr_length < 1) {
    return 0;
  }
  if(mode == true){
    temp_arr.filter(function(arr){
      if(arr.flag == 'edit') {
        delete arr.flag;
        delete arr.temp_id;
      }
      return temp_arr;
    });
  }else{
    temp_arr.filter(function(arr){
      delete arr.temp_id;
      return temp_arr;
    });
  }
  return temp_arr;
}

$(document).on('turbolinks:load', function(){
  payment_method = [];
  delete_payment_method = [];
  type_payment_method = 0;
  temp_id_count = 1;

  initDevicesTableIndex();
  $('#setting-form-submit .save').show();
  $('#setting-form-submit .process').hide();

  // prevent user input value exceed max attribute
  try {
    $('.force-max-min-attr')[0].oninput = function () {
      var max = parseInt(this.max);
      var min = parseInt(this.min);
      if (parseInt(this.value) > max) {
        this.value = max; 
      }
      if (parseInt(this.value) < min) {
        this.value = min;
      }
    }
  }catch(err) {}

  $('#reset-form').on('click',function(){
    resetFormPaymentMethod();
  });

  $('#popup-add-pay-method').on('hide.bs.modal', function(){
    resetFormPaymentMethod();
  });

  $(document).on('click', '.delete-payment-method', function(e){
    var $this = $(this);
    var id = $this.data('id');
    var $this_info = $this.siblings('.info-cell');

    if($this_info.length <= 0) {
      // new mode
      var index = payment_method.findIndex(function(arr){return arr.temp_id == parseInt(id)});
      payment_method.splice(payment_method[index],1);
    }else {
      // edit mode
      var index = edit_payment_method.findIndex(function(arr){return arr.id == parseInt(id)});
      if (checkForPaymentType(1, id)) {
        edit_payment_method.splice(index,1);
        delete_payment_method.push(id);
      }else {
        toggleModalErrorText('.type-cash');
        return false;
      }
    }

    $(this).parent('tr').remove();
  });

  $('#popup-see-devices .delete-devices').on('click', function(e){
    e.preventDefault();
    var id = $(this).parents('tr').data('id');
    var newUrl = $('#popup-delete-confirm').attr('href').split("=").shift() + "=" + id; 
    $('#popup-delete-confirm').attr('href',newUrl);
    $('#popup-delete-devices').modal('show');
  });

  $('#popup-delete-confirm').on('ajax:success', function(e, jqXHR, ajaxOptions, data) {
    var deleted_row = "tr[data-id=" + data.responseJSON.device_id + "]";
    $(deleted_row,'#table-see-devices').remove();
    initDevicesTableIndex();
    $('#popup-delete-devices').modal('hide');
  }); 

  $('#popup-delete-confirm').on('ajax:error', function(data) {
    alert('Delete device failed');
    location.reload();
  });     

  $('#add-payment-method').click(function(){
    $('#add-pay-method-title').show();
    $('#edit-pay-method-title').hide();
    $('#popup-add-pay-method').modal('show');
  });

  $(document).on('click', '.edit-payment-method', function(e){
    $('#add-pay-method-title').hide();
    $('#edit-pay-method-title').show();

    var $this = $(this);
    var $this_info = $this.siblings('.info-cell');
    var this_id = parseInt($this.data('id'));
    var data, index;

    if($this_info.length > 0) {
      index = edit_payment_method.findIndex(function(arr){return arr.id == parseInt(this_id)});
      data = edit_payment_method[index];
    }else {
      index = payment_method.findIndex(function(arr){return arr.temp_id == parseInt(this_id)});
      data = payment_method[index];
    }
    injectFormModal(data);
  });

  $('#payment-method-form').submit(function(e){
    e.preventDefault();
    e.stopPropagation();
    $('#payment_method_payment_type_name').val($('#payment-method-type-select-wrapper select option:selected').text());

    form_data = $('#payment-method-form').serializeObject();
    var form_data_payment_method = form_data.payment_method;
    var temp_id = form_data_payment_method.temp_id;
    var id = form_data_payment_method.id;
    var type_id = form_data_payment_method.payment_type_id;

    if ( temp_id != '' && id == '') {
      // update temporary data
      var index = payment_method.findIndex(function(arr){return arr.temp_id == temp_id});

      if(checkForPaymentTypeDouble(type_id, temp_id, id)) {
        toggleModalErrorText('.type-double');
        return false;
      }

      payment_method.splice(index,1,form_data_payment_method);
      data = payment_method[index];
      updateRow(data, data.temp_id);
    }else if ( temp_id == '' && id != '' ) {
      // update existing data
      form_data_payment_method.flag = 'edit';
      var index = edit_payment_method.findIndex(function(arr){return parseInt(arr.id) == id});

      if(checkForPaymentTypeDouble(type_id, temp_id, id)) {
        toggleModalErrorText('.type-double');
        return false;
      }

      edit_payment_method.splice(index,1,form_data_payment_method);
      data = edit_payment_method[index];
      updateRow(data, data.id);
    }
    else {
      // add new data
      data = form_data_payment_method;
      temp_id_count++;
      data.temp_id = temp_id_count;

      if(checkForPaymentTypeDouble(type_id, temp_id, id, temp_id_count)) {
        toggleModalErrorText('.type-double');
        return false;
      }

      payment_method.push(data);
      addNewRow(data);
    }

    $('#popup-add-pay-method').modal('hide');
    resetFormPaymentMethod();
    return false;
  });

  $(document).keypress(function(e) {
    if(e.keyCode == 13){
      $('#setting-form-submit').click();
    }
  });

  $('#edit-setting #setting-form-submit').click(function(){
    disableSubmitFormBtn(true);
    if( !checkForPaymentType(3) ) {
      toggleModalErrorText('.type-cash');
      disableSubmitFormBtn(false);
      return false;
    };
    if( $("#setting-form")[0].checkValidity() ){
      var params = sanitizeArray(payment_method);
      var edit_params = sanitizeArray(edit_payment_method, true);
      toggleSpinner(false);
      if(params != 0) {
        $.ajax({
          type: 'POST',
          url: payment_method_url.substring(0, payment_method_url.lastIndexOf("/") + 1),
          data: {'payment_method' : JSON.stringify(params)},
          dataType: 'json',
          success: function(data){
            // console.log(data);
          },
          error: function(xhr, textStatus, error){
            // console.log(xhr);
          }
        });
      }

      if(edit_params != 0) {
        $.ajax({
          type: 'PATCH',
          url: edit_payment_method_url,
          data: {'payment_method' : JSON.stringify(edit_params)},
          dataType: 'json',
          success: function(data){
            // console.log(data);
          },
          error: function(xhr, textStatus, error){
            // console.log(xhr);
          }
        });
      }

      if(delete_payment_method.length > 0) {
        $.ajax({
          type: 'DELETE',
          url: payment_method_url,
          data: {'delete_ids' : delete_payment_method},
          dataType: 'json',
          success: function(data){
            // console.log(data);
          },
          error: function(xhr, textStatus, error){
            // console.log(xhr);
          }
        });
      }

      $('#setting-form').submit();
    }else{
      $('#setting-form :submit').click();
      toggleSpinner(true);
      disableSubmitFormBtn(false);
    }
  });

  $('#new-setting #setting-form-submit').click(function(){
    disableSubmitFormBtn(true);
    if( !checkForPaymentType(2) ) {
      toggleModalErrorText('.type-cash');
      disableSubmitFormBtn(false);
      return false;
    };
    if( $("#setting-form")[0].checkValidity() ){
      var setting_params = $('#setting-form').serializeObject();
      var payment_method_params = sanitizeArray(payment_method);
      setting_params.setting.payment_method = payment_method;
      toggleSpinner(false);
      if(payment_method_params != 0) {
        $.ajax({
          type: 'POST',
          url: setting_url,
          data: {'setting': JSON.stringify(setting_params)},
          dataType: 'json',
          success: function(data){
            window.location.href = data.redirect_url;
          },
          error: function(xhr, textStatus, error){
            // console.log(xhr);
          }
        });
      }
    }else{
      $('#setting-form :submit').click();
      toggleSpinner(true);
      disableSubmitFormBtn(false);
    }
  });
});