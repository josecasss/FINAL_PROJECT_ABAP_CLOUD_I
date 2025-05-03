CLASS zcl_work_order_validator_fjcm DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    METHODS:
      validate_create_order
        IMPORTING
          iv_customer_id  TYPE zde_customer_id_fjcm
          iv_technician_id TYPE zde_technician_id_fjcm
          iv_priority      TYPE zde_priority_fjcm
        RETURNING
          VALUE(rv_valid)  TYPE abap_bool,

      validate_update_order
        IMPORTING
          iv_work_order_id TYPE zde_work_order_id_fjcm
          iv_status        TYPE zde_status_fjcm
        RETURNING
          VALUE(rv_valid)  TYPE abap_bool,

      validate_delete_order
        IMPORTING
          iv_work_order_id TYPE zde_work_order_id_fjcm
          iv_status        TYPE zde_status_fjcm
        RETURNING
          VALUE(rv_valid)  TYPE abap_bool,

      validate_status_and_priority
        IMPORTING
          iv_status   TYPE zde_status_fjcm
          iv_priority TYPE zde_priority_fjcm
        RETURNING
          VALUE(rv_valid) TYPE abap_bool.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_valid_status,
        pe TYPE zde_status_fjcm VALUE 'PE', " Pending
        co TYPE zde_status_fjcm VALUE 'CO', " Completed
      END OF c_valid_status,
      BEGIN OF c_valid_priority,
        a TYPE zde_priority_fjcm VALUE 'A', " High
        b TYPE zde_priority_fjcm VALUE 'B', " Low
      END OF c_valid_priority.

    METHODS:
      check_customer_exists
        IMPORTING
          iv_customer_id TYPE zde_customer_id_fjcm
        RETURNING
          VALUE(rv_exists) TYPE abap_bool,

      check_technician_exists
        IMPORTING
          iv_technician_id TYPE zde_technician_id_fjcm
        RETURNING
          VALUE(rv_exists) TYPE abap_bool,

      check_order_exists
        IMPORTING
          iv_work_order_id TYPE zde_work_order_id_fjcm
        RETURNING
          VALUE(rv_exists) TYPE abap_bool,

      check_order_history
        IMPORTING
          iv_work_order_id TYPE zde_work_order_id_fjcm
        RETURNING
          VALUE(rv_exists) TYPE abap_bool.

ENDCLASS.

CLASS zcl_work_order_validator_fjcm IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( 'This is a test message from zcl_work_order_validator_fjcm!' ).
    DATA(lo_validator) = NEW zcl_work_order_validator_fjcm( ).

    " Declaración de variables locales
    DATA: lv_customer_id  TYPE zde_customer_id_fjcm,
          lv_technician_id TYPE zde_technician_id_fjcm,
          lv_priority      TYPE zde_priority_fjcm.

    " *** Obtener un Customer ID de la tabla ZT_CUSTOMER_FJCM ***
    SELECT SINGLE customer_id
      FROM ztcustomer_fjcm
      INTO @lv_customer_id.
    IF sy-subrc <> 0.
      out->write( |No customers were found in table ZT_CUSTOMER_FJCM.| ).
      RETURN.
    ENDIF.

    " *** Obtener un Technician ID de la tabla ZT_TECHNICIAN_FJCM ***
    SELECT SINGLE technician_id
      FROM zttechnician_fjc
      INTO @lv_technician_id.
    IF sy-subrc <> 0.
      out->write( |No customers were found in table ZT_TECHNICIAN_FJCM.| ).
      RETURN.
    ENDIF.

    " Asignar un valor de prioridad (puedes hacerlo aleatorio o fijo para la prueba)
    lv_priority = c_valid_priority-a.

    DATA(lv_is_valid) = lo_validator->validate_create_order(
        iv_customer_id  = lv_customer_id
        iv_technician_id = lv_technician_id
        iv_priority      = lv_priority
    ).

    IF lv_is_valid = abap_true.
      out->write( |Is order creation valid? TRUE (con datos de la base de datos)| ).
    ELSE.
      out->write( |Is order creation valid? FALSE (con datos de la base de datos)| ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_create_order.
    " Verificar si el cliente existe
    DATA(lv_customer_exists) = check_customer_exists( iv_customer_id ).
    IF lv_customer_exists IS INITIAL.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    " Verificar si el técnico existe
    DATA(lv_technician_exists) = check_technician_exists( iv_technician_id ).
    IF lv_technician_exists IS INITIAL.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    " Verificar si la prioridad es válida
    IF iv_priority <> c_valid_priority-a AND iv_priority <> c_valid_priority-b.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

  METHOD validate_update_order.
    " Verificar si la orden de trabajo existe
    DATA(lv_order_exists) = check_order_exists( iv_work_order_id ).
    IF lv_order_exists IS INITIAL.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    " Verificar si el estado de la orden es editable (por ejemplo, Pendiente)
    IF iv_status <> c_valid_status-pe AND iv_status <> c_valid_status-co.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

  METHOD validate_delete_order.
    " Verificar si la orden existe
    DATA(lv_order_exists) = check_order_exists( iv_work_order_id ).
    IF lv_order_exists IS INITIAL.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    " Verificar si el estado de la orden es "PE" (Pendiente)
    IF iv_status <> c_valid_status-pe.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    " Verificar si la orden tiene historial (es decir, si ha sido modificada antes)
    DATA(lv_has_history) = check_order_history( iv_work_order_id ).
    IF lv_has_history IS NOT INITIAL.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

  METHOD validate_status_and_priority.
    " Validar el valor del estado
    IF iv_status <> c_valid_status-pe AND iv_status <> c_valid_status-co.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    " Validar el valor de la prioridad
    IF iv_priority <> c_valid_priority-a AND iv_priority <> c_valid_priority-b.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

  METHOD check_customer_exists.

    SELECT SINGLE FROM ztcustomer_fjcm
                  FIELDS customer_id
                  WHERE customer_id = @iv_customer_id
                  INTO @DATA(lv_customer_id).
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD check_technician_exists.

    SELECT SINGLE FROM zttechnician_fjc
                  FIELDS technician_id
                  WHERE technician_id = @iv_technician_id
                  INTO @DATA(lv_technician_id).
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD check_order_exists.

    SELECT SINGLE FROM ztwork_order_fjc
                  FIELDS work_order_id
                  WHERE work_order_id = @iv_work_order_id
                  INTO @DATA(lv_work_order_id).
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD check_order_history.
     SELECT SINGLE FROM ztwork_histo_fjc
                  FIELDS history_id
                  WHERE work_order_id = @iv_work_order_id
                  INTO @DATA(lv_history_id).
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
