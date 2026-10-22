import { RecoveryScreen } from "./RecoveryScreen";
import { tl } from "@/shared/i18n/tl";

export function RelaunchRequiredScreen() {
  return (
    <RecoveryScreen
      testId="relaunch-required"
      title={tl("Restart Corevia Talk to finish recovery")}
      body="Your identity was updated. Corevia Talk needs to restart so syncing and agents run under it."
    />
  );
}
