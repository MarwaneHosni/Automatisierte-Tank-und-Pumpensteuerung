(*
    sps/function_blocks/FB_TankControl.st
    Füllstandsauswertung.

    Aufgaben:
      - Skalierung des analogen Rohwerts (0..27648) in Prozent (0..100)
      - Plausibilitaetspruefung (Grenzwert-Widerspruch, Bereichsfehler)
      - Ableitung der Grenzwertmeldungen (High, Critical, Critical-Low)
      - Fuellbedarf mit Hysterese (Start 30 %, Stopp 80 %)
*)

FUNCTION_BLOCK FB_TankControl
VAR_INPUT
    iwRaw         : INT;    (* analoger Rohwert *)
    xLowLevel     : BOOL;   (* digitaler Grenzwertschalter Low *)
    xHighLevel    : BOOL;   (* digitaler Grenzwertschalter High *)
    xVeryHighLevel: BOOL;   (* digitaler Grenzwertschalter Very-High *)
END_VAR
VAR_OUTPUT
    rLevelPct     : REAL;   (* Füllstand in % *)
    xRawOutOfRange: BOOL;   (* Rohwert ausserhalb 0..27648 *)
    xSensorError  : BOOL;   (* unplausible Sensorinformation *)
    xHighAlarm    : BOOL;   (* >= 90 % *)
    xCriticalHigh : BOOL;   (* >= 95 % *)
    xCriticalLow  : BOOL;   (* <= 10 % *)
    xFillDemand   : BOOL;   (* Fuellen erforderlich (mit Hysterese) *)
    xLowSensor    : BOOL;   (* digitaler Low-Grenzwert *)
END_VAR
VAR
    rLastValid  : REAL;     (* letzter gueltiger Messwert *)
    initialized : BOOL;
END_VAR
    (* --- Plausibilitaet des Rohwerts --- *)
    xRawOutOfRange := (iwRaw < RAW_MIN) OR (iwRaw > RAW_MAX);
    (* Widerspruch: Low- und High-Grenzwert gleichzeitig aktiv *)
    xSensorError := (xLowLevel AND xHighLevel) OR xRawOutOfRange;

    (* --- Skalierung Rohwert -> Engineering Unit [%] --- *)
    IF xRawOutOfRange THEN
        (* ungueltiger Wert: letzten gueltigen Messwert halten *)
        rLevelPct := rLastValid;
    ELSE
        rLevelPct := EU_MIN +
                     (INT_TO_REAL(iwRaw - RAW_MIN) / INT_TO_REAL(RAW_MAX - RAW_MIN)) *
                     (EU_MAX - EU_MIN);
        rLevelPct := LIMIT_REAL(rLevelPct, EU_MIN, EU_MAX);
        rLastValid := rLevelPct;
    END_IF

    (* --- Grenzwerte (analog ODER digital) --- *)
    xLowSensor    := xLowLevel;
    xHighAlarm    := (rLevelPct >= LVL_HIGH_ALARM_PCT) OR xHighLevel;
    xCriticalHigh := (rLevelPct >= LVL_CRITICAL_PCT) OR xVeryHighLevel;
    xCriticalLow  := rLevelPct <= LVL_CRITICAL_LOW_PCT;

    (* --- Fuellbedarf mit Hysterese (Start 30 %, Stopp 80 %) --- *)
    IF NOT initialized THEN
        xFillDemand := rLevelPct < LVL_FILL_START_PCT;
        initialized := TRUE;
    END_IF
    IF rLevelPct <= LVL_FILL_START_PCT THEN
        xFillDemand := TRUE;
    ELSIF rLevelPct >= LVL_FILL_STOP_PCT THEN
        xFillDemand := FALSE;
    END_IF
END_FUNCTION_BLOCK
