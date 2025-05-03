CLASS zcl_pruebas_project_fjcm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_pruebas_project_fjcm IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " Pruebas con estructuras
*   DATA ls_customerinfo TYPE zst_customer_info_fjcm.
*   ls_customerinfo = VALUE #( customer_id =  '01'
*                              customer_adress = 'Chelsmokiego 8'
*                              customer_name = 'José'
*                              customer_phone = '123981239' ).
*   out->write( ls_customerinfo ).

    " Prueba de estructura anidada

    DATA(ls_work_order_info) = VALUE zst_work_order_info_fjcm(    work_order_id       = '1231231'
                                                                  modification_date   = '20250712'
                                                                  change_description  = 'Ensamblar placas electronicas'
                                                                  customer_id         = '12345678'
                                                                  technician_id       = 'TECH0001'
                                                                  description         = 'Ensamblar RAM'
                                                                  priority            = 'A'
                                                                  status              = 'PE'
                                                                  creation_date       = '20250711' ).

*    out->write( ls_work_order_info ).
    out->write( '' ).

    DATA(ls_work_order_hist) = VALUE zst_work_order_hist_fjcm(
                                  history_id     = '123123'
                                  work_order_id  = '1231231' ).

*    out->write( ls_work_order_hist ).

"Agregando registros  las base de datos ztcustomer_fjcm y zttechnician_fjc
    DATA: lt_customer      TYPE STANDARD TABLE OF ztcustomer_fjcm,
          lt_technician    TYPE STANDARD TABLE OF zttechnician_fjc.

*    lt_customer = VALUE #(
*        ( customer_id = '4123153'  address = 'Chelmoskiego 8A'     client = 100   name = 'Jose'       phone = '966836001' )
*        ( customer_id = '4123154'  address = 'Pilsudskiego 4B'     client = 200   name = 'Anna'       phone = '966836002' )
*        ( customer_id = '4123155'  address = 'Stawna 12C'          client = 150   name = 'Katarzyna'  phone = '966836003' )
*        ( customer_id = '4123156'  address = 'Krakowska 15D'       client = 110   name = 'Marek'      phone = '966836004' )
*        ( customer_id = '4123157'  address = 'Piastowska 8E'       client = 130   name = 'Lukasz'     phone = '966836005' )
*        ( customer_id = '4123158'  address = 'Wrocławska 22F'      client = 120   name = 'Ewa'        phone = '966836006' )
*        ( customer_id = '4123159'  address = 'Warszawska 31G'      client = 140   name = 'Piotr'      phone = '966836007' )
*        ( customer_id = '4123160'  address = 'Legionów 45H'        client = 180   name = 'Agnieszka'  phone = '966836008' )
*        ( customer_id = '4123161'  address = 'Gorzysława 19I'      client = 160   name = 'Tomasz'     phone = '966836009' )
*        ( customer_id = '4123162'  address = 'Sienkiewicza 50J'    client = 170   name = 'Zofia'      phone = '966836010' ) ).
*
*
*
*    lt_technician = VALUE #(
*     ( client = 100   name = 'Mariusz'   specialty = 'Assembly'     technician_id = '12312942' )
*     ( client = 200   name = 'Jan'       specialty = 'Welding'      technician_id = '12312943' )
*     ( client = 150   name = 'Anna'      specialty = 'Maintenance'  technician_id = '12312944' )
*     ( client = 110   name = 'Marek'     specialty = 'Electrical'   technician_id = '12312945' )
*     ( client = 130   name = 'Lukasz'    specialty = 'Fabrication'  technician_id = '12312946' )
*     ( client = 120   name = 'Ewa'       specialty = 'Automation'   technician_id = '12312947' )
*     ( client = 140   name = 'Piotr'     specialty = 'Repair'       technician_id = '12312948' )
*     ( client = 180   name = 'Agnieszka' specialty = 'Inspection'   technician_id = '12312949' )
*     ( client = 160   name = 'Tomasz'    specialty = 'Calibration'  technician_id = '12312950' )
*     ( client = 170   name = 'Zofia'     specialty = 'Installation' technician_id = '12312951' ) ).
*
*
*    TRY.
*    MODIFY ztcustomer_fjcm FROM TABLE @lt_customer.
*    SELECT * FROM ztcustomer_fjcm INTO TABLE @DATA(lt_results).
*
*    IF lt_results IS NOT INITIAL.
*      out->write( 'Inserción correcta' ).
*      out->write( lt_results ).
*    ELSE.
*      out->write( 'No se insertaron datos' ).
*    ENDIF.
*
*  CATCH cx_root INTO DATA(lx_root).
*    out->write( |Error: { lx_root->get_text( ) }| ).
*ENDTRY.
*
*
*    TRY.
*    MODIFY zttechnician_fjc FROM TABLE @lt_technician.
*    SELECT * FROM zttechnician_fjc INTO TABLE @DATA(lt_results2).
*
*    IF lt_results IS NOT INITIAL.
*      out->write( 'Inserción correcta' ).
*      out->write( lt_results ).
*    ELSE.
*      out->write( 'No se insertaron datos' ).
*    ENDIF.
*
*  CATCH cx_root INTO DATA(lx_root2).
*    out->write( |Error: { lx_root->get_text( ) }| ).
*ENDTRY.



*DELETE FROM ztcustomer_fjcm
*  WHERE customer_id = '12345678'.
*
*
*DELETE FROM zttechnician_fjc
*  WHERE technician_id = 'TECH0001'.










  ENDMETHOD.

ENDCLASS.


