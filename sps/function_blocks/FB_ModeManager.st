(*
    sps/function_blocks/FB_ModeManager.st
    Betriebsarten- und Tasterauswertung.

    Aufgaben:
      - Betriebsart aus Wahlschalter (AUTO / HAND)
      - Start/Stop als gespeicherter Laufwunsch (Flankenauswertung)
      - Reset-Sammelimpuls (Flanke)
*)

FUNCTION_BLOCK FB_ModeManager
VAR_INPUT
    xModeAuto : BOOL;       (* Wahlschalter *)
    xStartBtn : BOOL;
    xStopBtn  : BOOL;
    xResetBtn : BOOL;
END_VAR
VAR_OUTPUT
    eMode       : E_Mode;
    xRunRequest : BOOL;     (* Laufwunsch, gespeichert *)
    xStartPulse : BOOL;     (* Flanke Start *)
    xStopPulse  : BOOL;     (* Flanke Stop *)
    xResetPulse : BOOL;     (* Flanke Reset *)
END_VAR
VAR
    fbStart : FB_R_TRIG;
    fbStop  : FB_R_TRIG;
    fbReset : FB_R_TRIG;
END_VAR
    fbStart(CLK := xStartBtn);
    fbStop(CLK := xStopBtn);
    fbReset(CLK := xResetBtn);

    xStartPulse := fbStart.Q;
    xStopPulse  := fbStop.Q;
    xResetPulse := fbReset.Q;

    IF xModeAuto THEN
        eMode := E_Mode#MODE_AUTO;
    ELSE
        eMode := E_Mode#MODE_MANUAL;
    END_IF

    (* Laufwunsch speichern *)
    IF xStartPulse THEN
        xRunRequest := TRUE;
    END_IF
    IF xStopPulse THEN
        xRunRequest := FALSE;
    END_IF
END_FUNCTION_BLOCK
