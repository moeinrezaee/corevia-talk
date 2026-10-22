import { openUrl } from "@tauri-apps/plugin-opener";
import { useUpdaterContext } from "./hooks/UpdaterProvider";
import { Button } from "@/shared/ui/button";
import {
  SettingsOptionGroup,
  SettingsOptionRow,
} from "./ui/SettingsOptionGroup";
import { SettingsSectionHeader } from "./ui/SettingsSectionHeader";
import { tl } from "@/shared/i18n/tl";
export function UpdateChecker() {
  const { status, checkForUpdate, installAndRelaunch } = useUpdaterContext();

  return (
    <section className="min-w-0" data-testid="settings-updates">
      <SettingsSectionHeader
        title={tl("Software Updates")}
        description={tl(
          "Keep Corevia Talk up to date with the latest features and fixes.",
        )}
      />

      <SettingsOptionGroup title={tl("Update status")}>
        {status.state === "idle" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p
                className="text-sm font-normal text-muted-foreground/70"
                data-settings-subcopy
              >
                {tl("Check if a new version is available.")}
              </p>
            </div>
            <Button size="sm" onClick={checkForUpdate}>
              {tl("Check for Updates")}
            </Button>
          </SettingsOptionRow>
        )}

        {status.state === "checking" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p
                className="text-sm font-normal text-muted-foreground/70"
                data-settings-subcopy
              >
                {tl("Checking for updates...")}
              </p>
            </div>
          </SettingsOptionRow>
        )}

        {status.state === "up-to-date" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p
                className="text-sm font-normal text-muted-foreground/70"
                data-settings-subcopy
              >
                {tl("You're on the latest version.")}
              </p>
            </div>
            <Button variant="outline" size="sm" onClick={checkForUpdate}>
              {tl("Check Again")}
            </Button>
          </SettingsOptionRow>
        )}

        {status.state === "unavailable" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p
                className="text-sm font-normal text-muted-foreground/70"
                data-settings-subcopy
              >
                {tl(
                  "Automatic updates aren't available on this build. Download the latest release manually.",
                )}
              </p>
            </div>
            <Button variant="outline" size="sm" onClick={checkForUpdate}>
              {tl("Check Again")}
            </Button>
          </SettingsOptionRow>
        )}

        {status.state === "manual-required" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p className="text-sm font-medium">
                {tl("Update available — v")}
                {status.version}
              </p>
              <p
                className="text-sm font-normal text-muted-foreground/70"
                data-settings-subcopy
              >
                {tl(
                  "In-app updates aren't supported on this Linux package. Download the new version from GitHub.",
                )}{" "}
                <span>
                  {tl("Switch to the AppImage build for automatic updates.")}
                </span>
              </p>
            </div>
            <Button size="sm" onClick={() => void openUrl(status.releaseUrl)}>
              {tl("Download Update")}
            </Button>
          </SettingsOptionRow>
        )}

        {status.state === "available" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p
                className="text-sm font-normal text-muted-foreground/70"
                data-settings-subcopy
              >
                {tl("Preparing update...")}
              </p>
            </div>
          </SettingsOptionRow>
        )}

        {status.state === "downloading" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p
                className="text-sm font-normal text-muted-foreground/70"
                data-settings-subcopy
              >
                {tl("Downloading update...")}
              </p>
            </div>
          </SettingsOptionRow>
        )}

        {status.state === "installing" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p
                className="text-sm font-normal text-muted-foreground/70"
                data-settings-subcopy
              >
                {tl("Installing update...")}
              </p>
            </div>
          </SettingsOptionRow>
        )}

        {status.state === "ready" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p
                className="text-sm font-normal text-muted-foreground/70"
                data-settings-subcopy
              >
                {tl("Update downloaded. Click to apply.")}
              </p>
            </div>
            <Button size="sm" onClick={installAndRelaunch}>
              {tl("Update Now")}
            </Button>
          </SettingsOptionRow>
        )}

        {status.state === "error" && (
          <SettingsOptionRow>
            <div className="min-w-0">
              <p className="text-sm font-normal text-destructive">
                {tl("Update failed:")} {status.message}
              </p>
            </div>
            <Button variant="outline" size="sm" onClick={checkForUpdate}>
              {tl("Retry")}
            </Button>
          </SettingsOptionRow>
        )}
      </SettingsOptionGroup>
    </section>
  );
}
