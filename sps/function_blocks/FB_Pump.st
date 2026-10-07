(*
    sps/function_blocks/FB_Pump.st
    Pumpensteuerung mit Sicherheitsfreigabe und Rueckmeldungsueberwachung.

    Verriegelungen:
      - Ausgang nur bei xEnable (Freigabe aus FB_Safety) und xCommand
      - bei Ueberlast (xOverload) -> Störung, Ausgang AUS
      - fehlende Lauf-Rueckmeldung nach Ablauf von tFeedbackMs -> Stoerung
    Stoerungen werden gespeichert und durch xReset (Flanke) zurueckgesetzt.
*)

FUNCTION_BLOCK FB_Pump
VAR_INPUT
    xCommand    : BOOL;     (* Betrieb angefordert *)
    xEnable     : BOOL;     (* Freigabe (Verriegelung) *)
    xFeedback   : BOOL;     (* Rueckmeldung "Pumpe laeuft" *)
    xOverload   : BOOL;     (* Motorschutz/Fault vom Feld *)
    xReset      : BOOL;     (* Stoerungsreset (Flanke) *)
    tFeedbackMs : DINT;     (* Ueberwachungszeit *)
END_VAR
VAR_OUTPUT
    xRun           : BOOL;  (* Pumpenausgang *)
    xFault         : BOOL;  (* gespeicherte Stoerung *)
    xFeedbackFault : BOOL;  (* Rueckmeldung ausgeblieben *)
    xFeedbackOK    : BOOL;  (* Rueckmeldung plausibel *)
END_VAR
VAR
    fbFeedback : FB_TON;
END_VAR
    (* Reset der gespeicherten Stoerung *)
    IF xReset THEN
        xFault := FALSE;
        xFeedbackFault := FALSE;
    END_IF

    (* Ueberlast ist eine sofortige, speichernde Stoerung *)
    IF xOverload THEN
        xFault := TRUE;
    END_IF

    (* Ausgang nur bei Anforderung + Freigabe + keiner Stoerung *)
    xRun := xCommand AND xEnable AND NOT xFault;

    (* Ueberwachung der Lauf-Rueckmeldung *)
    fbFeedback(IN := xRun AND NOT xFeedback, PT := tFeedbackMs);
    xFeedbackOK := xRun AND xFeedback;
    IF xRun AND NOT xFeedback AND fbFeedback.Q THEN
        xFeedbackFault := TRUE;
        xFault := TRUE;
        xRun := FALSE;
    END_IF
END_FUNCTION_BLOCK
