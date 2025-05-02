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

  DATA ls_customerinfo TYPE zst_customer_info_fjcm.

  ls_customerinfo = VALUE #( customer_id =  '01'
                             customer_adress = 'Chelsmokiego 8'
                             customer_name = 'José'
                             customer_phone = '123981239' ).

out->write( ls_customerinfo ).


  ENDMETHOD.
ENDCLASS.
