(*
    sps/function_blocks/FB_Valve.st
    Ventilsteuerung mit Endlagen-Rueckmeldung.

    Verriegelungen:
      - Ausgang nur bei xEnable (Freigabe) und xCommand
      - bleibt die Offen-Rueckmeldung nach tFeedbackMs aus, obwohl das Ventil
        geoeffnet werden soll, wird eine Störung erzeugt (Stellungsfehler)
    Stoerungen werden gespeichert und durch xReset (Flanke) zurueckgesetzt.
*)

FUNCTION_BLOCK FB_Valve
VAR_INPUT
    xCommand        : BOOL;  (* Offen angefordert *)
    xEnable         : BOOL;  (* Freigabe (Verriegelung) *)
    xFeedbackOpen   : BOOL;  (* Rueckmeldung "offen" *)
    xFeedbackClosed : BOOL;  (* Rueckmeldung "geschlossen" *)
    xReset          : BOOL;  (* Stoerungsreset (Flanke) *)
    tFeedbackMs     : DINT;  (* Ueberwachungszeit *)
END_VAR
VAR_OUTPUT
    xOpen          : BOOL;   (* Ventilausgang *)
    xFault         : BOOL;   (* gespeicherte Stellungsstoerung *)
    xFeedbackOK    : BOOL;   (* Endlage passt zum Befehl *)
END_VAR
VAR
    fbFeedback : FB_TON;
END_VAR
    IF xReset THEN
        xFault := FALSE;
    END_IF

    xOpen := xCommand AND xEnable AND NOT xFault;

    (* Rueckmeldung pruefen: offen gefordert, aber nicht "offen" gemeldet *)
    fbFeedback(IN := xOpen AND NOT xFeedbackOpen, PT := tFeedbackMs);
    xFeedbackOK := (xOpen AND xFeedbackOpen) OR ((NOT xOpen) AND xFeedbackClosed);
    IF xOpen AND NOT xFeedbackOpen AND fbFeedback.Q THEN
        xFault := TRUE;
        xOpen := FALSE;
    END_IF
END_FUNCTION_BLOCK
