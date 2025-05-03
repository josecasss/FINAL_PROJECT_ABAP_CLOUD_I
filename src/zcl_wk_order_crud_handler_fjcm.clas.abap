CLASS zcl_wk_order_crud_handler_fjcm DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    METHODS:
      create_work_order
        IMPORTING
          is_work_order    TYPE ztwork_order_fjc
        RETURNING
          VALUE(rv_result) TYPE REF TO ztwork_order_fjc,

      read_work_order
        IMPORTING
          iv_work_order_id TYPE zde_work_order_id_fjcm
        RETURNING
          VALUE(rs_work_order) TYPE ztwork_order_fjc,

      update_work_order
        IMPORTING
          is_work_order    TYPE ztwork_order_fjc
        RETURNING
          VALUE(rv_success) TYPE abap_bool,

      delete_work_order
        IMPORTING
          iv_work_order_id TYPE zde_work_order_id_fjcm
          iv_status        TYPE zde_status_fjcm OPTIONAL
        RETURNING
          VALUE(rv_success) TYPE abap_bool.

  PRIVATE SECTION.
    DATA:
      mo_validator TYPE REF TO zcl_work_order_validator_fjcm.

    METHODS:
      initialize,

      get_next_work_order_id
        RETURNING
          VALUE(rv_work_order_id) TYPE zde_work_order_id_fjcm,

      add_work_order_history
        IMPORTING
          iv_work_order_id      TYPE zde_work_order_id_fjcm
          iv_change_description TYPE zde_change_description_fjcm
        RETURNING
          VALUE(rv_success)     TYPE abap_bool.

ENDCLASS.

CLASS zcl_wk_order_crud_handler_fjcm IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Inicializar el validador
    initialize( ).

    out->write( 'CRUD Handler initialized. Ready for CRUD operations.' ).
  ENDMETHOD.

  METHOD initialize.
    " Inicializar el validador si aún no se ha hecho
    IF mo_validator IS INITIAL.
      mo_validator = NEW zcl_work_order_validator_fjcm( ).
    ENDIF.
  ENDMETHOD.

  METHOD create_work_order.
    " Inicializar el validador
    initialize( ).

    " Comprobar si los datos de la orden de trabajo son válidos
    DATA(lv_valid) = mo_validator->validate_create_order(
        iv_customer_id   = is_work_order-customer_id
        iv_technician_id = is_work_order-technician_id
        iv_priority      = is_work_order-priority
    ).

    " Crear la orden de trabajo solo si es válida
    IF lv_valid = abap_true.
      " Generar un ID único para la nueva orden de trabajo
      DATA(lv_work_order_id) = get_next_work_order_id( ).

      " Crear una copia local de la estructura de la orden de trabajo
      DATA(ls_work_order) = is_work_order.

      " Actualizar campos clave
      ls_work_order-work_order_id = lv_work_order_id.
      ls_work_order-creation_date = cl_abap_context_info=>get_system_date( ).  " Fecha actual del sistema
      ls_work_order-status = 'PE'. " Por defecto, el estado es "Pendiente"

      " Insertar en la base de datos usando EML (Entity Manipulation Language)
      " que es la forma recomendada en ABAP Cloud
      INSERT ztwork_order_fjc FROM @ls_work_order.

      " Verificar si la inserción fue exitosa
      IF sy-subrc = 0.
        " Crear una referencia al resultado
        CREATE DATA rv_result.
        rv_result->* = ls_work_order.

        " Registrar en el historial
        add_work_order_history(
            iv_work_order_id      = lv_work_order_id
            iv_change_description = 'Work order created'
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD read_work_order.
    " Leer la orden de trabajo por ID desde la base de datos
    SELECT SINGLE *
      FROM ztwork_order_fjc
      WHERE work_order_id = @iv_work_order_id
      INTO @rs_work_order.

    " Si no se encuentra, rs_work_order permanecerá vacío (inicial)
  ENDMETHOD.

  METHOD update_work_order.
    " Inicializar el validador
    initialize( ).

    " Verificar si la orden de trabajo existe y puede ser actualizada
    DATA(lv_valid) = mo_validator->validate_update_order(
        iv_work_order_id = is_work_order-work_order_id
        iv_status        = is_work_order-status
    ).

    " Realizar la actualización solo si es válida
    IF lv_valid = abap_true.
      " También validar el estado y la prioridad
      DATA(lv_valid_status_priority) = mo_validator->validate_status_and_priority(
          iv_status   = is_work_order-status
          iv_priority = is_work_order-priority
      ).

      IF lv_valid_status_priority = abap_true.
        " Actualizar en la base de datos
        UPDATE ztwork_order_fjc FROM @is_work_order.

        " Verificar si la actualización fue exitosa
        IF sy-subrc = 0.
          rv_success = abap_true.

          " Registrar en el historial
          add_work_order_history(
              iv_work_order_id      = is_work_order-work_order_id
              iv_change_description = 'Work order updated'
          ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD delete_work_order.
    " Inicializar el validador
    initialize( ).

    " Obtener el estado actual si no se proporcionó
    DATA lv_status TYPE zde_status_fjcm.

    IF iv_status IS INITIAL.
      " Leer el estado actual de la orden de trabajo
      SELECT SINGLE status
        FROM ztwork_order_fjc
        WHERE work_order_id = @iv_work_order_id
        INTO @lv_status.
    ELSE.
      lv_status = iv_status.
    ENDIF.

    " Verificar si la orden de trabajo puede ser eliminada
    DATA(lv_valid) = mo_validator->validate_delete_order(
        iv_work_order_id = iv_work_order_id
        iv_status        = lv_status
    ).

    " Realizar la eliminación solo si es válida
    IF lv_valid = abap_true.
      " Eliminar de la base de datos
      DELETE FROM ztwork_order_fjc WHERE work_order_id = @iv_work_order_id.

      " Verificar si la eliminación fue exitosa
      IF sy-subrc = 0.
        rv_success = abap_true.

        " Registrar en el historial
        add_work_order_history(
            iv_work_order_id      = iv_work_order_id
            iv_change_description = 'Work order deleted'
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_next_work_order_id.
    " Obtener el último ID de orden de trabajo
    SELECT MAX( work_order_id )
      FROM ztwork_order_fjc
      INTO @DATA(lv_last_id).

    " Si no hay órdenes existentes, empezar desde 1
    IF sy-subrc <> 0 OR lv_last_id IS INITIAL.
      rv_work_order_id = '0000000001'.
    ELSE.
      " Incrementar el último ID
      DATA(lv_next_number) = CONV i( lv_last_id ) + 1.

      " Usar CONV con ALPHA para conversión
      rv_work_order_id = CONV zde_work_order_id_fjcm(
        CONV string( lv_next_number )
      ).
    ENDIF.
  ENDMETHOD.

  METHOD add_work_order_history.
    " Crear un registro de historial
    DATA: ls_history TYPE ztwork_histo_fjc.

    " Obtener el último ID de historial
    SELECT MAX( history_id )
      FROM ztwork_histo_fjc
      INTO @DATA(lv_last_history_id).

    " Si no hay registros existentes, empezar desde 1
    IF sy-subrc <> 0 OR lv_last_history_id IS INITIAL.
      ls_history-history_id = '000000000001'.
    ELSE.
      " Incrementar el último ID
      DATA(lv_next_number) = CONV i( lv_last_history_id ) + 1.

      " Usar CONV con ALPHA para conversión
      ls_history-history_id = CONV zde_history_fjcm(
        CONV string( lv_next_number  )
      ).
    ENDIF.

    " Asignar valores
    ls_history-work_order_id = iv_work_order_id.
    ls_history-modification_date = cl_abap_context_info=>get_system_date( ). " Fecha actual del sistema
    ls_history-change_description = iv_change_description.

    " Insertar en la base de datos
    INSERT ztwork_histo_fjc FROM @ls_history.

    " Verificar si la inserción fue exitosa
    IF sy-subrc = 0.
      rv_success = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

