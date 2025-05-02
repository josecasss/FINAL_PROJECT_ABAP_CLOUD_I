CLASS zcl_test_project_fjcm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_test_project_fjcm IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  "Probando estructuras (:

*  DATA ls_customerinfo TYPE zst_customer_info_fjcm.
*
*  ls_customerinfo = VALUE #( customer_id =  '01'
*                             customer_adress = 'Chelsmokiego 8'
*                             customer_name = 'José'
*                             customer_phone = '123981239' ).
*
*  out->write( ls_customerinfo ).



  "Mas pruebas estructura anidadas

  DATA(ls_work_order_info) = VALUE zst_work_order_info_fjcm( work_order_id = '1231231'
                                     modification_date = '20250712'
                                     change_description = 'Ensamblar placas electronicas'
                                     customer_id = '02'
                                     technician_id = '9123'
                                     description = 'Ensamblar RAM'
                                     priority = 'A'
                                     status = 'PE'
                                     creation_date = '20250711' ).


   out->write( ls_work_order_info ).
   out->write( '' ).

  DATA(ls_work_order_hist) = VALUE zst_work_order_hist_fjcm( history_id = '123123'
                                                             work_order_id = '14153432' ).


    out->write( ls_work_order_hist ).










  ENDMETHOD.
ENDCLASS.
