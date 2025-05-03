CLASS zcl_test_project_fjcm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_test_project_fjcm IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " Pruebas con estructuras
*   DATA ls_customerinfo TYPE zst_customer_info_fjcm.
*   ls_customerinfo = VALUE #( customer_id =  '01'
*                              customer_adress = 'Chelsmokiego 8'
*                              customer_name = 'José'
*                              customer_phone = '123981239' ).
*   out->write( ls_customerinfo ).

    " Prueba de estructura anidada
    DATA(ls_work_order_info) = VALUE zst_work_order_info_fjcm(
                                  work_order_id       = '1231231'
                                  modification_date   = '20250712'
                                  change_description  = 'Ensamblar placas electronicas'
                                  customer_id         = '12345678'
                                  technician_id       = 'TECH0001'
                                  description         = 'Ensamblar RAM'
                                  priority            = 'A'
                                  status              = 'PE'
                                  creation_date       = '20250711' ).

    out->write( ls_work_order_info ).
    out->write( '' ).

    DATA(ls_work_order_hist) = VALUE zst_work_order_hist_fjcm(
                                  history_id     = '123123'
                                  work_order_id  = '1231231' ).

    out->write( ls_work_order_hist ).

    DATA: lt_customer TYPE TABLE OF ztcustomer_fjcm,
      lt_technician TYPE TABLE OF zttechnician_fjc,
      lv_customer_id TYPE ztcustomer_fjcm-customer_id VALUE '12345678',
      lv_technician_id TYPE zttechnician_fjc-technician_id VALUE 'TECH0001'.

" Insertar en ZTCUSTOMER_FJCM
CLEAR lt_customer.
APPEND VALUE #( customer_id = lv_customer_id ) TO lt_customer.
INSERT ztcustomer_fjcm FROM TABLE @lt_customer.

" Insertar en ZTTECHNICIAN_FJC
CLEAR lt_technician.
APPEND VALUE #( technician_id = lv_technician_id ) TO lt_technician.
INSERT zttechnician_fjc FROM TABLE @lt_technician.

COMMIT WORK.



  ENDMETHOD.

ENDCLASS.


