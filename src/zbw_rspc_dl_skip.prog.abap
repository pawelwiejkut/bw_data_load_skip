*&---------------------------------------------------------------------*
*& Report zbw_rspc_dl_skip
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbw_rspc_dl_skip.

DATA: lv_rspc TYPE rspc_chain.

SELECT-OPTIONS: so_rspc FOR lv_rspc NO INTERVALS.
PARAMETERS: pa_logs TYPE logsys.

CHECK so_rspc IS NOT INITIAL.

SELECT * FROM
rspcchain
INTO TABLE @DATA(lt_dtp_rspc)
WHERE chain_id IN @so_rspc
AND type = 'DTP_LOAD'
AND objvers = 'A'.

LOOP AT so_rspc REFERENCE INTO DATA(lr_rspc).

  LOOP AT lt_dtp_rspc REFERENCE INTO DATA(lr_dtp_rspc).

    DATA(lr_dtp) =   cl_rsbk_dtp_api=>factory( i_dtp = lr_dtp_rspc->variante  ).

    TRY.
        lr_dtp->get_dtp( IMPORTING e_s_general = DATA(ls_general) ).
      CATCH cx_rs_failed INTO DATA(lr_failed).
        MESSAGE lr_failed->get_text( ) type 'E'.
    ENDTRY.

    IF ls_general-srctlogo = 'RSDS'.

      cl_rsds_rsds=>convert_tlogo_real(
        EXPORTING
          i_tlogo       = CONV #( ls_general-src )
        IMPORTING
          e_logsys      = DATA(lv_logsys) ).

      IF lv_logsys = pa_logs.

        DATA(lr_chain) = NEW cl_rspc_chain( i_chain = lr_rspc->low
        i_objvers = 'A'
        i_display_only = abap_true
        I_FILTER_CLIENT = abap_true
        i_no_transport = abap_true ).

        lr_chain->set_skipped(
          EXPORTING
            i_s_process     = VALUE #( chain_id = lr_rspc->low
                                           type = 'DTP_LOAD'
                                       variante =  lr_dtp_rspc->variante
                                   eventp_start = lr_dtp_rspc->eventp_start
                                   event_start  = lr_dtp_rspc->event_start
                                        )
            i_to_be_skipped = abap_true
        ).

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDLOOP.
