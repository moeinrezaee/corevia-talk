import { RecoveryScreen } from "./RecoveryScreen";
import { tl } from "@/shared/i18n/tl";

export function RelaunchRequiredScreen() {
  return (
    <RecoveryScreen
      testId="relaunch-required"
      title={tl("Restart Buzz to finish recovery")}
      body="Your identity was updated. Buzz needs to restart so syncing and agents run under it."
    />
  );
}
