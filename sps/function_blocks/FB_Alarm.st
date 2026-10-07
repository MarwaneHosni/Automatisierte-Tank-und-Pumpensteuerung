(*
    sps/function_blocks/FB_Alarm.st
    Generischer Alarm-Baustein.

    Jede Alarminstanz erhaelt eine feste Kennung und Prioritaet sowie die
    ausloesende Bedingung. Der Alarm wird gespeichert (latch) und kann mit
    einem Sammelreset (Flanke) quittiert/zurueckgesetzt werden.
*)

FUNCTION_BLOCK FB_Alarm
VAR_INPUT
    xTrigger : BOOL;        (* Ausloesende Bedingung *)
    xReset   : BOOL;        (* Sammelreset (Flanke vom PLC_PRG) *)
    id       : E_AlarmId;
    severity : E_Severity;
    xDelay   : BOOL;        (* optionale Verzoegerung aktiv *)
    tDelayMs : DINT;        (* Verzoegerungszeit *)
END_VAR
VAR_OUTPUT
    xActive      : BOOL;    (* Bedingung liegt aktuell an *)
    xLatched     : BOOL;    (* gespeichert, bis Reset *)
    xAcknowledged: BOOL;    (* quittiert *)
END_VAR
VAR
    fbDelay : FB_TON;
    xCond   : BOOL;
END_VAR
    (* optionale Einschaltverzoegerung *)
    IF xDelay THEN
        fbDelay(IN := xTrigger, PT := tDelayMs);
        xCond := fbDelay.Q;
    ELSE
        fbDelay(IN := FALSE, PT := tDelayMs);
        xCond := xTrigger;
    END_IF

    (* Speichern (latch) *)
    IF xCond THEN
        xLatched := TRUE;
    END_IF

    xActive := xCond;

    (* Reset: nur wenn Bedingung nicht mehr anliegt, wird der Alarm geloescht *)
    IF xReset THEN
        xAcknowledged := TRUE;
        IF NOT xCond THEN
            xLatched := FALSE;
            xAcknowledged := FALSE;
        END_IF
    END_IF
END_FUNCTION_BLOCK
