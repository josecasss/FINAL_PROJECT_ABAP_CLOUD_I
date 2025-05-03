CLASS zcl_work_order_crud_test_fjcm DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    DATA:
      mo_crud_handler TYPE REF TO zcl_wk_order_crud_handler_fjcm,
      mv_test_customer_id TYPE zde_customer_id_fjcm,
      mv_test_technician_id TYPE zde_technician_id_fjcm,
      mv_test_work_order_id TYPE zde_work_order_id_fjcm.

    METHODS:
      initialize
        IMPORTING
          io_out TYPE REF TO if_oo_adt_classrun_out,

      setup_test_data
        IMPORTING
          io_out TYPE REF TO if_oo_adt_classrun_out,

      test_create_work_order
        IMPORTING
          io_out TYPE REF TO if_oo_adt_classrun_out,

      test_read_work_order
        IMPORTING
          io_out TYPE REF TO if_oo_adt_classrun_out,

      test_update_work_order
        IMPORTING
          io_out TYPE REF TO if_oo_adt_classrun_out,

      test_delete_work_order
        IMPORTING
          io_out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.

CLASS zcl_work_order_crud_test_fjcm IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Inicializar el manejador CRUD y los datos de prueba
    initialize( out ).

    " Configurar datos de prueba
    setup_test_data( out ).

    " Ejecutar casos de prueba
    test_create_work_order( out ).
    test_read_work_order( out ).
    test_update_work_order( out ).
    test_delete_work_order( out ).

    out->write( |*** Tests completed! ***| ).
  ENDMETHOD.

  METHOD initialize.
    " Crear una instancia del manejador CRUD
    mo_crud_handler = NEW zcl_wk_order_crud_handler_fjcm( ).
    io_out->write( |CRUD Handler initialized.| ).
  ENDMETHOD.

  METHOD setup_test_data.
    " Paso 1: Verificar si hay clientes en la base de datos
    SELECT SINGLE customer_id
      FROM ztcustomer_fjcm
      INTO @mv_test_customer_id.

    IF sy-subrc <> 0.
      " Si no hay clientes, crear uno de prueba
      DATA: ls_customer TYPE ztcustomer_fjcm.

      " Generar un ID de cliente único
      SELECT MAX( customer_id )
        FROM ztcustomer_fjcm
        INTO @DATA(lv_last_customer_id).

      IF sy-subrc <> 0 OR lv_last_customer_id IS INITIAL.
        ls_customer-customer_id = '00000001'.
      ELSE.
        DATA(lv_next_customer) = CONV i( lv_last_customer_id ) + 1.
        ls_customer-customer_id = |{ lv_next_customer }|.
      ENDIF.

      ls_customer-name = 'Test Customer'.
      ls_customer-address = 'Test Address 123'.
      ls_customer-phone = '555-1234'.

      INSERT ztcustomer_fjcm FROM @ls_customer.

      IF sy-subrc = 0.
        mv_test_customer_id = ls_customer-customer_id.
        io_out->write( |Created test customer with ID: { mv_test_customer_id }| ).
      ELSE.
        io_out->write( |Failed to create test customer!| ).
        RETURN.
      ENDIF.
    ELSE.
      io_out->write( |Using existing customer with ID: { mv_test_customer_id }| ).
    ENDIF.

    " Verificar si hay técnicos en la base de datos
    SELECT SINGLE technician_id
      FROM zttechnician_fjc
      INTO @mv_test_technician_id.

    IF sy-subrc <> 0.
      " Si no hay técnicos, crear uno de prueba PARA EL TEST
      DATA: ls_technician TYPE zttechnician_fjc.

      " Generar un ID de técnico único (alfanumérico)
      ls_technician-technician_id = 'TECH0001'.
      ls_technician-name = 'Test Technician'.
      ls_technician-specialty = 'General Repairs'.

      INSERT zttechnician_fjc FROM @ls_technician.

      IF sy-subrc = 0.
        mv_test_technician_id = ls_technician-technician_id.
        io_out->write( |Created test technician with ID: { mv_test_technician_id }| ).
      ELSE.
        io_out->write( |Failed to create test technician!| ).
        RETURN.
      ENDIF.
    ELSE.
      io_out->write( |Using existing technician with ID: { mv_test_technician_id }| ).
    ENDIF.

    io_out->write( |Test data setup completed.| ).
  ENDMETHOD.

  METHOD test_create_work_order.
    io_out->write( |----- Test: Create Work Order -----| ).

    " Crear una nueva orden de trabajo
    DATA: ls_work_order TYPE ztwork_order_fjc.

    ls_work_order-customer_id = mv_test_customer_id.
    ls_work_order-technician_id = mv_test_technician_id.
    ls_work_order-priority = 'A'. " Alta prioridad
    ls_work_order-description = 'Test work order created for testing purposes'.

    " Llamar al método de creación
    DATA(lo_result) = mo_crud_handler->create_work_order( ls_work_order ).

    " Verificar el resultado
    IF lo_result IS BOUND.
      mv_test_work_order_id = lo_result->work_order_id.
      io_out->write( |Work order created successfully with ID: { mv_test_work_order_id }| ).
      io_out->write( |Status: { lo_result->status }| ).
      io_out->write( |Creation Date: { lo_result->creation_date DATE = USER }| ).
    ELSE.
      io_out->write( |Failed to create work order! Please check validation rules.| ).
    ENDIF.
  ENDMETHOD.

  METHOD test_read_work_order.
    " Solo proceder si tenemos un ID de orden de trabajo válido
    IF mv_test_work_order_id IS INITIAL.
      io_out->write( |----- Test: Read Work Order - SKIPPED (No work order ID) -----| ).
      RETURN.
    ENDIF.

    io_out->write( |----- Test: Read Work Order -----| ).

    " Leer la orden de trabajo
    DATA(ls_work_order) = mo_crud_handler->read_work_order( mv_test_work_order_id ).

    " Verificar el resultado
    IF ls_work_order IS NOT INITIAL.
      io_out->write( |Work order read successfully:| ).
      io_out->write( |ID: { ls_work_order-work_order_id }| ).
      io_out->write( |Customer ID: { ls_work_order-customer_id }| ).
      io_out->write( |Technician ID: { ls_work_order-technician_id }| ).
      io_out->write( |Status: { ls_work_order-status }| ).
      io_out->write( |Priority: { ls_work_order-priority }| ).
      io_out->write( |Description: { ls_work_order-description }| ).
    ELSE.
      io_out->write( |Failed to read work order with ID: { mv_test_work_order_id }| ).
    ENDIF.
  ENDMETHOD.

  METHOD test_update_work_order.
    " Solo proceder si tenemos un ID de orden de trabajo válido
    IF mv_test_work_order_id IS INITIAL.
      io_out->write( |----- Test: Update Work Order - SKIPPED (No work order ID) -----| ).
      RETURN.
    ENDIF.

    io_out->write( |----- Test: Update Work Order -----| ).

    " Primero, leer la orden de trabajo existente
    DATA(ls_work_order) = mo_crud_handler->read_work_order( mv_test_work_order_id ).

    IF ls_work_order IS INITIAL.
      io_out->write( |Failed to read work order for update!| ).
      RETURN.
    ENDIF.

    " Modificar algunos campos
    ls_work_order-description = 'Updated description - test update operation'.
    ls_work_order-priority = 'B'. " Cambiar a prioridad baja

    " Llamar al método de actualización
    DATA(lv_update_success) = mo_crud_handler->update_work_order( ls_work_order ).

    " Verificar el resultado
    IF lv_update_success = abap_true.
      io_out->write( |Work order updated successfully.| ).

      " Leer nuevamente para verificar los cambios
      DATA(ls_updated_order) = mo_crud_handler->read_work_order( mv_test_work_order_id ).

      io_out->write( |Updated values:| ).
      io_out->write( |Description: { ls_updated_order-description }| ).
      io_out->write( |Priority: { ls_updated_order-priority }| ).
    ELSE.
      io_out->write( |Failed to update work order! Please check validation rules.| ).
    ENDIF.
  ENDMETHOD.

  METHOD test_delete_work_order.
    " Solo proceder si tenemos un ID de orden de trabajo válido
    IF mv_test_work_order_id IS INITIAL.
      io_out->write( |----- Test: Delete Work Order - SKIPPED (No work order ID) -----| ).
      RETURN.
    ENDIF.

    io_out->write( |----- Test: Delete Work Order -----| ).

    " Primero, verificar si la orden existe
    DATA(ls_work_order) = mo_crud_handler->read_work_order( mv_test_work_order_id ).

    IF ls_work_order IS INITIAL.
      io_out->write( |Work order not found for deletion!| ).
      RETURN.
    ENDIF.

    " Intentar eliminar la orden
    DATA(lv_delete_success) = mo_crud_handler->delete_work_order(
        iv_work_order_id = mv_test_work_order_id
        iv_status        = ls_work_order-status
    ).

    " Verificar el resultado
    IF lv_delete_success = abap_true.
      io_out->write( |Work order deleted successfully.| ).

      " Verificar que ya no existe
      DATA(ls_deleted_order) = mo_crud_handler->read_work_order( mv_test_work_order_id ).

      IF ls_deleted_order IS INITIAL.
        io_out->write( |Verification successful: Work order no longer exists.| ).
      ELSE.
        io_out->write( |Verification failed: Work order still exists!| ).
      ENDIF.
    ELSE.
      io_out->write( |Failed to delete work order! Please check validation rules.| ).
      io_out->write( |Note: Orders can only be deleted if they are in 'PE' status and have no history entries.| ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
