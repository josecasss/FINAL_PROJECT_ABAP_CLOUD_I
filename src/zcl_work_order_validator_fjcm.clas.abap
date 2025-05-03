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
    DATA(lv_is_valid) = lo_validator->validate_create_order(
        iv_customer_id  = '12345678'  " Replace with a valid customer ID from ZT_CUSTOMER
        iv_technician_id = 'TECH0001'  " Replace with a valid technician ID from ZT_TECHNICIAN
        iv_priority      = 'A'
    ).
    IF lv_is_valid = abap_true.
      out->write( |Is order creation valid? TRUE| ).
    ELSE.
      out->write( |Is order creation valid? FALSE| ).
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
    " Implementación: Verificar en la tabla ZT_CUSTOMER si existe el cliente
    SELECT SINGLE customer_id
           FROM ztcustomer_fjcm
           WHERE customer_id = @iv_customer_id
           INTO @DATA(lv_customer_id).  " Added INTO clause
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD check_technician_exists.
    " Implementación: Verificar en la tabla ZT_TECHNICIAN si existe el técnico
    SELECT SINGLE technician_id
           FROM zttechnician_fjc
           WHERE technician_id = @iv_technician_id
           INTO @DATA(lv_technician_id).  " Added INTO clause
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD check_order_exists.
    " Implementación: Verificar en la tabla ZT_WORK_ORDER si existe la orden
    SELECT SINGLE work_order_id
           FROM ztwork_order_fjc
           WHERE work_order_id = @iv_work_order_id
           INTO @DATA(lv_work_order_id).  " Added INTO clause
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD check_order_history.
    " Implementación: Verificar en la tabla ZT_WORK_ORDER_HIST si hay entradas para la orden
    SELECT SINGLE history_id
           FROM ztwork_histo_fjc
           WHERE work_order_id = @iv_work_order_id
           INTO @DATA(lv_history_id).  " Added INTO clause
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ELSE.
      rv_exists = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
