(*
    sps/function_blocks/FB_Safety.st
    Sicherheits- und Verriegelungslogik.

    Zentrale Freigaben fuer Pumpe, Zulauf und Ablauf. In einer realen Anlage
    schaltet ein Sicherheitsschaltgeraet (z. B. PNOZ) den Not-Aus allpolig ab;
    hier ist diese Abschaltung logisch nachgebildet.

    Die Aktor-Bausteine (FB_Pump, FB_Valve) setzen diese Freigaben zusaetzlich
    zu ihren eigenen Verriegelungen durch.
*)

FUNCTION_BLOCK FB_Safety
VAR_INPUT
    xEStop              : BOOL; (* Not-Aus aktiv *)
    xPumpOverload       : BOOL; (* Motorueberlast *)
    xPumpFeedbackFault  : BOOL; (* Pumpen-Rueckmeldung fehlt *)
    xValveFault         : BOOL; (* Ventilstellungsfehler *)
    xSensorError        : BOOL; (* unplausible Sensorik *)
    xCriticalHigh       : BOOL; (* kritisch hoher Füllstand *)
    xCriticalLow        : BOOL; (* kritisch niedriger Füllstand *)
END_VAR
VAR_OUTPUT
    xSafe        : BOOL;        (* Grundfreigabe (kein Not-Aus) *)
    xPumpEnable  : BOOL;        (* Freigabe Pumpe *)
    xFillEnable  : BOOL;        (* Freigabe Zulaufventil *)
    xDrainEnable : BOOL;        (* Freigabe Ablaufventil *)
    xAnyFault    : BOOL;        (* Sammelstoerung *)
END_VAR
    (* Not-Aus hebt jede Freigabe auf *)
    xSafe := NOT xEStop;

    (* Sammelstoerung (fuehrt in den FAULT-Zustand) *)
    xAnyFault := xPumpOverload OR xPumpFeedbackFault OR xValveFault
                 OR xSensorError OR xCriticalHigh;

    (* Pumpe: keine Freigabe bei Ueberlast/Rueckmeldungsfehler/kritisch niedrig *)
    xPumpEnable  := xSafe AND NOT xPumpOverload AND NOT xPumpFeedbackFault
                    AND NOT xCriticalLow AND NOT xSensorError;

    (* Zulauf: keine Freigabe bei kritisch hoch / Ventilfehler / Sensorfehler *)
    xFillEnable  := xSafe AND NOT xCriticalHigh AND NOT xValveFault
                    AND NOT xSensorError;

    (* Ablauf: nur Grundfreigabe und plausible Sensorik *)
    xDrainEnable := xSafe AND NOT xSensorError;
END_FUNCTION_BLOCK
