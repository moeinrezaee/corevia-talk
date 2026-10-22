import type { AcpCommandCandidate } from "@/shared/api/acpCommands";
import type { PersonaDropdownOption } from "./agentConfigOptions";
import { tl } from "@/shared/i18n/tl";

export const DEFAULT_ACP_COMMAND_VALUE = "corevia-talk-acp";

export function acpCommandPickerState(
  command: string,
  candidates: readonly AcpCommandCandidate[],
): {
  options: PersonaDropdownOption[];
  selectValue: string;
} {
  const options: PersonaDropdownOption[] = [
    { label: tl("Corevia Talk ACP (default)"), value: DEFAULT_ACP_COMMAND_VALUE },
    ...candidates.map((candidate) => ({
      label: candidate.command,
      value: candidate.command,
    })),
  ];
  if (command && !options.some((option) => option.value === command)) {
    options.push({
      disabled: true,
      label: `${command} (unavailable)`,
      value: command,
    });
  }
  return { options, selectValue: command || DEFAULT_ACP_COMMAND_VALUE };
}
