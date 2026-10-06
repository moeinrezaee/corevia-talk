import { RecoveryScreen } from "./RecoveryScreen";
import { tl } from "@/shared/i18n/tl";

export function ResetFailedScreen() {
  return (
    <RecoveryScreen
      testId="reset-failed"
      title={tl("Sign out could not complete")}
      body="Buzz was unable to fully clear your local data. Try relaunching — the reset will resume automatically. If this persists, contact support."
    />
  );
}
