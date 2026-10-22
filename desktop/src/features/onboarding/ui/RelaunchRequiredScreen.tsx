import { RecoveryScreen } from "./RecoveryScreen";

export function RelaunchRequiredScreen() {
  return (
    <RecoveryScreen
      testId="relaunch-required"
      title="Restart Corevia Talk to finish recovery"
      body="Your identity was updated. Corevia Talk needs to restart so syncing and agents run under it."
    />
  );
}
