(*
    sps/standard/Standard.st
    Eigene Standard-Bausteine (Hilfsfunktionen und Zeitglieder).

    Zeitglieder, Flankenerkennung und Skalierung sind hier selbst umgesetzt.
    Die Zeitglieder arbeiten mit der Simulationszeit gSimTimeMs (fest).
*)

(* ================= Typkonvertierungen ================= *)

FUNCTION INT_TO_REAL : REAL
VAR_INPUT
    in : INT;
END_VAR
    INT_TO_REAL := in;
END_FUNCTION

FUNCTION DINT_TO_REAL : REAL
VAR_INPUT
    in : DINT;
END_VAR
    DINT_TO_REAL := in;
END_FUNCTION

(* Rundung auf die naechste ganze Zahl (kaufmaennisch) *)
FUNCTION REAL_TO_DINT : DINT
VAR_INPUT
    in : REAL;
END_VAR
VAR
    r : REAL;
END_VAR
    IF in >= 0.0 THEN
        r := in + 0.5;
    ELSE
        r := in - 0.5;
    END_IF
    REAL_TO_DINT := r;
END_FUNCTION

(* Betrag *)
FUNCTION ABS_REAL : REAL
VAR_INPUT
    x : REAL;
END_VAR
    IF x < 0.0 THEN
        ABS_REAL := -x;
    ELSE
        ABS_REAL := x;
    END_IF
END_FUNCTION

(* Begrenzung auf [lo, hi] *)
FUNCTION LIMIT_REAL : REAL
VAR_INPUT
    x  : REAL;
    lo : REAL;
    hi : REAL;
END_VAR
    IF x < lo THEN
        LIMIT_REAL := lo;
    ELSIF x > hi THEN
        LIMIT_REAL := hi;
    ELSE
        LIMIT_REAL := x;
    END_IF
END_FUNCTION

(* ================= Flankenerkennung ================= *)

FUNCTION_BLOCK FB_R_TRIG
VAR_INPUT
    CLK : BOOL;
END_VAR
VAR_OUTPUT
    Q : BOOL;
END_VAR
VAR
    M : BOOL;
END_VAR
    Q := CLK AND NOT M;
    M := CLK;
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_F_TRIG
VAR_INPUT
    CLK : BOOL;
END_VAR
VAR_OUTPUT
    Q : BOOL;
END_VAR
VAR
    M : BOOL;
END_VAR
    Q := (NOT CLK) AND M;
    M := CLK;
END_FUNCTION_BLOCK

(* ================= Zeitglieder (deterministisch) ================= *)

(* Einschaltverzoegerung (TON) *)
FUNCTION_BLOCK FB_TON
VAR_INPUT
    IN : BOOL;
    PT : DINT;          (* Verzoegerung in ms *)
END_VAR
VAR_OUTPUT
    Q  : BOOL;
    ET : DINT;          (* verstrichene Zeit in ms *)
END_VAR
VAR
    tStart   : DINT;
    xRunning : BOOL;
END_VAR
    IF IN THEN
        IF NOT xRunning THEN
            xRunning := TRUE;
            tStart := gSimTimeMs;
        END_IF
        ET := gSimTimeMs - tStart;
        IF ET >= PT THEN
            Q := TRUE;
        END_IF
    ELSE
        xRunning := FALSE;
        Q := FALSE;
        ET := 0;
    END_IF
END_FUNCTION_BLOCK

(* Ausschaltverzoegerung (TOF) *)
FUNCTION_BLOCK FB_TOF
VAR_INPUT
    IN : BOOL;
    PT : DINT;
END_VAR
VAR_OUTPUT
    Q  : BOOL;
    ET : DINT;
END_VAR
VAR
    tStart  : DINT;
    xTiming : BOOL;
END_VAR
    IF IN THEN
        Q := TRUE;
        xTiming := FALSE;
        ET := 0;
    ELSE
        IF NOT xTiming THEN
            xTiming := TRUE;
            tStart := gSimTimeMs;
        END_IF
        ET := gSimTimeMs - tStart;
        IF ET >= PT THEN
            Q := FALSE;
        ELSE
            Q := TRUE;
        END_IF
    END_IF
END_FUNCTION_BLOCK
