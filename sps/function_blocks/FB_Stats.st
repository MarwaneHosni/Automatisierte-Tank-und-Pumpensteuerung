(*
    sps/function_blocks/FB_Stats.st
    Betriebsstatistik: Zyklen, Betriebszeit, Pumpenlaufzeit, Fuellzyklen.
*)

FUNCTION_BLOCK FB_Stats
VAR_INPUT
    xProcessRunning : BOOL;  (* Prozess aktiv (FILLING/PUMPING) *)
    xPumpRunning    : BOOL;  (* Pumpenausgang *)
    xFillDone       : BOOL;  (* Flanke: Fuellzyklus abgeschlossen *)
END_VAR
VAR_OUTPUT
    diCycles        : DINT;  (* Zyklen gesamt *)
    diRunTimeMs     : DINT;  (* Betriebszeit Prozess (ms) *)
    diPumpRunTimeMs : DINT;  (* Pumpenlaufzeit (ms) *)
    diFillCycles    : DINT;  (* abgeschlossene Fuellzyklen *)
END_VAR
VAR
    fbFillDone : FB_R_TRIG;
END_VAR
    diCycles := diCycles + 1;

    IF xProcessRunning THEN
        diRunTimeMs := diRunTimeMs + SCAN_PERIOD_MS;
    END_IF
    IF xPumpRunning THEN
        diPumpRunTimeMs := diPumpRunTimeMs + SCAN_PERIOD_MS;
    END_IF

    fbFillDone(CLK := xFillDone);
    IF fbFillDone.Q THEN
        diFillCycles := diFillCycles + 1;
    END_IF
END_FUNCTION_BLOCK
